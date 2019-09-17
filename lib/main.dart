import 'package:flutter/material.dart';
import 'login.dart';
import 'detect.dart';
import 'authentication.dart';

void main() => runApp(MyApp());

enum AuthStatus {
  LOGGED_IN,
  NOT_LOGGED_IN,
  UNKNOWN,
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        primaryTextTheme: TextTheme(
            title: TextStyle(
          color: Colors.white,
        )),
        fontFamily: "OpenSans",
      ),
      home: RootPage(
        auth: Auth(),
      ),
    );
  }
}

class RootPage extends StatefulWidget {
  final Auth auth;

  RootPage({this.auth});

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.UNKNOWN;
  String _userID = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          if (user?.uid != null) {
            _userID = user?.uid;
            authStatus = AuthStatus.LOGGED_IN;
          } else {
            authStatus = AuthStatus.NOT_LOGGED_IN;
          }
        } else {
          authStatus = AuthStatus.NOT_LOGGED_IN;
        }
      });
    });
  }

  void _onLogin() {
    setState(() {
      authStatus = AuthStatus.UNKNOWN;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.auth.getCurrentUser().then((user) {
        setState(() {
          _userID = user.uid;
          authStatus = AuthStatus.LOGGED_IN;
        });
      });
    });
  }

  void _onLogout() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
    });
  }

  Widget showLoadingScreen() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.LOGGED_IN:
        return DetectPage(
          auth: widget.auth,
          onLogout: _onLogout,
        );
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return LoginPage(
          auth: widget.auth,
          onLogin: _onLogin,
        );
        break;
      case AuthStatus.UNKNOWN:
        return showLoadingScreen();
        break;
      default:
        return showLoadingScreen();
    }
  }
}
