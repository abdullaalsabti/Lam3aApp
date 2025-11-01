import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/theme/widgets/role_button.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPage();
}

class _FirstPage extends State<FirstPage> {

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
                  'lib/assets/images/lam3a-logo2.png',
                  fit: BoxFit.contain,
                  colorBlendMode: BlendMode.modulate,
                  color: Colors.white.withAlpha(100),
                ),
              ),
              SizedBox(height: 50),
              Text(
                'Who are you ?',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Please select your role to continue',
                style: GoogleFonts.poppins(fontSize: 20, color: Colors.grey),
              ),
              SizedBox(height: 20),

              RoleButton(
                roleImagePath: 'lib/assets/images/car.png',
                roleTitle: 'Client',
                roleSubTitle: 'I want to book a car service',
                onPressed: (){
                  Navigator.pushNamed(context, '/login_page');
                },
              ),

              SizedBox(height: 30),

              RoleButton(
                roleImagePath: 'lib/assets/images/construction-worker.png',
                roleTitle: 'Provider',
                roleSubTitle: 'I offer car wash or detailing service',
                onPressed: (){},
              ),

            ],),
        ),
      ),
    );
  }
}

