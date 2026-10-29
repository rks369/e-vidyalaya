import 'package:evidyalaya/core/models/notes_model.dart';
import 'package:evidyalaya/core/services/open_file.dart';
import 'package:evidyalaya/core/utils/constants.dart';
import 'package:flutter/material.dart';

const _imageExtensions = {'.jpg', '.jpeg', '.png', '.gif', '.webp'};

class NotesGrid extends StatelessWidget {

  const NotesGrid({
    super.key,
    required this.notes,
  });

  final List<NotesModel> notes;

  @override
  Widget build(BuildContext context) {

    final scheme = Theme.of(context).colorScheme;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {

        final note = notes[index];
        final isImage = _imageExtensions.contains(note.ext.toLowerCase());

        return Card(
          child: InkWell(
            onTap: () => openFile(
              context: context,
              url: note.url,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: isImage
                      ? Image.network(
                          note.url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.broken_image_outlined,
                            color: scheme.onSurfaceVariant,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            extToImage[note.ext.toLowerCase()] ??
                                'images/clipboard.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    note.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );

      },
    );

  }

}
