import 'package:flutter/material.dart';

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // backgroundColor: const Color.fromARGB(255, 201, 201, 201),
      backgroundColor: Colors.deepPurple,
      content: Text(
        content,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
