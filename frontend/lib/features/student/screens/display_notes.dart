import 'package:evidyalaya/core/models/subject_model.dart';
import 'package:evidyalaya/core/widgets/empty_state.dart';
import 'package:evidyalaya/core/widgets/error.dart';
import 'package:evidyalaya/core/widgets/loading.dart';
import 'package:evidyalaya/core/widgets/notes_grid.dart';
import 'package:evidyalaya/features/director/services/director_service.dart';
import 'package:flutter/material.dart';

class DisplayNotes extends StatelessWidget {

  final SubjectModel subjectModel;
  const DisplayNotes({
    super.key,
    required this.subjectModel,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(subjectModel.name),
      ),
      body: FutureBuilder(
        future: DirectorService.getNotesList(subjectId: subjectModel.id),
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
