import 'package:evidyalaya/core/bloc/connection_cubit.dart';
import 'package:evidyalaya/core/widgets/app_logo.dart';
import 'package:evidyalaya/core/widgets/error.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/core/widgets/no_internet.dart';
import 'package:evidyalaya/core/widgets/responsive_fields.dart';
import 'package:evidyalaya/core/widgets/simple_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatelessWidget {

  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact us'),
      ),
      body: BlocBuilder<ConnectionCubit, ConnectionStates>(
        builder: (context, state) {

          switch (state) {
            case ConnectionStates.checking:
              return const Loading();
            case ConnectionStates.notConnected:
              return const NoInternet();
            case ConnectionStates.error:
              return const ErrorScreen();
            case ConnectionStates.connected:
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ResponsiveFields(
                  children: [
                    const SizedBox(
                      height: 20,
                      width: double.infinity,
                    ),
                    const FullRow(child: Center(child: AppLogo())),
                    const SizedBox(height: 16),
                    SimpleTile(
                      title: "admin@evidyalaya.in",
                      onTap: () async {

                        await launchUrl(
                          Uri(
                            scheme: 'mailto',
                            path: 'evidyalayaerp@gmail.com',
                          ),
                        );

                      },
                      leading: const Icon(Icons.email),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                    SimpleTile(
                      title: "+91 9998887776",
                      onTap: () async {

                        await launchUrl(
                          Uri(
                            scheme: 'tel',
                            path: '99988877766',
                          ),
                        );

                      },
                      leading: const Icon(Icons.phone),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                    SimpleTile(
                      title: "www.evidyalaya.edu.in",
                      onTap: () async {

                        await launchUrl(
                          Uri.parse('https://www.assetsync.tech'),
                          mode: LaunchMode.externalApplication,
                        );

                      },
                      leading: const Icon(Icons.public),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              );
          }

        },
      ),
    );

  }

}
