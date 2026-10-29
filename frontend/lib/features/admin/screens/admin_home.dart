import 'package:evidyalaya/core/api/api_client.dart';
import 'package:evidyalaya/core/config/flavor_config.dart';
import 'package:evidyalaya/core/widgets/adaptive_list.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/core/widgets/user_avatar.dart';
import 'package:evidyalaya/features/admin/admin_routes.dart';
import 'package:evidyalaya/features/admin/admin_session.dart';
import 'package:evidyalaya/features/admin/models/institute_model.dart';
import 'package:evidyalaya/features/admin/screens/admin_login.dart';
import 'package:evidyalaya/features/admin/services/admin_service.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {

  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();

}

class _AdminHomeState extends State<AdminHome> {

  Future<List<InstituteModel>>? _future;

  @override
  void initState() {

    super.initState();
    AdminSession.restore();

  }

  void _refresh() {

    setState(() {

      _future = _load();

    });

  }

  Future<List<InstituteModel>> _load() async {

    try {
      return await AdminService.getInstitute();
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await AdminSession.clear();
      }
      rethrow;
    }

  }

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<bool?>(
      valueListenable: AdminSession.signedIn,
      builder: (context, signedIn, _) {

        if (signedIn == null) {
          return const Scaffold(body: Loading());
        }
        if (!signedIn) {
          _future = null;
          return const AdminLogin();
        }
        return _buildList(context: context);

      },
    );

  }

  Widget _buildList({required BuildContext context}) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add institute',
        child: const Icon(Icons.add),
        onPressed: () async {

          await Navigator.pushNamed(
            context,
            AdminRoutes.addInstitute,
          );
          _refresh();

        },
      ),
      appBar: AppBar(
        title: Text(FlavorConfig.instance.appTitle),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: AdminSession.clear,
          ),
        ],
      ),
      body: FutureBuilder<List<InstituteModel>>(
        future: _future ??= _load(),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            final error = snapshot.error;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      error is ApiException
                          ? error.message
                          : 'Something went wrong',
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data!;
          if (list.isEmpty) {
            return const Center(child: Text('No institutes yet'));
          }

          return AdaptiveList(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: list.length,
            itemBuilder: (context, index) {

              final institute = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: UserAvatar(
                    name: institute.name,
                    url: institute.logo,
                    radius: 28,
                  ),
                  title: Text(
                    institute.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${institute.code} · ${institute.domain}\n${institute.email}',
                  ),
                  isThreeLine: true,
                ),
              );

            },
          );

        },
      ),
    );

  }

}
