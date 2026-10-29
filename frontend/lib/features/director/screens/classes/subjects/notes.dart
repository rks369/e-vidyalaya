import 'package:evidyalaya/core/api/api_client.dart';
import 'package:evidyalaya/core/models/notes_model.dart';
import 'package:evidyalaya/core/models/subject_model.dart';
import 'package:evidyalaya/core/services/pick_upload.dart';
import 'package:evidyalaya/core/services/show_progress_dialog.dart';
import 'package:evidyalaya/core/utils/custom_snack_bar.dart';
import 'package:evidyalaya/core/widgets/empty_state.dart';
import 'package:evidyalaya/core/widgets/error.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/core/widgets/notes_grid.dart';
import 'package:evidyalaya/features/director/services/director_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Notes extends StatefulWidget {

  final SubjectModel subjectModel;
  const Notes({
    super.key,
    required this.subjectModel,
  });

  @override
  State<Notes> createState() => _NotesState();

}

class _NotesState extends State<Notes> {

  late Future<List<NotesModel>> _notes = _loadNotes();

  Future<List<NotesModel>> _loadNotes() =>
      DirectorService.getNoteList(subjectId: widget.subjectModel.id);

  Future<void> _pickAndUpload({required Future<PickedFile?> Function() pick}) async {

    Navigator.pop(context);
    final PickedFile? file;
    try {
      file = await pick();
    } catch (_) {
      if (mounted) {
        showErrorMessage(
          context: context,
          error: 'Could not open that file',
        );
      }
      return;
    }
    if (!mounted) {
      return;
    }
    if (file == null) {
      showErrorMessage(
        context: context,
        error: 'No File Selected !!!',
      );
      return;
    }

    showProgressDialog(context: context);
    try {
      final uploaded = await ApiClient.instance.upload(
        filename: file.name,
        length: file.length,
        content: file.openRead(),
      );
      await DirectorService.addNote(
        subjectId: widget.subjectModel.id,
        title: file.name,
        ext: uploaded.ext,
        url: uploaded.url,
      );
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
      showSuccessMessage(
        context: context,
        message: 'Note Added Successfully',
      );
      setState(() {

        _notes = _loadNotes();

      });
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
      showErrorMessage(
        context: context,
        error: e.message,
      );
    }

  }

  void _showPicker() {

    final options = <(
      IconData,
      String,
      Future<PickedFile?> Function(),
    )>[
      if (canUseCamera) (Icons.camera_alt, 'Camera', takePhoto),
      (
        Icons.image,
        'Image',
        () => pickFile(type: FileType.image),
      ),
      (
        Icons.video_file,
        'Video',
        () => pickFile(
          type: FileType.custom,
          extensions: videoExtensions,
        ),
      ),
      (
        Icons.audio_file,
        'Audio',
        () => pickFile(
          type: FileType.custom,
          extensions: audioExtensions,
        ),
      ),
      (
        Icons.picture_as_pdf,
        'Document',
        () => pickFile(
          type: FileType.custom,
          extensions: documentExtensions,
        ),
      ),
    ];
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 24,
          runSpacing: 16,
          children: [
            for (final (icon, label, pick) in options)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: label,
                    onPressed: () => _pickAndUpload(pick: pick),
                    child: Icon(icon),
                  ),
                  const SizedBox(height: 6),
                  Text(label),
                ],
              ),
          ],
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectModel.name),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPicker,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _notes,
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return const ErrorScreen();
          }
          if (!snapshot.hasData) {
            return const Loading();
          }
          final list = snapshot.data!;
          if (list.isEmpty) {
            return const EmptyState(
              message: 'No notes yet',
              icon: Icons.note_outlined,
            );
          }
          return NotesGrid(notes: list);

        },
      ),
    );

  }

}
