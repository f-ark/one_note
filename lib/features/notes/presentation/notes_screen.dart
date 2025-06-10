import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_note/core/navigation/app_route_state.dart';
import 'package:one_note/core/utils/responsive.dart';
import 'package:one_note/core/widgets/app_bottom_sheet.dart';
import 'package:one_note/features/authentication/data/auth_repository.dart';
import 'package:one_note/features/authentication/presentation/login/auth_controller.dart';
import 'package:one_note/features/notes/domain/note.dart';
import 'package:one_note/features/notes/presentation/notes_controller.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _sortType = 'modified'; // 'modified', 'created', 'alphabetical'
  bool _isWideView = false;
  String _searchQuery = '';
  final SearchController _searchController = SearchController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _searchBarIsNotOpen = true;
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notesControllerProvider.notifier).loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return AppBottomSheet(
          // Use AppBottomSheet to wrap the content
          title: 'Sıralama ve Filtre',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.update),
                title: const Text('Değiştirilme Tarihi'),
                trailing:
                    _sortType == 'modified' ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() => _sortType = 'modified');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Oluşturulma Tarihi'),
                trailing:
                    _sortType == 'created' ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() => _sortType = 'created');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Alfabetik'),
                trailing:
                    _sortType == 'alphabetical'
                        ? const Icon(Icons.check)
                        : null,
                onTap: () {
                  setState(() => _sortType = 'alphabetical');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesControllerProvider);
    final appUserAsync = ref.watch(appUserStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Sıralama ve Filtre',
            onPressed: _showSortSheet,
          ),
          IconButton(
            icon: Icon(_isWideView ? Icons.view_agenda : Icons.view_week),
            tooltip: 'Görünüm',
            onPressed: () {
              setState(() {
                _isWideView = !_isWideView;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: SizedBox(
              width: 220,
              child: SearchAnchor(
                searchController: _searchController,

                builder: (context, controller) {
                  return _searchBarIsNotOpen
                      ? IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: 'Ara',
                        onPressed: () {
                          setState(() {
                            _searchBarIsNotOpen = !_searchBarIsNotOpen;
                          });
                        },
                      )
                      : SearchBar(
                        controller: controller,
                        hintText: 'Notlarda ara...',
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        trailing: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            ),
                        ],
                      );
                },
                suggestionsBuilder: (context, controller) => const [],
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: appUserAsync.when(
            data: (user) {
              final displayName =
                  user?.displayName ?? user?.email ?? 'Kullanıcı';
              final initials = displayName[0];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (user?.email != null)
                                Text(
                                  user!.email!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Çıkış Yap'),
                    onTap: () async {
                      await ref.read(authControllerProvider.notifier).signOut();
                    },
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Hata: $e')),
          ),
        ),
      ),
      body: notesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (notes) {
          var noteList = notes as List<Note>? ?? [];
          if (_searchQuery.isNotEmpty && _searchQuery.length >= 3) {
            noteList =
                noteList.where((note) {
                  final query = _searchQuery.toLowerCase();
                  return note.title.toLowerCase().contains(query) ||
                      note.content.toLowerCase().contains(query);
                }).toList();
          }
          if (_sortType == 'modified') {
            noteList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          } else if (_sortType == 'created') {
            noteList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          } else if (_sortType == 'alphabetical') {
            noteList.sort(
              (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
            );
          }
          if (noteList.isEmpty) {
            return const Center(child: Text('Henüz not yok.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: () {
                final axisCount = switch (Responsive.screenSize(context)) {
                  ScreenSize.xs => 1,
                  ScreenSize.sm => 2,
                  ScreenSize.md => 3,
                  ScreenSize.lg => 4,
                  ScreenSize.xl => 5,
                };
                return _isWideView ? axisCount : axisCount + 1;
              }(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: _isWideView ? 2.5 : 1.0,
            ),
            itemCount: noteList.length,
            itemBuilder: (context, index) {
              final note = noteList[index];
              return Card(
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    ref
                        .read(appRouteNotifierProvider.notifier)
                        .goToNoteEdit(noteId: note.id);
                  },
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert),

                                  onPressed: () {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      builder:
                                          (context) => AppBottomSheet(
                                            title: 'Menü',
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.share,
                                                  ),
                                                  title: const Text('Paylaş'),
                                                  onTap: () {
                                                    // Paylaşma işlemi
                                                    Navigator.pop(context);
                                                    // Burada paylaşım fonksiyonu çağrılabilir
                                                  },
                                                ),
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  title: const Text('Sil'),
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                    await ref
                                                        .read(
                                                          notesControllerProvider
                                                              .notifier,
                                                        )
                                                        .deleteNote(note.id!);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child:
                                  _isWideView
                                      ? Text(
                                        _getFirstLines(note.content, 4),
                                        style: const TextStyle(fontSize: 14),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                      : Text(
                                        _getFirstLines(note.content, 10),
                                        style: const TextStyle(fontSize: 14),
                                        maxLines: 10,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${note.createdAt.day}.${note.createdAt.month}.${note.createdAt.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(appRouteNotifierProvider.notifier).goToNoteEdit();
        },
        tooltip: 'Yeni Not Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Yardımcı fonksiyon: İçeriğin ilk N satırını döndürür
  String _getFirstLines(String text, int lineCount) {
    final lines = text.split('\n');
    if (lines.length <= lineCount) return text;
    return '${lines.take(lineCount).join('\n')}...';
  }
}
