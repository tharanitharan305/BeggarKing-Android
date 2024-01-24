import 'package:beggarking/Widgets/AlertBox.dart';
import 'package:beggarking/Widgets/Sizedbox.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  State<AuthScreen> createState() {
    return _AuthScreen();
  }
}

class _AuthScreen extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  var _isAuthenticating = false;
  var _username;
  var _email;
  var _password;
  var _isLogin = true;
  void onSubmit() async {
    var _isvalid = formKey.currentState!.validate();
    if (!_isvalid) {
      return;
    }
    formKey.currentState!.save();
    setState(() {
      _isAuthenticating = true;
    });
    try {
      if (_isLogin) {
        final UserCretinal = await _firebase.signInWithEmailAndPassword(
            email: _email, password: _password);
      } else {
        final UserCretinal = await _firebase.createUserWithEmailAndPassword(
            email: _email, password: _password);
      }
    } on FirebaseException catch (error) {
      showDialog(
          context: context,
          builder: (BuildContext) {
            return AlertBox(
                b2: '',
                title: 'Auth Error',
                b1: 'ok',
                content: error.message ?? 'Authentication failed..');
          });
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  Widget build(context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color.fromRGBO(252, 186, 3, 255), Colors.black])),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Image.asset('images/logo.png'),
              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 10,
                  child: Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          if (!_isLogin)
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Username'),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length < 5) {
                                  return 'Username must containd 5 characters';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _username = value;
                              },
                            ),
                          getSizedBox(height: 10, widht: 0),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Email'),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _email = value;
                            },
                          ),
                          getSizedBox(height: 10, widht: 0),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.length < 5) {
                                return 'Password must containd 5 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _password = value;
                            },
                          ),
                          getSizedBox(height: 10, widht: 0),
                          if (_isAuthenticating) CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: onSubmit,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  elevation: 10),
                              child: Text(_isLogin ? 'LOGIN' : 'SIGN UP'),
                            ),
                          getSizedBox(height: 10, widht: 0),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(!_isLogin
                                  ? 'I already have an account'
                                  : 'Create an account'))
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
