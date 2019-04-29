import 'package:firebase_database/firebase_database.dart';
import 'package:classroom/course.dart';
import 'package:classroom/auth.dart';
import 'dart:async';

class DatabaseManager{
  static DatabaseReference mDatabase = FirebaseDatabase.instance.reference();

  static void addUsersPerCourse(String uid, String course){
    mDatabase.child("UsersPerCourse").child(course).push().set({
      'uid': uid,
    }).then((_) { });
  }

  static void addCoursesPerUser(String uid, String course){
    mDatabase.child("coursesPerUser").child(uid).push().set({
      'course': course,
    }).then((_) { });
  }

  static Future<String> addCourse(String authorId, String author, String name) async{
    DatabaseReference course;
    course = mDatabase.child("courses").push();
    await course.set({
      'name': name,
      'author': author,
      'authorId': authorId,
      'participants': 1,
      'lessons' : 0,
      'accessCode' : course.key
    }).then((_) {
      addUsersPerCourse(authorId,course.key);
      addCoursesPerUser(authorId,course.key);
      updateCourse(course.key,course.key,"accessCode");
    });
    return course.key;
  }

  static Future<void> updateCourse(String code, String param, String column) async{
    DatabaseReference course;
    switch(column){
      case "participant": {
        int participants = int.parse(param);
        course = await mDatabase.child("courses").child(code).update({
          'participants': participants,
        }).then((_){/*nothing*/});        
        break;
      }
      case "accessCode": {
         course = await mDatabase.child("courses").child(code).update({
          'accessCode': param,
        }).then((_){/*nothing*/});       
        break;
      }
    }    
  }

  static Future<Map> addCourseByAccessCode(String code, String uid) async{
    Map _course;
    await mDatabase.child("courses").child(code).once().then((DataSnapshot snapshot){
      Map<dynamic,dynamic> course = snapshot.value;
      if(course != null){
        int participants = course['participants'] + 1;
        addUsersPerCourse(uid,code);
        addCoursesPerUser(uid,code);
        updateCourse(code,(participants).toString(),"participants");
        _course = {
          'accessCode': course['accessCode'],
          'participants': participants,
          'lessons': course['lessons'],
          'name': course['name'],
          'author': course['author'],
          'authorId': course['authorId']          
        };
      }
    });
    return _course;
  }

  static Future<List<Course>> getCoursesPerUserByList(List<String> listString) async{
    List<Course> _coursesList = List<Course>();
    try{
      for (var eachCourse in listString) {
        await mDatabase.child("courses").child(eachCourse).once().then((DataSnapshot snapshot) {
          Map<dynamic,dynamic> course = snapshot.value;
          if(course != null){
            if(course != null){
              _coursesList.add(
                Course(
                  accessCode: course['accessCode'],
                  participants: course['participants'],
                  lessons: course['lessons'],
                  name: course['name'],
                  author: course['author'],
                  authorId: course['authorId']
                )
              );  
            }      
          }
        }); 
      }
    }catch(e){
      print("error getCoursesPerUserByList: $e");
    } 
    return _coursesList;
  } 

  static Future<List<String>> getCoursesPerUser() async{
    List<String> _coursesList = List<String>();
    try{
      await mDatabase.child("coursesPerUser").child(Auth.uid).once().then((DataSnapshot snapshot) {
        Map<dynamic,dynamic> map = snapshot.value;
        if(map != null){
          map.forEach((key, course) {
            if(map != null){
              _coursesList.add(course['course']);  
            }      
          });
        }
      }); 
    }catch(e){
      print("error getCoursesPerUser: $e");
    } 
    return _coursesList;
  } 
  
  static Future<List<Course>> getAllCourses() async{
    List<Course> _coursesList = List<Course>();
    try{
      await mDatabase.child("courses").once().then((DataSnapshot snapshot) {
        Map<dynamic,dynamic> map = snapshot.value;
        if(map != null){
          map.forEach((key, course) {  
              _coursesList.add(
                Course(
                  accessCode: course['accessCode'],
                  participants: course['participants'],
                  lessons: course['lessons'],
                  name: course['name'],
                  author: course['author'],
                  authorId: course['authorId'],
                )
              );        
          });
        }
      }); 
    }catch(e){
      print("error getAllCourses: $e");
    }          
    return _coursesList;
  }   
}