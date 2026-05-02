import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/layout_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const BoxyApp());
}

class BoxyApp extends StatelessWidget {
  const BoxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LayoutProvider())],
      child: MaterialApp(
        title: 'Boxy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.black, // Monochrome Black
          scaffoldBackgroundColor: Colors.white, // Pure White
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            surface: Colors.white, // Pure White Surface
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
