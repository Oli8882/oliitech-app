import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ─── Config ───────────────────────────────────────────────────
const kBaseUrl   = "https://oliitech.com";
const kAppName   = "oliitech";
const kPrimary   = Color(0xFF0A0A0A);
const kAccent    = Color(0xFF00C853);
const kBg        = Color(0xFF111111);
const kNavBg     = Color(0xFF1A1A1A);
const kNavActive = Color(0xFF00C853);
const kNavInact  = Color(0xFF666666);

// ─── Notification Plugin ──────────────────────────────────────
final FlutterLocalNotificationsPlugin _notifPlugin =
    FlutterLocalNotificationsPlugin();

// ─── Background message handler (top-level) ───────────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage msg) async {
  await Firebase.initializeApp();
}

// ─── Nav Items ────────────────────────────────────────────────
class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String url;
  const NavItem({
    required this.label, required this.icon,
    required this.activeIcon, required this.url,
  });
}

const kNavItems = [
  NavItem(label: "Home",     icon: Icons.home_outlined,        activeIcon: Icons.home,           url: kBaseUrl),
  NavItem(label: "Articles", icon: Icons.article_outlined,     activeIcon: Icons.article,        url: "$kBaseUrl/articles"),
  NavItem(label: "Projects", icon: Icons.code_outlined,        activeIcon: Icons.code,           url: "$kBaseUrl/projects"),
  NavItem(label: "About",    icon: Icons.info_outline_rounded, activeIcon: Icons.info_rounded,   url: "$kBaseUrl/about"),
];

// ══════════════════════════════════════════════════════════════
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Firebase init
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Local notifications init
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios     = DarwinInitializationSettings();
  await _notifPlugin.initialize(
    const InitializationSettings(android: android, iOS: ios),
  );

  runApp(const OliitechApp());
}

// ══════════════════════════════════════════════════════════════
class OliitechApp extends StatelessWidget {
  const OliitechApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(primary: kAccent),
        scaffoldBackgroundColor: kBg,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SPLASH SCREEN
// ══════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo container
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    color: kNavBg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: kAccent.withOpacity(0.4), width: 2),
                    boxShadow: [
                      BoxShadow(color: kAccent.withOpacity(0.2),
                        blurRadius: 32, spreadRadius: 4),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text("O",
                          style: GoogleFonts.poppins(
                            color: kAccent, fontSize: 52,
                            fontWeight: FontWeight.w900,
                          )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(kAppName,
                  style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 32,
                    fontWeight: FontWeight.w800, letterSpacing: 1,
                  )),
                const SizedBox(height: 6),
                Text("Tech. Code. Africa.",
                  style: GoogleFonts.poppins(
                    color: kAccent, fontSize: 13,
                  )),
                const SizedBox(height: 48),
                SizedBox(
                  width: 28, height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: kAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  MAIN SCREEN
// ══════════════════════════════════════════════════════════════
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int     _navIndex    = 0;
  bool    _isOffline   = false;
  bool    _isLoading   = true;
  String  _currentUrl  = kBaseUrl;

  late WebViewController _webCtrl;
  late StreamSubscription _connSub;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _initConnectivity();
    _initNotifications();
  }

  // ── WebView ───────────────────────────────────────────────
  void _initWebView() {
    _webCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(kBg)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() { _isLoading = true; }),
        onPageFinished: (url) {
          setState(() {
            _isLoading  = false;
            _currentUrl = url;
          });
        },
        onWebResourceError: (_) => setState(() { _isOffline = true; }),
      ))
      ..loadRequest(Uri.parse(kBaseUrl));
  }

  // ── Connectivity ──────────────────────────────────────────
  void _initConnectivity() {
    _connSub = Connectivity().onConnectivityChanged.listen((result) {
      final online = result != ConnectivityResult.none;
      if (online && _isOffline) {
        setState(() { _isOffline = false; });
        _webCtrl.reload();
      }
      setState(() { _isOffline = !online; });
    });
  }

  // ── Push Notifications ────────────────────────────────────
  void _initNotifications() async {
    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance
        .subscribeToTopic('oliitech_updates');

    // Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      final notif = msg.notification;
      if (notif == null) return;
      _notifPlugin.show(
        notif.hashCode,
        notif.title,
        notif.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'oliitech_channel', 'Oliitech Updates',
            importance: Importance.high,
            priority: Priority.high,
            color: kAccent,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });

    // Notification tap → open app
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      final url = msg.data['url'] as String?;
      if (url != null) _webCtrl.loadRequest(Uri.parse(url));
    });
  }

  @override
  void dispose() {
    _connSub.cancel();
    super.dispose();
  }

  // ── Nav tap ───────────────────────────────────────────────
  void _onNavTap(int idx) {
    setState(() { _navIndex = idx; });
    _webCtrl.loadRequest(Uri.parse(kNavItems[idx].url));
  }

  // ── Share ─────────────────────────────────────────────────
  void _share() {
    Share.share(
      "Check out this article on oliitech! 🔥\n$_currentUrl",
      subject: "oliitech — Tech. Code. Africa.",
    );
  }

  // ── Pull to refresh ───────────────────────────────────────
  Future<void> _refresh() async {
    await _webCtrl.reload();
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _webCtrl.canGoBack()) {
          _webCtrl.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: kPrimary,
          elevation: 0,
          title: Text(kAppName,
            style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w800,
              fontSize: 20, letterSpacing: 0.5,
            )),
          actions: [
            // Share button
            IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              onPressed: _share,
            ),
            // Reload button
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () => _webCtrl.reload(),
            ),
          ],
        ),

        body: Stack(
          children: [
            // ── Offline screen ──────────────────────────────
            if (_isOffline)
              _buildOfflinePage()
            else
              // ── WebView + pull to refresh ─────────────────
              RefreshIndicator(
                color: kAccent,
                backgroundColor: kNavBg,
                onRefresh: _refresh,
                child: WebViewWidget(controller: _webCtrl),
              ),

            // ── Loading bar ──────────────────────────────────
            if (_isLoading && !_isOffline)
              Positioned(
                top: 0, left: 0, right: 0,
                child: LinearProgressIndicator(
                  color: kAccent,
                  backgroundColor: kNavBg,
                  minHeight: 3,
                ),
              ),
          ],
        ),

        // ── Bottom Navigation Bar ─────────────────────────
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: kNavBg,
            border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
            boxShadow: [
              BoxShadow(color: Colors.black45, blurRadius: 12, offset: const Offset(0, -2)),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(kNavItems.length, (i) {
                  final item   = kNavItems[i];
                  final active = i == _navIndex;
                  return GestureDetector(
                    onTap: () => _onNavTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? kAccent.withOpacity(0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(active ? item.activeIcon : item.icon,
                            color: active ? kNavActive : kNavInact, size: 22),
                          const SizedBox(height: 3),
                          Text(item.label,
                            style: GoogleFonts.poppins(
                              color: active ? kNavActive : kNavInact,
                              fontSize: 10,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                            )),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Offline Page ─────────────────────────────────────────
  Widget _buildOfflinePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: kNavBg, shape: BoxShape.circle,
                border: Border.all(color: Colors.red.shade800, width: 2),
              ),
              child: Icon(Icons.wifi_off_rounded,
                color: Colors.red.shade400, size: 40),
            ),
            const SizedBox(height: 24),
            Text("No Internet Connection",
              style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700,
              )),
            const SizedBox(height: 10),
            Text(
              "Looks like you're offline.\nCheck your connection and try again.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Connectivity().checkConnectivity();
                if (result != ConnectivityResult.none) {
                  setState(() { _isOffline = false; });
                  _webCtrl.reload();
                }
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text("Try Again", style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
