import 'package:firebase_database/firebase_database.dart';
import 'package:classroom/course.dart';
import 'package:classroom/auth.dart';
class DatabaseManager{
  static DatabaseReference mDatabase = FirebaseDatabase.instance.reference();

  static void addBelongCourse(String uid, String courseid){

  }

  static String getUserInfo(String uid){
    return "user.name.missing";
  }

  static void addUsersPerCourse(String uid, String course){
    mDatabase.child("UsersPerCourse").child(course).push().set({
      'uid': uid,
    }).then((_) { });
  }

  static void addCoursesPerUser(String uid, String course, String name, String code, String author){
    mDatabase.child("coursesPerUser").child(uid).push().set({
      'name': name,
      'author': author,
      'participants': 1,
      'lessons' : 0,
      'accessCode' : code
    }).then((_) { });
  }

  static void addCourse(String author, String name, String code) async{
      DatabaseReference course;
      course =  mDatabase.child("courses").push();
      course.set({
        'name': name,
        'author': author,
        'participants': 1,
        'lessons' : 0,
        'accessCode' : code
      }).then((_) {
        addUsersPerCourse(author,course.key);
        addCoursesPerUser(author,course.key,name,code,author);
      });
  }


  static Future<List<Course>> getCoursesPerUser() async{
    List<Course> _coursesList = List<Course>();
    try{
      await mDatabase.child("courses").once().then((DataSnapshot snapshot) {
        Map<dynamic,dynamic> map = snapshot.value;
        map.forEach((key, course) {  
            print(course);
            _coursesList.add(
              Course(
                accessCode: course['accessCode'],
                participants: course['participants'],
                lessons: course['lessons'],
                name: course['name'],
                author: getUserInfo(course['author'])
              )
            );        
        });
      }); 
    }catch(e){
      print("error $e");
    }   
    return _coursesList;
  } 

  static Future<List<Course>> getAllCourses() async{
    List<Course> _coursesList = List<Course>();
    await mDatabase.child("courses").once().then((DataSnapshot snapshot) {
      Map<dynamic,dynamic> map = snapshot.value;
      map.forEach((key, course) {  
          print(course);
          _coursesList.add(
            Course(
              accessCode: course['accessCode'],
              participants: course['participants'],
              lessons: course['lessons'],
              name: course['name'],
              author: getUserInfo(course['author'])
            )
          );        
      });
    });    
    return _coursesList;
  }   
}