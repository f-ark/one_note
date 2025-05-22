import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_note/core/navigation/app_route_enum.dart';
import 'package:one_note/core/navigation/app_route_path.dart';
import 'package:one_note/features/notes/domain/note.dart';
import 'package:one_note/features/notes/presentation/note_edit_screen.dart';
import 'package:one_note/features/notes/presentation/notes_list_screen.dart';
import 'package:one_note/features/notes/provider/notes_provider.dart';
import 'package:one_note/features/notes/provider/pages_provider.dart';

class AppRouterDelegate extends RouterDelegate<List<AppRoutePath>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<AppRoutePath>> {
  final WidgetRef ref;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  AppRouterDelegate(this.ref) {
    ref.listen<List<AppRoutePath>>(pagesProvider, (_, __) => notifyListeners());
  }

  @override
  List<AppRoutePath> get currentConfiguration => ref.read(pagesProvider);

  @override
  Widget build(BuildContext context) {
    final pages = ref.watch(pagesProvider);
    return Navigator(
      key: navigatorKey,
      pages: [for (final path in pages) ..._buildPage(path, ref)],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        ref.read(pagesProvider.notifier).pop();
        return true;
      },
    );
  }

  List<Page<dynamic>> _buildPage(AppRoutePath path, WidgetRef ref) {
    switch (path.route) {
      case AppRoute.notesList:
        return [const MaterialPage(child: NotesListScreen())];
      case AppRoute.noteEdit:
        return [
          MaterialPage(
            child: NoteEditScreen(
              note:
                  path.noteId == null ? null : _findNoteById(ref, path.noteId!),
            ),
          ),
        ];
      case AppRoute.unknown:
        return [
          MaterialPage(
            child: Scaffold(
              appBar: AppBar(title: const Text('Sayfa bulunamadı')),
              body: const Center(child: Text('404 - Sayfa bulunamadı')),
            ),
          ),
        ];
    }
  }

  @override
  Future<void> setNewRoutePath(List<AppRoutePath> configuration) async {
    ref.read(pagesProvider.notifier).setStack(configuration);
  }

  Note? _findNoteById(WidgetRef ref, String id) {
    final notes = ref.read(notesProvider).value;
    final note = notes?.firstWhere(
      (n) => n.id == id,
      orElse:
          () => Note(id: '', title: '', content: '', createdAt: DateTime(0)),
    );
    if (note == null || note.id.isEmpty) return null;
    return note;
  }
}
