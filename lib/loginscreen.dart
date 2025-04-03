import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'register.dart';
import 'MajorPage.dart';
// Replace with your actual home screen

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      String input = _emailPhoneController.text.trim();
      String password = _passwordController.text.trim();

      UserCredential userCredential;

      if (input.contains('@')) {
        // Login with Email & Password
        userCredential = await _auth.signInWithEmailAndPassword(
          email: input,
          password: password,
        );

        // After successful login, navigate to the home page
        navigateToHomePage();
      } else {
        // Handle phone number authentication
        String phoneNumber = input.trim();

        // Append India country code (+91) if not present
        if (!phoneNumber.startsWith('+91')) {
          phoneNumber = '+91' + phoneNumber;
        }

        // Start the phone number authentication process with reCAPTCHA verification handled internally
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-retrieval of verification code completed (e.g., SMS code was auto-filled)
            await _auth.signInWithCredential(credential);
            navigateToHomePage();
          },
          verificationFailed: (FirebaseAuthException e) {
            showError(e.message ?? "Phone number verification failed");
          },
          codeSent: (String verificationId, int? resendToken) {
            // Handle when the code is sent to the user's phone
            _showSmsCodeDialog(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Handle timeout if needed
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Login failed");
    } catch (e) {
      showError("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to show the SMS code dialog or input screen
  Future<void> _showSmsCodeDialog(String verificationId) async {
    String smsCode = '';
    await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter the SMS Code"),
          content: TextField(
            onChanged: (value) {
              smsCode = value;
            },
            decoration: InputDecoration(hintText: 'Enter SMS Code'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Submit'),
              onPressed: () async {
                // Create the PhoneAuthCredential with the code entered by the user
                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: verificationId,
                  smsCode: smsCode,
                );

                // Sign the user in with the phone credential
                await _auth.signInWithCredential(credential);
                navigateToHomePage();
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MajorPage()), // Replace with actual home screen
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FadeInUp(
                duration: Duration(milliseconds: 1500),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontFamily: 'Bebas Neue',
                    color: Color.fromRGBO(49, 39, 79, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
              SizedBox(height: 50),
              FadeInUp(
                duration: Duration(milliseconds: 1000),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(
                      color: Color.fromRGBO(196, 135, 198, .3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(196, 135, 198, .3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color.fromRGBO(196, 135, 198, .3),
                            ),
                          ),
                        ),
                        child: TextField(
                          controller: _emailPhoneController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email or Phone Number",
                            hintStyle: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
              FadeInUp(
                duration: Duration(milliseconds: 1000),
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: Color.fromRGBO(196, 135, 198, 1)),
                  ),
                ),
              ),
              FadeInUp(
                duration: Duration(milliseconds: 1000),
                child: MaterialButton(
                  onPressed: loginUser,
                  color: Color.fromRGBO(49, 39, 79, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  height: 50,
                  minWidth: double.infinity,
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 30),
              FadeInUp(
                duration: Duration(milliseconds: 1000),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Create Account",
                    style: TextStyle(color: Color.fromRGBO(49, 39, 79, .6)),
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
