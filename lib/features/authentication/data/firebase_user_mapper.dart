import 'package:firebase_auth/firebase_auth.dart';
import 'package:one_note/features/authentication/domain/app_user.dart';

extension FirebaseUserMapper on User {
  AppUser toAppUser() {
    return AppUser(id: uid, email: email, displayName: displayName);
  }
}
