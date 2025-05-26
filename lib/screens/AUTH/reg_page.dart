import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hermes_pro/screens/HOME/Slider_pages/profile_page.dart';


class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _fullName = '';  
  String _birthDate = ''; 
  String _inn = '';
  bool _obscureText = true; // Переменная состояния для управления видимостью пароля
  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "JOJOS.PRO",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tabs for Create Account and Log In
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Logic for "Create Account" tab
                            },
                            child: Text(
                              "Создать аккаунт",
                              style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/auth'); // Logic for "Log In" tab
                            },
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Создание Аккаунта",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Давайте начнем с заполнения формы ниже.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "ФИО",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.person),
                              ),
                              onSaved: (value) {
                                _fullName = value ?? '';
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введите ваше ФИО';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),

                            // Date of Birth field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Дата рождения",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              onSaved: (value) {
                                _birthDate = value ?? '';
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введите вашу дату рождения';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),

                            // INN field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "ИНН",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.business),
                              ),
                              onSaved: (value) {
                                _inn = value ?? '';
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введите ваш ИНН';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),

                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Email",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.email),
                              ),
                              onSaved: (value) {
                                _email = value ?? '';
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введите адрес вашей почты';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'Введите корректную электронную почту';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              obscureText: _obscureText, // Используем _obscureText
                              decoration: InputDecoration(
                                labelText: "Password",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                              onSaved: (value) {
                                _password = value ?? '';
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введите пароль';
                                }
                                if (value.length < 6) {
                                  return 'Пароль должен быть не менее 6 символов';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                padding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 80,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Зарегистрироваться",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 20),
                            Center(
                              child: Text(
                                "Зарегистрироваться с помощью",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _signInWithGoogle,
                                  icon: Icon(Icons.g_mobiledata),
                                  label: Text("Продолжить с Google"),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Logic for Apple sign up
                                  },
                                  icon: Icon(Icons.apple),
                                  label: Text("Продолжить с Apple"),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      // Создание экземпляра GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Аутентификация пользователя в Firebase
        UserCredential userCredential = await _auth.signInWithCredential(credential);

        // Успешная регистрация
        print('Пользователь вошел через Google: ${userCredential.user?.email}');
        Navigator.pushReplacementNamed(context, '/home'); // Перенаправление на главную страницу
      }
    } catch (e) {
      // Обработка ошибок
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
        ),
      );
    }
  }


void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    try {
      // Register the user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);

      // Successful registration
      print('User registered: ${userCredential.user?.email}');
      // Navigate to the home page or another page
      Navigator.pushReplacementNamed(context, '/auth');

      // Переход на страницу профиля с переданными данными
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Handle errors here
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Этот адрес электронной почты уже используется.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Пароль слишком слабый.';
      } else {
        errorMessage = 'Произошла ошибка: ${e.message}';
      }
      // Show the error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ОК'),
            ),
          ],
        ),
      );
    }
  }
}
Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Отправка подтверждающего письма
        User? user = userCredential.user;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Письмо с подтверждением отправлено. Проверьте свою почту.',
              ),
            ),
          );
        }

        // Перенаправление на страницу входа
        Navigator.pushReplacementNamed(context, '/auth');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
          ),
        );
      }
    }
  }
}
