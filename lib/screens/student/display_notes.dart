import 'dart:developer';

import 'package:evidyalaya/bloc/auth_cubit.dart';
import 'package:evidyalaya/database/director_my_sql_helper.dart';
import 'package:evidyalaya/models/notes_model.dart';
import 'package:evidyalaya/models/subject_model.dart';
import 'package:evidyalaya/services/download_file.dart';
import 'package:evidyalaya/utils/constant.dart';
import 'package:evidyalaya/widgets/error.dart';
import 'package:evidyalaya/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DisplayNotes extends StatelessWidget {
  final SubjectModel subjectModel;
  const DisplayNotes({super.key, required this.subjectModel});

  @override
  Widget build(BuildContext context) {
    final blocProvider = BlocProvider.of<AuthCubit>(context);
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            subjectModel.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: FutureBuilder(
          future: DirectorMySQLHelper.getNotesList(
              blocProvider.domainName, subjectModel.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const ErrorScreen();
            if (!snapshot.hasData) {
              return const Loading();
            } else {
              List<NotesModel> list = snapshot.data!;

              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'No Notes Exists !!!',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                );
              }
              return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 2 / 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    if (list[index].ext == '.jpg' ||
                        list[index].ext == '.png') {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          list[index].url,
                          fit: BoxFit.fill,
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () async {
                        log(list[index].url);
                        openFile(list[index].url + list[index].url,
                            list[index].title);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(extToImage[list[index].ext] ??
                                  'images/clipboard.png'),
                            ),
                            Text(list[index].title)
                          ],
                        ),
                      ),
                    );
                  });
            }
          }),
    );
  }
}
