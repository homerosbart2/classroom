import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class Auth{
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static String userName = "";
  static String userEmail = "";
  static String userPhotoUrl;
  static String uid = "";
  // static boolean emailVerified;

  static Future<dynamic> signInWithEmailAndPassword(String email, String password) async{
    FirebaseUser user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    if(user != null){
      print("verified ${user.isEmailVerified}");
      if (user.isEmailVerified == true) return user.uid;
      else return "0";
    }
    else return "-1";
  }

  static Future<void> resetPassword(String email) async {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
  
  static Future<String> createUserWithEmailAndPassword(String email, String password, String name) async{
    FirebaseUser user;
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).then((user){
        UserUpdateInfo profileUpdate = new UserUpdateInfo();
        profileUpdate.displayName = name;
        user.updateProfile(profileUpdate);
        user.reload().then((_){
          try{
            user.sendEmailVerification();
          }catch(e){
            print("An error occured while trying to send email        verification");
            print(e.message);      
          }          
            // Auth.signInWithEmailAndPassword(email, password).then((_){
            //   return user?.uid;
            // });
        });
      });
    }catch(e){
      return null;
    }
  }  

  static Future<String> currentUser(String name) async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser(); 
    if (user != null) {
      if(name != "") userName = name;
      else userName = user.displayName;
      userEmail = user.email;
      userPhotoUrl = user.photoUrl;
      uid = user.uid;
    }    
    return user?.uid;
  } 

  static Future<void> signOut() async{    
    await FirebaseAuth.instance.signOut();
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