import 'package:desktop_anywhere/modules/WelcomePage/WelcomePage.dart';
import 'package:desktop_anywhere/shared/cubit/cubit.dart';
import 'package:desktop_anywhere/shared/cubit/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:
    const FirebaseOptions(
      apiKey: "AIzaSyAVjZjh4_Bn6pyRzLKTO23Pw5HT8FqTQOQ",
      authDomain: "desktopanywhere-7ea4c.firebaseapp.com",
      projectId: "desktopanywhere-7ea4c",
      storageBucket: "desktopanywhere-7ea4c.appspot.com",
      messagingSenderId: "1095289543550",
      appId: "1:1095289543550:web:cc2f4a5e34078f3e25712f",
    )
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..updateInputData(context: context),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WelcomePage(),
      ),
    );
  }
}

