import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_note/core/extensions/async_value_ui.dart';
import 'package:one_note/core/navigation/app_route_state.dart';
import 'package:one_note/features/notes/domain/note.dart';
import 'package:one_note/features/notes/presentation/notes_controller.dart';

class NoteEditAndDetailScreen extends ConsumerStatefulWidget {
  const NoteEditAndDetailScreen({super.key, this.note});

  final Note? note;

  @override
  ConsumerState<NoteEditAndDetailScreen> createState() =>
      _NoteEditAndDetailScreenState();
}

class _NoteEditAndDetailScreenState
    extends ConsumerState<NoteEditAndDetailScreen> {
  static const int maxLength = 1000000; // 1MB'a yakın karakter
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final String _initialTitle;
  late final String _initialContent;

  @override
  void initState() {
    super.initState();
    _initialTitle = widget.note?.title ?? '';
    _initialContent = widget.note?.content ?? '';
    _titleController = TextEditingController(text: _initialTitle);
    _contentController = TextEditingController(text: _initialContent);
  }

  Future<void> _saveAndGoBack() async {
    final currentTitle = _titleController.text;
    final currentContent = _contentController.text;
    if (!(currentTitle == _initialTitle && currentContent == _initialContent)) {
      await ref
          .read(notesControllerProvider.notifier)
          .saveIfChanged(currentTitle, currentContent, widget.note?.id);
    }
    ref.read(appRouteNotifierProvider.notifier).goToNotesList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(notesControllerProvider, (previous, next) {
      next.showSnackbarOnError(context);
    });
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _saveAndGoBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.note == null ? 'Yeni Not' : 'Not Detay/Düzenle'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _saveAndGoBack,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Başlık (isteğe bağlı)',
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textInputAction: TextInputAction.next,
                maxLength: 100,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: "Notunuzu buraya yazın... (1MB'a kadar)",
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                  maxLength: maxLength,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
