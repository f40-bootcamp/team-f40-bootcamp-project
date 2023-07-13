import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'feed_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginPage extends StatefulWidget {
  final String email;
  final String password;

  LoginPage({String? email, String? password})
      : email = email ?? '',
        password = password ?? '';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //final TextEditingController _emailController = TextEditingController();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController(text: widget.password);
  }

  //final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool error = false;
  bool _passwordVisible = false;

  Future<void> _login() async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FeedPage()),
        );
      }
    } catch (e) {
      setState(() {
        error = true;
        _errorMessage =
            'Giriş yaparken bir hata oluştu. E-postanızı veya şifrenizi kontrol ediniz!';
      });
      print(_errorMessage);
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RegisterPage(
                userName: '',
                email: '',
              )),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FeedPage()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google ile oturum açarken bir hata oluştu.';
      });
      print(_errorMessage);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 600,
          height: 1400,
          padding: EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color.fromRGBO(223, 244, 243, 1),
                Color.fromRGBO(218, 228, 238, 1),
                Color.fromRGBO(185, 187, 223, 1),
              ],
              radius: 1.65,
              center: Alignment.topLeft,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 70),
                Text(
                  'Giriş Yap',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    color: Color.fromRGBO(135, 142, 205, 1),
                  ),
                ),
                Image.asset(
                  'lib/assets/aPngtreeahand_drawn_cute_cat_reading_4361091.png',
                  width: 280,
                  height: 180,
                ),
                Container(
                  height: 68,
                  width: 320,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0.0,
                        blurRadius: 1.0,
                        offset: Offset(0, 3), // horizontal, vertical offset
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      labelStyle:
                          TextStyle(color: Color.fromRGBO(170, 170, 170, 1)),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                Container(
                  height: 68,
                  width: 320,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0.0,
                        blurRadius: 1.0,
                        offset: Offset(0, 3),
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      labelStyle: const TextStyle(
                          color: Color.fromRGBO(170, 170, 170, 1)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 30),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                if (error)
                  Flexible(
                    child: Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.circleExclamation,
                          size: 15.0,
                          color: Color(0xFF878ECD),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Color.fromRGBO(135, 142, 205, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromRGBO(135, 142, 205, 1)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 40.0),
                    ),
                    textStyle: MaterialStateProperty.all(
                      const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(51.16),
                      ),
                    ),
                  ),
                  onPressed: _login,
                  child: const Text('Giriş Yap'),
                ),
                SizedBox(height: 8.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgotPasswordPage()),
                    );
                  },
                  child: Text(
                    'Şifremi Unuttum',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromRGBO(135, 142, 205, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                    ),
                    textStyle: MaterialStateProperty.all(
                      TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.16),
                      ),
                    ),
                  ),
                  onPressed: _signInWithGoogle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.google,
                        size: 18.0,
                      ),
                      SizedBox(width: 10.0),
                      Text('Google ile Giriş Yap'),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hesabın yok mu? Hemen',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: _goToRegister,
                      child: Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          color: Color.fromRGBO(135, 142, 205, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
