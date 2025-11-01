import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Password extends StatefulWidget{
  const Password({super.key});

  @override
  State<Password> createState() => _Password();
}

class _Password extends State<Password>{

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: true,


    );
  }
}