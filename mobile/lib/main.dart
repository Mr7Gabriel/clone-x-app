import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'auth_page.dart';
import 'user_provider.dart';
import 'api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        title: 'X Clone',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
        ),
        darkTheme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            // Check login status when app starts
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!userProvider.isLoggedIn) {
                userProvider.checkLoginStatus();
              }
            });
            
            return const AuthPage();
          },
        ),
      ),
    );
  }
}