import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_motion/extras/data.dart';
import 'package:in_motion/extras/UI-extras.dart';
import 'package:in_motion/pages/home.dart';
import 'package:in_motion/pages/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //Variables
  bool showLogin = false, showRegister = false, isLoading = false;
  String userEmail, password;
  SharedPreferences prefs;
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode focusNodeUserEmail = FocusNode();
  final FocusNode focusNodePassword = FocusNode();

  //Login Form
  Widget loginForm(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: colors[4],
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),),
          ),
          child: Form(
            key: loginFormKey,
            child: Column(
              children: [
                //Form Title and close botton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),

                    //Title
                    Center(
                      child: Text("Login Details",
                          style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: colors[1], fontSize: 20, fontWeight: FontWeight.bold))
                      ),
                    ),

                    //Close icon
                    IconButton(
                      onPressed: (){
                        setState(() {
                          showLogin = false;
                        });
                      },
                      icon: Icon(Icons.close,
                        color: colors[1],
                        size: 24,
                      ),
                    )
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Divider(
                    color: colors[2],
                    thickness: 1.5,
                  ),
                ),
                //Email and password inputs
                Container(
                  child: Theme(
                    data: Theme.of(context).copyWith(primaryColor: colors[1]),
                    child: TextFormField(
                      cursorColor: colors[2],
                      style: TextStyle(
                          color: colors[2]
                      ),
                      decoration: InputDecoration(
                          focusColor: colors[1],
                          fillColor: colors[1],
                          labelText: "Username",
                          labelStyle: TextStyle(color: colors[1]),
                          hintText: 'example@company.com',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: colors[0]),
                          icon: Icon(Icons.email_outlined,
                              color: colors[1]
                          )
                      ),
                      controller: emailController,
                      validator: (value) {
                        if (!EmailValidator.validate(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        userEmail = value;
                      },
                      //focusNode: focusNodeUserEmail,
                    ),
                  ),
                ),

                Container(
                  child: Theme(
                    data: Theme.of(context).copyWith(primaryColor: colors[1]),
                    child: TextFormField(
                      style: TextStyle(
                          color: colors[1]
                      ),
                      decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: colors[1]),
                          hintText: '......',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: colors[0]),
                          icon: Icon(Icons.lock,
                            color: colors[1],
                          )
                      ),
                      //controller: _passwordController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Cannot be empty';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        password = value;
                      },
                      //focusNode: focusNodePassword,
                      obscureText: true,
                    ),
                  ),
                ),
                //Login Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    buttonUI(context, 'Login', colors[2], colors[1], (){
                      loginFormKey.currentState.validate()
                          ? onPressSignIN()
                          : Fluttertoast.showToast(msg: "Please fill in all the required info.");}
                          )
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  //Register Form
  Widget registerForm(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          child: Form(
            key: registerFormKey,
            child: Column(

            ),
          ),
        )
      ],
    );
  }
  //Log In using email and password function
  void onPressSignIN() async{
    prefs = await SharedPreferences.getInstance();
    focusNodePassword.unfocus();
    focusNodeUserEmail.unfocus();
    setState(() {
      isLoading = true;
    });
    // Check is already sign up
    final QuerySnapshot result =
    await Firestore.instance.collection('users')
        .where('email', isEqualTo: userEmail).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0) {
      this.setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "You are not registered, please select Sign Up");
    } else{
      if(documents[0]['password'] == password || isEmpty(documents[0]['password'])) {
        this.setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "Sign in successful");
        //Write User Details to local storage
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('firstName', documents[0]['firstName']);
        await prefs.setString('lastName', documents[0]['lastName']);
        await prefs.setString('pic', documents[0]['pic']);
        await prefs.setString('role', documents[0]['role']);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
      } else {
        this.setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "Sign in fail");
      }
    }
  }
  void checkSignIn() async{
    setState(() {
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('id') ?? '';
    isEmpty(id)
        ? setState(() {
      isLoading = false;
    })
        :
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Home()));
    setState(() {
      isLoading = false;
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkSignIn();
    setState(() {

    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
      body:  Stack(
    children: [
      //background image
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/cover.png'),
            fit: BoxFit.cover
          )
        ),
      ),
      Container(
        color: colors[5],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Logo
              SvgPicture.asset("assets/icons/logo.svg", height: 130, width: 150,),

              Padding(
                padding: const EdgeInsets.only(bottom:7.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Welcome to ",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: colors[4], fontSize: 18)),
                    ),
                    Text("In Motione",
                      style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: colors[2], fontSize: 18)),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buttonUI(context, 'Login', Colors.transparent , colors[2], (){
                    setState(() {
                      showLogin = true;
                    });
                  }),
                  buttonUI(context, 'Sign Up', colors[2], colors[1], (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                  })
                ],
              )
            ],
          ),
        ),
      ),
      showLogin
      ? loginForm()
          : showRegister
      ? registerForm()
          : Container(),
      isLoading
      ? Positioned(
        child: Container(
          color: colors[0],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  backgroundColor: colors[1],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Signing you in...', style: TextStyle(color: colors[4])),
                )
              ],
            ),
          ),
        ),
      )
          : Container()
    ]
    )
    );
  }
}
