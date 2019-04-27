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

  static void addCoursesPerUser(String uid, String course, String name, String code, String authorId, String author){
    mDatabase.child("coursesPerUser").child(uid).push().set({
      'course': course,
      'name': name,
      'author': author,
      'authorId': authorId,
      'participants': 1,
      'lessons' : 0,
      'accessCode' : code
    }).then((_) { });
  }

  static void addCourse(String authorId, String author, String name, String code) async{
    DatabaseReference course;
    course =  mDatabase.child("courses").push();
    course.set({
      'name': name,
      'author': author,
      'authorId': authorId,
      'participants': 1,
      'lessons' : 0,
      'accessCode' : code
    }).then((_) {
      addUsersPerCourse(authorId,course.key);
      addCoursesPerUser(authorId,course.key,name,code,authorId,author);
    });
  }

  static Future<Map> addCourseByAccessCode(String code, String uid) async{
    Map _course;
    await mDatabase.child("courses").child(code).once().then((DataSnapshot snapshot){
      Map<dynamic,dynamic> course = snapshot.value;
      if(course != null){
        addUsersPerCourse(uid,code);
        addCoursesPerUser(uid,code,course['name'],course['accessCode'],course['authorId'],course['author']);
        _course = {
          'accessCode': course['accessCode'],
          'participants': course['participants'],
          'lessons': course['lessons'],
          'name': course['name'],
          'author': course['author'],
          'authorId': course['authorId']          
        };
      }
    });
    print(_course);
    return _course;
  }

  static Future<List<Course>> getCoursesPerUser() async{
    List<Course> _coursesList = List<Course>();
    try{
      await mDatabase.child("coursesPerUser").child(Auth.uid).once().then((DataSnapshot snapshot) {
        Map<dynamic,dynamic> map = snapshot.value;
        if(map != null){
          map.forEach((key, course) {
            if(map != null){
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
              print(course);
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