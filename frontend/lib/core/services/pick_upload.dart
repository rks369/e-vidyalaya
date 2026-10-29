import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class PickedFile {

  PickedFile({
    required this.name,
    required this.length,
    required this.openRead,
  });

  final String name;
  final int length;
  final Stream<List<int>> Function() openRead;

}

const videoExtensions = ['mp4', 'mkv', 'mpg', 'mpeg', 'webm', 'mov'];
const audioExtensions = ['m4a', 'flac', 'mp3', 'wav', 'wma', 'aac', 'ogg'];
const documentExtensions = [
  'pdf',
  'doc',
  'docx',
  'ppt',
  'pptx',
  'xls',
  'xlsx',
  'txt',
];

bool get canUseCamera =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

Future<PickedFile?> takePhoto() async {

  final photo = await ImagePicker().pickImage(source: ImageSource.camera);
  if (photo == null) {
    return null;
  }
  return PickedFile(
    name: photo.name,
    length: await photo.length(),
    openRead: photo.openRead,
  );

}

Future<PickedFile?> pickFile({
  FileType type = FileType.any,
  List<String>? extensions,
}) async {

  final file = await FilePicker.pickFile(
    type: type,
    allowedExtensions: extensions,
  );
  if (file == null) {
    return null;
  }
  final length = await file.length();
  if (length != null) {
    return PickedFile(
      name: file.name,
      length: length,
      openRead: file.readAsByteStream,
    );
  }
  final bytes = await file.readAsBytes();
  return PickedFile(
    name: file.name,
    length: bytes.length,
    openRead: () => Stream.value(bytes),
  );

}
