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

  static void addCoursesPerUser(String uid, String course){
    mDatabase.child("coursesPerUser").child(uid).push().set({
      'course': course,
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
        addCoursesPerUser(author,course.key);
      });
  }

  static List<Course> getCourses(){
    //search in node coursesPerUser
    // mDatabase.child("coursesPerUser").equalTo(Auth.uid).once().then((DataSnapshot snapshot){
      // print("first query: $snapshot");
    // });

    List<Course> _coursesList = List<Course>();
    mDatabase.once().then((DataSnapshot snapshot) {
      Map<dynamic,dynamic> map = snapshot.value;
      map.forEach((key, value) {  
        value.forEach((key, course){
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
    });
    return _coursesList;
  }   
}