import 'app_route_enum.dart';

class AppRoutePath {
  final AppRoute route;
  final String? noteId;

  const AppRoutePath._(this.route, {this.noteId});

  const AppRoutePath.notesList() : this._(AppRoute.notesList);
  const AppRoutePath.noteEdit({String? noteId})
    : this._(AppRoute.noteEdit, noteId: noteId);
  const AppRoutePath.unknown() : this._(AppRoute.unknown);

  bool get isNotesList => route == AppRoute.notesList;
  bool get isNoteEdit => route == AppRoute.noteEdit;
  bool get isUnknown => route == AppRoute.unknown;
}
