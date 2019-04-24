import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class Auth{
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static String userName;
  static String userEmail;
  static String userPhotoUrl;
  static String uid;
  // static boolean emailVerified;

  static Future<String> signInWithEmailAndPassword(String email, String password) async{
    FirebaseUser user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    return user?.uid;
  }

  static Future<String> createUserWithEmailAndPassword(String email, String password) async{
    FirebaseUser user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    return user?.uid;
  }  

  static Future<String> currentUser() async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser(); 
    if (user != null) {
      userName = user.displayName;
      userEmail = user.email;
      userPhotoUrl = user.photoUrl;
      uid = user.uid;
    }    
    return user?.uid;
  } 

  static Future<void> signOut() async{    
    return await FirebaseAuth.instance.signOut();
  }

  static Future<String> updateUser() async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      userName = user.displayName;
      userEmail = user.email;
      userPhotoUrl = user.photoUrl;
      uid = user.uid;
    }
    return user?.email;
  } 

  static String getName(){
    if(userName != null) return userName;
    else return "";
  }   

  static String getEmail(){
    if(userEmail != null) return userEmail;
    else return "";
  }   

  static String getPhotoUrl(){
    if(userPhotoUrl != null) return userPhotoUrl;
    else return "lib/assets/images/default.png";
  }   
  
}