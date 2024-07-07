import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      await FirebaseFirestore.instance
          .collection("Users")
          .where("Email", isEqualTo: _emailController.text.trim())
          .get()
          .then((res) {
        if (res.size == 0) {
          throw FirebaseAuthException(
              code: "Email Invalid!",
              message: "There's no user with this email.");
        }
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text(
              "Password reset link sent!\nCheck your email",
              style: TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.grey[800],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
              e.message.toString(),
              style: const TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.grey[800],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white54),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.deepPurple.shade400,
              Colors.purple.shade400,
            ])),
          ),
          backgroundColor: Colors.grey[800],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (Rect bounds) => LinearGradient(
                    stops: [0, 1],
                    colors: [
                      Colors.purple.shade300,
                      Colors.deepPurple.shade400,
                    ],
                  ).createShader(bounds),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.deepPurple[400],
                    size: 96,
                  ),
                ),
                const Text(
                  'Password Reset',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                      color: Colors.white70),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Type your email, and we\'ll send you a link!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: Colors.white38),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[800],
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12.0)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.white38)),
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.deepPurple.shade400,
                        Colors.purple.shade300,
                      ]),
                      borderRadius: BorderRadius.circular(12.0)),
                  child: GestureDetector(
                    onTap: passReset,
                    child: const Text(
                      "Send Link",
                      style: TextStyle(color: Colors.white54),
                    ),
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
