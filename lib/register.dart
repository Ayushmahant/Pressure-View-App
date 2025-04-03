import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginscreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? phoneError;
  bool isLoading = false;

  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (phoneController.text.length != 10) {
        setState(() {
          phoneError = "Phone number must be 10 digits";
          isLoading = false;
        });
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "uid": userCredential.user!.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful! Redirecting to login...")),
      );

      // Redirect to Login Page after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Registration failed")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            width: double.infinity,
            child: Column(
              children: [
                // Top image section
                Container(
                  height: size.height * 0.1,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/check.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                // Form Section
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        Text("Register Yourself", style: GoogleFonts.bebasNeue(fontSize: 32)),
                        const SizedBox(height: 20),
                        RoundedInputField(controller: nameController, hintText: "Name", icon: CupertinoIcons.person),
                        RoundedInputField(controller: emailController, hintText: "Email", icon: CupertinoIcons.mail),
                        RoundedPasswordField(controller: passwordController),
                        PhoneNumberInputField(
                          controller: phoneController,
                          errorText: phoneError,
                          onChanged: (value) {
                            setState(() {
                              phoneError = value.length == 10 ? null : "Phone number must be 10 digits";
                            });
                          },
                        ),
                        isLoading
                            ? const CircularProgressIndicator()
                            : RoundedButton(text: "REGISTER", press: registerUser),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage())),
                          child: const Text("Already have an account? Login here",
                              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                        ),
                        const SizedBox(height: 30),
                      ],
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

class RoundedInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;

  const RoundedInputField({Key? key, required this.controller, required this.hintText, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class RoundedPasswordField extends StatelessWidget {
  final TextEditingController controller;

  const RoundedPasswordField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(CupertinoIcons.lock_fill, color: Colors.blue),
          hintText: "Password",
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback press;

  const RoundedButton({Key? key, required this.text, required this.press}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: press,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}


class PhoneNumberInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const PhoneNumberInputField({
    Key? key,
    required this.controller,
    this.errorText,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: const Icon(CupertinoIcons.phone, color: Colors.blue),
          hintText: "Phone Number",
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          errorText: errorText,
        ),
      ),
    );
  }
}