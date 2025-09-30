import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'settings_page.dart';
import 'home_page.dart';
import 'theme_controller.dart';
import 'notifications_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadTheme();
  // Initialize notifications and Firebase
  await NotificationsService.instance.init();

  // For debugging: print FCM token
  try {
    final token = await FirebaseMessaging.instance.getToken();
    // ignore: avoid_print
    print('FCM token: $token');
  } catch (e) {
    // ignore: avoid_print
    print('Failed to get FCM token: $e');
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF2563EB),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF8B0B0B),
            scaffoldBackgroundColor: const Color(0xFF0B0B0B),
            cardColor: const Color(0xFF121212),
            dividerColor: Colors.grey.shade800,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: Colors.white)),
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF2563EB),
              onPrimary: Colors.white,
              secondary: const Color(0xFFED135C),
              surface: const Color(0xFF121212),
              onSurface: Colors.white70,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB))),
          ),
          themeMode: mode,
          routes: {
            '/': (c) => const LoginPage(),
            '/settings': (c) => const SettingsPage(),
            '/home': (c) => const HomePage(),
          },
          initialRoute: '/',
        );
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscure = true;
  bool _remember = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.bodyMedium?.color ?? const Color(0xFF6B7280);
    final hintColor = theme.textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF);
    final borderColor = theme.dividerColor;
    final actionBlue = theme.colorScheme.primary;
    final topSpacing = media.height * 0.08;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: topSpacing),
              Stack(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/logo.svg',
                      width: 160,
                      height: 44,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Text('E-mail', style: TextStyle(fontWeight: FontWeight.w600, color: labelColor)),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Informe seu e-mail',
                  hintStyle: TextStyle(color: hintColor),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: actionBlue, width: 1.5),
                  ),
                ),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),
              Text('Senha', style: TextStyle(fontWeight: FontWeight.w600, color: labelColor)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Informe sua senha',
                      hintStyle: TextStyle(color: hintColor),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: actionBlue, width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: hintColor),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _remember = !_remember),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                        color: _remember ? actionBlue : Colors.transparent,
                      ),
                      child: _remember
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                      const SizedBox(width: 10),
                      Text('Lembre-me', style: TextStyle(color: labelColor)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                    child: Text('Esqueceu a senha?', style: const TextStyle(decoration: TextDecoration.underline, color: Color(0xFF2563EB))),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_loading) return;
                    setState(() => _loading = true);
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final email = _emailController.text.trim();
                    final password = _passwordController.text;
                    final result = await ApiService.loginAluno(email, password);
                    if (result.containsKey('token')) {
                      final token = result['token'] as String;
                      await ApiService.saveToken(token);
                      final fcm = await FirebaseMessaging.instance.getToken();
                      if (fcm != null) await ApiService.registerFcm(token, fcm);
                      if (!mounted) return;
                      navigator.pushReplacementNamed('/home');
                    } else {
                      if (!mounted) return;
                      final err = result['error'] ?? 'Falha ao autenticar.';
                      messenger.showSnackBar(SnackBar(content: Text(err.toString())));
                    }
                    setState(() => _loading = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Entrar', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
