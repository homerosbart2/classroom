
import 'package:firebase_database/firebase_database.dart';
import 'package:classroom/course.dart';
import 'package:classroom/lesson.dart';
import 'package:classroom/question.dart';
import 'package:classroom/auth.dart';
import 'package:classroom/answer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseManager{
  static DatabaseReference mDatabase = FirebaseDatabase.instance.reference();
  static StorageReference storageRef = FirebaseStorage.instance.ref();
  static Directory tempDir = Directory.systemTemp;
  
  static void addUserPerCourse(String uid, String course){
    mDatabase.child("UsersPerCourse").child(course).push().set({
      'uid': uid,
    }).then((_) { });
  }

  static void addCoursePerUser(String uid, String course){
    DocumentReference reference = Firestore.instance.collection('coursesPerUser').document(uid);
    reference.setData({
      'course': course,
    });      
  }

  static void addLessonPerCourse(String lesson, String course){
    DocumentReference reference = Firestore.instance.collection('lessonsPerCourse').document(course);
    reference.setData({
      'lesson': lesson,
    });     
  }  

  static Future<void> removeQuestionsPerUser(String questionId, String uid) async{
    mDatabase.child("questionPerUser").child(uid).equalTo(questionId);        
  } 

  static void deleteDocumentInCollection(String collection,document){
    Firestore.instance.collection(collection).document(document).delete();
  }

  static void searchField(String collection,document,field,compare) async{
    CollectionReference reference = Firestore.instance.collection(collection);
    reference.where(field, isEqualTo: compare).getDocuments().then((snapshot){
      List<DocumentSnapshot> docs = snapshot.documents;
      for(var doc in docs){
        print("DOC: ${doc.data}");
      }
    });
  }

  static Future<void> deleteLesson(String collection,String document) async{
    deleteDocumentInCollection(collection,document);
    searchInArray
  } 

  static Future<void> deleteCourse(String courseId, String uid) async{

  }  

  static String addZero(int param){
    String paramString = param.toString();
    if(paramString.length > 1) return paramString;
    else return "0"+paramString;
  }

  static Future<String> addLesson(String uid, String name, String description, int day, int month, int year, String course) async{
    String date = (addZero(day)+"/"+addZero(month)+"/"+addZero(year));
    DocumentReference lesson = Firestore.instance.collection('lessons').document();
    lesson.setData({
      'name': name,
      'presentation' : false,
      'description': description,
      'date': date,
      'comments' : 0
    }).then((_){
      addLessonPerCourse(lesson.documentID,course);
      updateCourse(course,"1","lessons");
    });
    return lesson.documentID;
  }

  static Future<String> addCourse(String authorId, String author, String name) async{
    DocumentReference course = Firestore.instance.collection('courses').document();
    course.setData({
      'name': name,
      'author': author,
      'authorId': authorId,
      'participants': 1,
      'lessons' : 0,
    }).then((_){
      addCoursePerUser(authorId,course.documentID);
      updateCourse(course.documentID,course.documentID,"accessCode");
    });
    return course.documentID;
  }

  static Future<String> getFiles(String type, String lessonId) async{
    StorageReference ref =  storageRef.child(type).child(lessonId);
    List<int> bytes = await ref.getData(1024*1024*10); 
    File file;
    var directory = await getApplicationDocumentsDirectory();
    file = new File('${directory.path}/$lessonId.pdf');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  static Future<String> uploadFiles(String type, String lessonId, String filePath) async{  
    switch(type){
      case "pdf": {
        StorageUploadTask uploadTask = storageRef.child(type).child(lessonId).putFile(
          File(filePath),
          StorageMetadata(
            contentType: type,
          ),
        );
        await updateLesson(lessonId, "", "presentation");
        break;        
      }
    }    
    return filePath;
  }

  static Future<void> updateLesson(String code, String param, String column) async{
    DatabaseReference lesson;
    print("param: $param");
    switch(column){
      case "comments": {
        await mDatabase.child("lessons").child(code).once().then((DataSnapshot snapshot){
          Map<dynamic,dynamic> currentLesson = snapshot.value;
          mDatabase.child("lessons").child(code).update({
          'comments': currentLesson['comments'] + int.parse(param),
          }).then((_){/*nothing*/});
        });       
        break;        
      }
      case "presentation": {
        await mDatabase.child("lessons").child(code).update({
          'presentation': true,
        }).then((_){/*nothing*/});    
        break;        
      }
      case "name": {
        await mDatabase.child("lessons").child(code).update({
          'name': param,
        }).then((_){/*nothing*/});       
        break;
      }       
      case "date": {
        await mDatabase.child("lessons").child(code).update({
          'date': param,
        }).then((_){/*nothing*/});
        break;        
      }      
      case "description": {
        await mDatabase.child("lessons").child(code).update({
          'description': param,
        }).then((_){/*nothing*/});    
        break;        
      }       
    }    
  }

  static Future<void> updateCourse(String code, var param, String column) async{
    DocumentReference reference = Firestore.instance.document('courses/' + code);
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(reference);
      if (snapshot.exists) {
        switch(column){
          case "participants": {
            await transaction.update(reference, <String, dynamic>{'participants': snapshot.data['participants'] + int.parse(param)});      
            break;
          }
          case "accessCode": {
            await transaction.update(reference, <String, dynamic>{'accessCode': param});       
            break;
          }
          case "name": {
            await transaction.update(reference, <String, dynamic>{'name': param});       
            break;
          }      
          case "lessons": {
            await transaction.update(reference, <String, dynamic>{'lessons': snapshot.data['lessons'] + int.parse(param)});     
            break;        
          }
        }           
      }
    }); 
  }

  static Future<Map> addCourseByAccessCode(String code, String uid) async{
    Map _course;
    await mDatabase.child("courses").child(code).once().then((DataSnapshot snapshot){
      Map<dynamic,dynamic> course = snapshot.value;
      if(course != null){
        int participants = course['participants'];
        updateCourse(code,"1","participants");
        // addUserPerCourse(uid,code);
        addCoursePerUser(uid,code);
        _course = {
          'accessCode': course['accessCode'],
          'participants': participants + 1,
          'lessons': course['lessons'],
          'name': course['name'],
          'author': course['author'],
          'authorId': course['authorId'],
          'owner': false
        };
      }
    });
    return _course;
  }

  //GETTERS 

  static Future<dynamic> getFieldFrom(String parent, String child, String column) async{
    var field;
    await mDatabase.child(parent).child(child).once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> map = snapshot.value;
      if(map != null){
        field = map[column]; 
      }
    });    
    return field;
  }
  
  static Future<List<Lesson>> getLessonsPerCourseByList(List<String> listString, String uid, String courseId) async{
    List<Lesson> lessonsList = List<Lesson>();
    bool userOwner;
    try{
      for (var eachLesson in listString) {
        await Firestore.instance.collection('lessons').document(eachLesson).get().then((snapshot){
          Map<dynamic,dynamic> lesson = snapshot.data;
          if(lesson != null){
            if(lesson['authorId'] == uid) userOwner = true;
            else userOwner = false;
            String date = (lesson['date']).toString();
            lessonsList.add(
              Lesson(
                presentation: lesson['presentation'],
                lessonId: eachLesson,
                courseId: courseId,
                comments: lesson['comments'],
                date: lesson['date'],
                description: lesson['description'],
                name: lesson['name'],
                owner: userOwner,
              )
            );       
          }
        }); 
      }
    }catch(e){
      print("error getLessonsPerCourseByList: $e");
    } 
    return lessonsList;
  } 

  static Future<List<Course>> getCoursesPerUserByList(List<String> listString, String uid) async{
    List<Course> coursesList = List<Course>();
    bool userOwner;
    try{
      for (var eachCourse in listString) {
        await Firestore.instance.collection('courses').document(eachCourse).get().then((snapshot){
          Map<dynamic,dynamic> course = snapshot.data;
          if(course != null){
            if(course['authorId'] == uid) userOwner = true;
            else userOwner = false;
            coursesList.add(
              Course(
                courseId: course['accessCode'],
                participants: course['participants'],
                lessons: course['lessons'],
                name: course['name'],
                author: course['author'],
                authorId: course['authorId'],
                owner: userOwner,
              )
            );    
          }
        }); 
      }
    }catch(e){
      print("error getCoursesPerUserByList: $e");
    } 
    return coursesList;
  } 

  static Future<List<String>> getQuestionsPerLesson(String lesson) async{
    List<String> questionsList = List<String>();
    try{
      DocumentReference reference = Firestore.instance.collection('questionsPerLesson').document(lesson);
      await reference.get().then((snapshot){
        snapshot.data.forEach((key,value){
          questionsList.add(value);
        });
      });
    }catch(e){
      print("error getQuestionsPerUser: $e");
    }     
    return questionsList;
  } 

  static Future<List<String>> getLessonsPerCourse(String course) async{
    List<String> lessonsList = List<String>();
    try{
      DocumentReference reference = Firestore.instance.collection('lessonsPerCourse').document(course);
      await reference.get().then((snapshot){
        snapshot.data.forEach((key,value){
          lessonsList.add(value);
        });
      });
    }catch(e){
      print("error getLessonsPerUser: $e");
    } 
    return lessonsList;
  } 

  static Future<List<String>> getCoursesPerUser() async{
    List<String> coursesList = List<String>();
    try{
      DocumentReference reference = Firestore.instance.collection('coursesPerUser').document(Auth.uid);
      await reference.get().then((snapshot){
        snapshot.data.forEach((key,value){
          coursesList.add(value);
        });
      });
    }catch(e){
      print("error getCoursesPerUser: $e");
    }
    return coursesList;
  }  
}