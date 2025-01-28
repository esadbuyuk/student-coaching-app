import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/ui_controller.dart';
import '../../controller/user_controller.dart';
import '../../model/my_constants.dart';
import '../widgets/brand_name.dart';
import '../widgets/slogan.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserController userController = UserController();

  @override
  void initState() {
    // UserController userController = UserController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SizedBox(
          width: isMobile(context) ? null : 600,
          child: Padding(
            padding: isMobile(context)
                ? const EdgeInsets.all(5)
                : const EdgeInsets.all(50),
            child: Card(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 50, end: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40, child: FittedBox(child: BrandName())),
                    SizedBox(height: 5.h),
                    SizedBox(height: 20, child: FittedBox(child: Slogan())),
                    SizedBox(height: 90.h),
                    Container(
                      // Email TextField
                      // width: 256,
                      height: 32.h > 30 ? 32.h : 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.only(
                          topEnd: Radius.circular(30.r),
                          topStart: Radius.circular(30.r),
                        ),
                        color: myPrimaryColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 30, end: 30),
                        child: TextField(
                          controller: _usernameController,
                          cursorColor: myAccentColor,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 13),
                            filled: true,
                            fillColor: myPrimaryColor,
                            prefixIcon:
                                const Icon(Icons.person, color: myIconsColor),
                            hintText: 'Username',
                            hintStyle:
                                myThinStyle(color: myIconsColor, fontSize: 14),
                            focusColor: myAccentColor,
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: myAccentColor,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      // Password TextField
                      // width: 256,
                      height: 32.h > 30 ? 32.h : 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.only(
                          bottomEnd: Radius.circular(30.r),
                          bottomStart: Radius.circular(30.r),
                        ),
                        color: myPrimaryColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 30, end: 30),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          cursorColor: myAccentColor,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 13),
                            border: const UnderlineInputBorder(
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: myPrimaryColor,
                            prefixIcon:
                                const Icon(Icons.key, color: myIconsColor),
                            hintText: 'Password',
                            hintStyle:
                                myThinStyle(color: myIconsColor, fontSize: 14),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: myAccentColor,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    LogInButton(
                        userController: userController,
                        usernameController: _usernameController,
                        passwordController: _passwordController),
                    SizedBox(height: 40.h),
                    const FittedBox(child: SignUpText()),
                    SizedBox(height: 25.h),
                    GestureDetector(
                      onTap: () {
                        // Aydınlatma metnini aç
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("KVKK Metni"),
                              content: const SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      kvkk,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Diyaloğu kapat
                                  },
                                  child: const Text("Okudum, Anladım"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0, right: 0.0),
                        child: SizedBox(
                          height: 15.h,
                          width: 265,
                          child: FittedBox(
                            child: RichText(
                              text: TextSpan(
                                text: 'Devam etmeniz halinde ',
                                style: myThinStyle(
                                    color: myIconsColor, fontSize: 10),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'KVKK Metnini ',
                                    style: myThinStyle(
                                        color: myAccentColor, fontSize: 10),
                                  ),
                                  TextSpan(
                                    text: 'okumuş olduğunuz kabul edilecektir.',
                                    style: myThinStyle(
                                        color: myIconsColor, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LogInButton extends StatelessWidget {
  const LogInButton({
    Key? key,
    required this.userController,
    required TextEditingController usernameController,
    required TextEditingController passwordController,
  })  : _usernameController = usernameController,
        _passwordController = passwordController,
        super(key: key);

  final UserController userController;
  final TextEditingController _usernameController;
  final TextEditingController _passwordController;

  Future<void> _fixedNavigation(BuildContext context) async {
    // Store the current navigator to avoid using context after async
    final navigator = Navigator.of(context);

    if (!isKeyboardOpen(context)) {
      context.go('/home');
    } else {
      // Unfocus the keyboard or any focused input field
      FocusScope.of(context).unfocus();

      // Delay for 3 seconds
      await Future.delayed(const Duration(milliseconds: 300));

      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: 64.h > 60 ? 64.h : 60,
      child: ElevatedButton(
        onPressed: () async {
          FocusScope.of(context).unfocus();

          final result = await userController.logIn(
              _usernameController.text, _passwordController.text);

          if (result == true) {
            if (!context.mounted) return;
            _showWebErrorOverlay(
              context,
              'Logged in.',
              color: Colors.green,
            );
            await _fixedNavigation(context);
          } else if (result == null) {
            // _showErrorSnackBar(
            //   context,
            //   'Connect to Internet.',
            // );
          } else {
            if (!context.mounted) return;
            _showWebErrorOverlay(context, 'Invalid username or password.',
                color: Colors.red);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          backgroundColor: myAccentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0.r),
          ),
        ),
        child: const Text(
          'Log In',
          style: TextStyle(
              fontSize: 45,
              color: myIconsColor,
              fontFamily: 'MyTonicFont',
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

enum LaunchModeType {
  inAppBrowserOptions,
  inBrowser,
  inBrowserView,
  inWebView,
}

class SignUpText extends StatelessWidget {
  const SignUpText({
    Key? key,
  }) : super(key: key);

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://www.personalcoachapp.me/login.php');
    if (await canLaunchUrl(url)) {
      _launchURLWithMode();
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchURLWithMode() async {
    final Uri url = Uri.parse('https://www.personalcoachapp.me/login.php');
    int currentModeIndex = 0;
    const List<LaunchModeType> modes = LaunchModeType.values;
    final mode = modes[currentModeIndex];

    if (await canLaunchUrl(url)) {
      switch (mode) {
        case LaunchModeType.inAppBrowserOptions:
          await _launchInAppWithBrowserOptions(url);
          break;
        case LaunchModeType.inBrowser:
          await _launchInBrowser(url);
          break;
        case LaunchModeType.inBrowserView:
          await _launchInBrowserView(url);
          break;
        case LaunchModeType.inWebView:
          await _launchInWebView(url);
          break;
      }
      // Modu sıradaki moda güncelle
      currentModeIndex = (currentModeIndex + 1) % modes.length;
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInWebView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInAppWithBrowserOptions(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppBrowserView,
      browserConfiguration: const BrowserConfiguration(showTitle: true),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showWebErrorOverlay(context, "Contact the product owner");
        _launchURL();
      },
      child: RichText(
        text: TextSpan(
          text: 'Not a member?  ',
          style: myThinStyle(color: myIconsColor, fontSize: 20),
          children: <TextSpan>[
            TextSpan(
              text: 'Sign up now', // düzeltilecek
              style: myThinStyle(color: myAccentColor, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

void _showWebErrorOverlay(BuildContext context, String warningText,
    {Color color = Colors.red}) {
  // Create an overlay entry
  final overlay = OverlayEntry(
    builder: (context) => Positioned(
      top: 20, // Position the overlay at the top of the screen
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            warningText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  // Insert the overlay into the context's Overlay
  final overlayState = Overlay.of(context);
  overlayState?.insert(overlay);

  // Remove the overlay after 3 seconds
  Future.delayed(const Duration(seconds: 3), () {
    overlay.remove();
  });
}
