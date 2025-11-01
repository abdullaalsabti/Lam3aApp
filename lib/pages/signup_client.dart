import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/theme/widgets/button.dart';

class SignupClient extends StatefulWidget {
  const SignupClient({super.key});

  @override
  State<SignupClient> createState() => _LoginClient();
}

class _LoginClient extends State<SignupClient> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'lib/assets/images/lam3a-logo-login.png',
                  fit: BoxFit.contain,
                  colorBlendMode: BlendMode.modulate,
                  color: Colors.white.withAlpha(100),
                ),
              ),
              SizedBox(height: 25),
              SafeArea(
                child: SizedBox(
                  width: 400,
                  height: 500,
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                        SizedBox(height: 15),

                        TextFormField(
                          focusNode: _focusNode,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            suffixIcon: _focusNode.hasFocus
                                ? IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            )
                                : null,
                            border: InputBorder.none,
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                        SizedBox(height: 20),
                        Button(btnText: 'Sign Up'),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey, thickness: 1),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('OR'),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey, thickness: 1),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            side: BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'lib/assets/images/google.png',
                                width: 50,
                              ),
                              SizedBox(width: 30),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sign Up with Google',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(fontSize: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 18),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/login_page');
                              },
                              child: Text(
                                'Log In',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}