import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_note/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appInitializerProvider = FutureProvider<void>((ref) async {
  // Firebase'i başlat
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // SharedPreferences'ı başlat
  await ref.read(sharedPreferencesProvider.future);

  // Gerekirse başka bağımlılıklar da eklenebilir
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return SharedPreferences.getInstance();
});
