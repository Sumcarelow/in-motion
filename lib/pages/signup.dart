import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_motion/extras/data.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';


class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  //Form Utilities
  TextEditingController controllerFirstName;
  TextEditingController controllerLastName;
  TextEditingController controllerEmail;
  TextEditingController controllerPassword;
  TextEditingController controllerAddress;
  final FocusNode focusNodeFirstName = FocusNode();
  final FocusNode focusNodeLastName = FocusNode();
  final FocusNode focusNodeAddress = FocusNode();
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodePassword = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String firstName, lastName, email, address, role, password, pic = '';
  File profilePic;
  bool isLoading = false;
  SharedPreferences prefs;


  //Role Select
  Row categoryLabel2(String category) {
    return Row(
      children: [
        Radio(
          activeColor: colors[2],
          groupValue: role,
          value: category,
          onChanged: (String value){
            setState(() {
              role = value;
            });
          },
        ),
        Text(category,
          style: GoogleFonts.getFont('Roboto', textStyle: TextStyle(color: colors[0], fontSize: 15,)),
        ),
      ],
    );
  }

  //Get profile Image
  Future getImage() async {
    File image = await FilePicker.getFile(type: FileType.image);

    if (image != null) {
      setState(() {
        profilePic = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = DateFormat('ddMMMMyyyyhhmmss').format(DateTime.now()).toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(profilePic);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          setState(() {
            pic = downloadUrl;
            isLoading = false;
          });

        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'Failed to Upload');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }
  void handleUpdateData() async{
    focusNodeFirstName.unfocus();
    focusNodeLastName.unfocus();
    focusNodeEmail.unfocus();
    focusNodeAddress.unfocus();
    focusNodePassword.unfocus();
    prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });
    // Check is already sign up
    final QuerySnapshot result =
    await Firestore.instance.collection('users').where('email', isEqualTo: email)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if(documents.length == 0) {
      DocumentReference docRef = Firestore.instance.collection('users').document();
      docRef.setData({
        'firstName': firstName,
        'lastName': lastName,
        'id': docRef.documentID,
        'email': email,
        'pic': pic,
        'password': password,
        'address': address,
        'role': role,
        'date': DateFormat('dd MMMM yyyy').format(DateTime.now()).toString(),
        'time': DateFormat('hh:mm:ss').format(DateTime.now()).toString()
      }).then((data) async {
        await prefs.setString('firstName', firstName);
        await prefs.setString('lastName', lastName);
        await prefs.setString('role', role);
        await prefs.setString('pic', pic);
        await prefs.setString('address', address);
        await prefs.setString('id', docRef.documentID);
        await prefs.setString('email', email);

        setState(() {
          isLoading = false;
        });

        Fluttertoast.showToast(msg: "Registration successful");
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });

        Fluttertoast.showToast(msg: err.toString());
      });
    }else
    {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Already registered, please go to sign in");

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: colors[1],
        centerTitle: true,
        title: Text("Sign Up"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: Text("Please fill in the following information to join In Motione App.",
                      textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          categoryLabel2("Passenger"),
                          categoryLabel2("Driver"),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        // Avatar
                        Expanded(
                          child: Container(
                            child: Center(
                              child: Stack(
                                children: <Widget>[
                                  (profilePic == null)
                                      ? (pic != ''
                                      ? Material(
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                        ),
                                        width: 90.0,
                                        height: 90.0,
                                        padding: EdgeInsets.all(20.0),
                                      ),
                                      imageUrl: pic,
                                      width: 90.0,
                                      height: 90.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(45.0)),
                                    clipBehavior: Clip.hardEdge,
                                  )
                                      : Icon(
                                    Icons.account_circle,
                                    size: 90.0,
                                  ))
                                      : Material(
                                    child: Image.file(
                                      profilePic,
                                      width: 90.0,
                                      height: 90.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(45.0)),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.camera_alt,
                                    ),
                                    onPressed: getImage,
                                    padding: EdgeInsets.all(30.0),
                                    splashColor: Colors.transparent,
                                    iconSize: 30.0,
                                  ),
                                ],
                              ),
                            ),
                            width: double.infinity,
                            margin: EdgeInsets.all(20.0),
                          ),
                        ),

                        // Input
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: Theme(
                                  data: Theme.of(context).copyWith(primaryColor: colors[0]),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'First Name',
                                      hintText: 'Thabiso',
                                      contentPadding: new EdgeInsets.all(5.0),
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    controller: controllerFirstName,
                                    onChanged: (value) {
                                      firstName = value;
                                    },
                                    focusNode: focusNodeFirstName,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Cannot be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                margin: EdgeInsets.only(left: 30.0, right: 30.0),
                              ),
                              Container(
                                child: Theme(
                                  data: Theme.of(context).copyWith(primaryColor: colors[0]),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Last Name',
                                      hintText: 'Sithole',
                                      contentPadding: new EdgeInsets.all(5.0),
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    controller: controllerLastName,
                                    onChanged: (value) {
                                      lastName = value;
                                    },
                                    focusNode: focusNodeLastName,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Cannot be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                margin: EdgeInsets.only(left: 30.0, right: 30.0),
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        ),
                      ],
                    ),

                    //Other Information
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: colors[0]),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'user@example.com',
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: controllerEmail,
                          onChanged: (value) {
                            email = value;
                          },
                          focusNode: focusNodeEmail,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Cannot be empty';
                            }
                            return null;
                          },
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: colors[0]),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: '...',
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: controllerPassword,
                          obscureText: true,
                          onChanged: (value) {
                            password = value;
                          },
                          focusNode: focusNodePassword,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Cannot be empty';
                            }
                            return null;
                          },
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: colors[0]),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Address',
                            hintText: '123 ABC Street',
                            contentPadding: new EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: controllerAddress,
                          onChanged: (value) {
                            address = value;
                          },
                          focusNode: focusNodeAddress,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Cannot be empty';
                            }
                            return null;
                          },
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),


                    RaisedButton(
                      onPressed: (){
                        _formKey.currentState.validate()
                            ? isEmpty(pic)
                            ? Fluttertoast.showToast(msg: "Please select a profile picture.")
                            : isEmpty(role)
                            ? Fluttertoast.showToast(msg: "Please select a role between Driver and Passenger.")
                            : handleUpdateData()
                            : Fluttertoast.showToast(msg: "Please fill in the missing or incorrect information.");
                      },
                      color: colors[0],
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.getFont('Lora', textStyle: TextStyle(color: colors[2], fontSize: 15,)),
                      ),
                    )
                  ],
                )),
          ),
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
                      child: Text('Signing you up...', style: TextStyle(color: colors[4])),
                    )
                  ],
                ),
              ),
            ),
          )
              : Container()
        ],
      ),
    );
  }
}
