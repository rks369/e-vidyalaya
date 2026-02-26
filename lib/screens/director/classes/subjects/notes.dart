import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:evidyalaya/bloc/auth_cubit.dart';
import 'package:evidyalaya/database/director_my_sql_helper.dart';
import 'package:evidyalaya/models/notes_model.dart';
import 'package:evidyalaya/models/subject_model.dart';
import 'package:evidyalaya/services/change_screen.dart';
import 'package:evidyalaya/services/download_file.dart';
import 'package:evidyalaya/utils/constant.dart';
import 'package:evidyalaya/utils/custom_snack_bar.dart';
import 'package:evidyalaya/widgets/error.dart';
import 'package:evidyalaya/widgets/loading.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Notes extends StatefulWidget {
  final SubjectModel subjectModel;
  const Notes({super.key, required this.subjectModel});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  double progress = 0.0;
  @override
  Widget build(BuildContext context) {
    final blocProvider = BlocProvider.of<AuthCubit>(context);
    uploadFile(File file) {
      showProgressDialog(context);
      FirebaseStorage.instance.ref('notes').putFile(file).then(
        (result) {
          result.ref.getDownloadURL().then((url) {
            DirectorMySQLHelper.addNote(context, widget.subjectModel.id,
                    basename(file.path), extension(file.path), url)
                .whenComplete(() {
              Navigator.pop(context);
            });
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.subjectModel.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();

                          await picker
                              .pickImage(source: ImageSource.camera)
                              .then((xFile) {
                            if (xFile != null) {
                              File file = File(xFile.path);
                              uploadFile(file);
                            } else {
                              showErrorMessage(context, 'No File Selected !!!');
                            }
                          });
                        },
                        child: const Icon(Icons.camera),
                      ),
                      FloatingActionButton(
                        onPressed: () async {
                          await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['mp4', 'mkv', 'mpg', 'webm'],
                          ).then((result) {
                            if (result != null) {
                              File file = File(result.files.single.path!);
                              uploadFile(file);
                            } else {
                              showErrorMessage(context, 'No File Seleced !!!');
                            }
                          });
                        },
                        child: const Icon(Icons.video_file),
                      ),
                      FloatingActionButton(
                        onPressed: () async {
                          await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: [
                              'm4a',
                              'FLAC',
                              'mp3',
                              'mp4',
                              'wav',
                              'wma',
                              'aac'
                            ],
                          ).then((result) {
                            if (result != null) {
                              File file = File(result.files.single.path!);
                              uploadFile(file);
                            } else {
                              showErrorMessage(context, 'No File Seleced !!!');
                            }
                          });
                        },
                        child: const Icon(Icons.audio_file),
                      ),
                      FloatingActionButton(
                        onPressed: () async {
                          await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'doc'],
                          ).then((result) {
                            if (result != null) {
                              File file = File(result.files.single.path!);
                              uploadFile(file);
                            } else {
                              showErrorMessage(context, 'No File Seleced !!!');
                            }
                          });
                        },
                        child: const Icon(Icons.document_scanner),
                      )
                    ],
                  ),
                );
              });
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
          future: DirectorMySQLHelper.getNotesList(
              blocProvider.domainName, widget.subjectModel.id),
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
