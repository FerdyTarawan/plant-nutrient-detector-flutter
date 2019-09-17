import 'package:flutter/material.dart';
import 'authentication.dart';

enum FormType { Login, Register }

class LoginPage extends StatefulWidget {

  final Auth auth;
  final VoidCallback onLogin;

  LoginPage({this.auth, this.onLogin}); 


  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FormType _formType = FormType.Login;
  final formKey = new GlobalKey<FormState>();
  String _email, _password;

  List<Widget> _buildButtons() {
    if (_formType == FormType.Login) {
      return [
        RaisedButton(
          child: Text(
            "Login",
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          color: Colors.lightGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          padding: EdgeInsets.all(10.0),
          onPressed: () async {
            // login code here
            final form = formKey.currentState;
            String userID = "";
            if(form.validate()){
              form.save();
              print("Data is valid $_email $_password");
              userID = await widget.auth.login(_email, _password);
              print("Signed in : $userID");

              if(userID.length > 0 && userID != null){
                widget.onLogin();
              }

            }else{
              print("Data is invalid");
            }
          },
        ),
        Padding(padding: EdgeInsets.only(bottom: 20.0)),
        FlatButton(
          child: Text(
            "Create new account",
            style: TextStyle(fontSize: 18.0),
          ),
          onPressed: () {
            setState(() {
             _formType = FormType.Register; 
            });
          },
        ),
      ];
    } else {
      return [
        RaisedButton(
          child: Text(
            "Sign Up",
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          color: Colors.lightGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          padding: EdgeInsets.all(10.0),
          onPressed: () async {
            // register code here
            final form = formKey.currentState;
            String userID = "";
            if(form.validate()){
              form.save();
              print("Data is valid");
              userID = await widget.auth.register(_email, _password);
              print("Signed up user : $userID");

              if(userID.length > 0 && userID != null){
                setState(() {
                 _formType = FormType.Login; 
                });
              }
            }else{
              print("Data is invalid");
            }
          },
        ),
        Padding(padding: EdgeInsets.only(bottom: 20.0)),
        FlatButton(
          child: Text(
            "Have an account? Login",
            style: TextStyle(fontSize: 18.0),
          ),
          onPressed: () {
            setState(() {
             _formType = FormType.Login; 
            });
          },
        ),
      ];
    }
  }

  Widget _getForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(bottom: 30.0)),
          TextFormField(
            decoration: InputDecoration(
              hintText: "Email",
              icon: Icon(
                Icons.mail,
                color: Colors.lightGreen,
              ),
            ),
            validator: (value) => value.isEmpty ? "Email cant be empty" : null,
            onSaved: (value) => _email = value.trim(),
          ),
          Padding(padding: EdgeInsets.only(bottom: 10.0)),
          TextFormField(
            decoration: InputDecoration(
                hintText: "Password",
                icon: Icon(
                  Icons.lock,
                  color: Colors.lightGreen,
                )),
            obscureText: true,
            validator: (value) => value.isEmpty ? "Password cant be empty" : null,
            onSaved: (value) => _password = value.trim(),
          ),
          Padding(padding: EdgeInsets.only(bottom: 30.0)),
        ] + _buildButtons()
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Plant Health"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(20.0),
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      "assets/images/leaf.png",
                      width: 150,
                      height: 150,
                    ),
                    _getForm()
                  ],
                ))));
  }
}
