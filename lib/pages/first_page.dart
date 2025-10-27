import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:lamaa/theme/text_style.dart';
import 'package:lamaa/theme/widgets/role_button.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          child: Image.asset(
            'lib/assets/images/lam3a-logo2.png',
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
          onRole: () {},
          roleImagePath: 'lib/assets/images/car.png',
          roleTitle: 'Client',
          roleSubTitle: 'I want to book a car service',
        ),

        SizedBox(height: 30),

        RoleButton(
          onRole: () {},
          roleImagePath: 'lib/assets/images/construction-worker.png',
          roleTitle: 'Provider',
          roleSubTitle: 'I offer car wash or detailing service',
        ),
      ],
    );
  }
}
