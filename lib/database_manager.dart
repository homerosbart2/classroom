
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

  static void addCoursesPerUser(String uid, String course){
    List<String> list = new List<String>();  
    DocumentReference reference = Firestore.instance.document('coursesPerUser/' + uid);
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(reference);
      if (snapshot.data != null) {
        list = List<String>.from(snapshot.data['courses']);
        list.add(course);
        await transaction.update(reference, <String, dynamic>{'courses': list});
      }else{
        list.add(course);
        reference.setData({
          'courses': list,
        });          
      }
    });        
  }

  static void addLessonPerCourse(String lesson, String course){
    List<String> list = new List<String>();  
    DocumentReference reference = Firestore.instance.document('lessonsPerCourse/' + course);
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(reference);
      if (snapshot.data != null) {
        list = List<String>.from(snapshot.data['lessons']);
        list.add(lesson);
        await transaction.update(reference, <String, dynamic>{'lessons': list});
      }else{
        list.add(lesson);
        reference.setData({
          'lessons': list,
        });          
      }
    });     
  }  

  static void addUsersPerCourse(String course, String uid){
    List<String> list = new List<String>();  
    DocumentReference reference = Firestore.instance.document('usersPerCourse/' + course);
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(reference);
      if (snapshot.data != null) {
        list = List<String>.from(snapshot.data['users']);
        list.add(uid);
        await transaction.update(reference, <String, dynamic>{'users': list});
      }else{
        list.add(uid);
        reference.setData({
          'users': list,
        });          
      }
    });     
  }  

  static void removeVoteToQuestion(String lessonId, String authorId, String question, String val){
    CollectionReference reference = Firestore.instance.collection('lessons').document(lessonId).collection("questions").document(question).collection("votes");
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.set(reference.document(authorId), <String, dynamic>{"voted": false}).then((_){
        updateQuestion(lessonId,question, val, "votes");
      });
    });  
  }

  static void addVoteToQuestion(String lessonId, String authorId, String question, String val){   
    CollectionReference reference = Firestore.instance.collection('lessons').document(lessonId).collection("questions").document(question).collection("votes");
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.set(reference.document(authorId), <String, dynamic>{"voted": true}).then((_){
        updateQuestion(lessonId,question, val, "votes");
      });
    });    
  }

  static void removeVoteToAnswer(String lessonId, String authorId, String question, String answer, String val){
    CollectionReference reference = Firestore.instance.collection('lessons').document(lessonId).collection("questions").document(question).collection("answers").document(answer).collection("votes");
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.set(reference.document(authorId), <String, dynamic>{"voted": false}).then((_){
        updateAnswer(lessonId,question,answer,val,"votes");
      });
    });
  }

  static void addVoteToAnswer(String lessonId, String authorId, String question, String answer, String val){
    CollectionReference reference = Firestore.instance.collection('lessons').document(lessonId).collection("questions").document(question).collection("answers").document(answer).collection("votes");
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.set(reference.document(authorId), <String, dynamic>{"voted": true}).then((_){
        updateAnswer(lessonId,question,answer,val,"votes");
      });
    });
  }

  static Future<String> addAnswers(String question, String author, String authorId, String lesson, String text, int day, int month, int year, int hours, int minutes) async{
    DocumentReference reference = Firestore.instance.collection('lessons').document(lesson);
    await reference.collection("questions").document(question).collection("answers").document().setData({
      'text': text,
      'author': author,
      'authorId': authorId,
      'day': day,
      'month': month,
      'year': year,
      'hours': hours,
      'minutes': minutes,
      'votes': 0,
    }).then((_){
      updateQuestion(lesson, question, "1", "comments");
    });
    return reference.documentID;
  }

  static Future<String> addQuestions(String author, String authorId, String lesson, String text, int day, int month, int year, int hours, int minutes) async{
    DocumentReference reference = Firestore.instance.collection('lessons').document(lesson);
    reference.collection("questions").document().setData({
      'text': text,
      'author': author,
      'authorId': authorId,
      'day': day,
      'month': month,
      'year': year,
      'hours': hours,
      'minutes': minutes,
      'votes': 0,
    }).then((_){
      updateLesson(lesson,"1","comments");
    });
    return reference.documentID;
  }

  static Future<void> removeAnswersPerQuestion(String questionId) async{
    await mDatabase.child("answersPerQuestion").child(questionId).remove();
  }

  static Future<void> removeQuestionsPerLesson(String questionId) async{
    await mDatabase.child("questionsPerLesson").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> map = snapshot.value;
      if(map != null){
        map.forEach((key, val) {
          mDatabase.child("questionPerLesson").child(key).child(questionId).remove();
        });
      }
    });           
  }  

  static Future<void> removeQuestionsPerUser(String questionId, String uid) async{
    mDatabase.child("questionPerUser").child(uid).equalTo(questionId);        
  } 

  static Future<void> deleteDocumentInCollection(String collection,document) async{
    await Firestore.instance.collection(collection).document(document).delete();
  }

  static Future<void> deleteFromArray(collection,document,field,val) async{
    List<dynamic> list = new List<dynamic>();
    DocumentReference reference = Firestore.instance.document(collection + '/' + document);
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(reference);
      list = List<String>.from(snapshot.data[field]);
      list.remove(val);
      await transaction.update(reference, <String, dynamic>{field: list});
    });  
  }

  static Future<bool> searchInArray(collection,document,field,compare) async{
    List<dynamic> lista = new List<dynamic>();
    DocumentReference reference = Firestore.instance.collection(collection).document(document);
    await reference.get().then((snapshot){
      if(snapshot.data != null) lista = List<String>.from(snapshot.data[field]);
    });
    return lista.contains(compare);
  }

  static void searchArray(collection,document,field,compare) async{
    CollectionReference reference = Firestore.instance.collection(collection);
    reference.where(field, arrayContains: compare).getDocuments().then((snapshot){
      List<DocumentSnapshot> docs = snapshot.documents;
      for(var doc in docs){
        print("DOC: ${doc.data}");  
      }
    });
  }

  static Future<dynamic> getDocumentIDInSearchFieldInCollection(location,collection,field,compare) async{
    var documentId = null;
    DocumentSnapshot doc;
    CollectionReference reference = Firestore.instance.document(location).collection(collection);
    await reference.where(field, isEqualTo: compare).getDocuments().then((snapshot){
      doc = snapshot.documents.first;  
    }).then((_){
      if(doc.exists) documentId = doc.documentID;       
    });
    return documentId;
  }

  static Future<bool> getFieldInDocument(location,document,field) async{
    var val;
    DocumentReference reference = Firestore.instance.collection(location).document(document);
    await reference.get().then((snapshot){
      if(snapshot.data != null)val = snapshot[field];     
    });
    if(val == null) val = false;
    return val;
  }

  static Future<bool> searchFieldInCollection(location,collection,field,compare) async{
    bool find = false;
    List<DocumentSnapshot> docs = new List<DocumentSnapshot>();
    CollectionReference reference = Firestore.instance.document(location).collection(collection);
    await reference.where(field, isEqualTo: compare).getDocuments().then((snapshot){
      docs = snapshot.documents;
    }).then((_){
      if(docs.isNotEmpty) find = true;       
    });
    return find;
  }

  static Future<void> deleteLesson(String lessonId,String courseId) async{
    await deleteDocumentInCollection("lessons", lessonId).then((_){
      updateCourse(courseId, "-1", "lessons");
      deleteFromArray("lessonsPerCourse", courseId, "lessons", lessonId);
    });
  } 

  static Future<void> deleteCourse(String courseId, String uid) async{
    await deleteDocumentInCollection("courses", courseId).then((_){
      deleteFromArray("coursesPerUser", uid, "courses", courseId);
      // deleteFromArray("coursesPerUser", uid, "courses", courseId);
    });
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
      addCoursesPerUser(authorId,course.documentID);
      addUsersPerCourse(course.documentID,authorId);
      updateCourse(course.documentID,course.documentID,"accessCode");
    });
    return course.documentID;
  }

  static Future<void> updateAnswer(String lesson, String question, String answer, String param, String column) async{
    DocumentReference reference = Firestore.instance.document('lessons/' + lesson + "/questions/" + question + "/answers/" + answer);
    await Firestore.instance.runTransaction((Transaction transaction) async {
      // DocumentSnapshot snapshot = await transaction.get(reference);
      // if (snapshot.exists) {
        switch(column){
          case "votes": {
            await transaction.update(reference, <String, dynamic>{'votes': FieldValue.increment(int.parse(param))});      
            break;
          }
          default: {
            await transaction.update(reference, <String, dynamic>{column: param});       
            break;
          }
        }           
      // }
    });  
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

  static Future<void> updateQuestion(String lesson, String question, String param, String column) async{
    DocumentReference reference = Firestore.instance.document('lessons/' + lesson + "/questions/" + question);
    Firestore.instance.runTransaction((Transaction transaction) async {
      // DocumentSnapshot snapshot = await transaction.get(reference);
      // if (snapshot.exists) {
        switch(column){
          case "votes": {
            await transaction.update(reference, <String, dynamic>{'votes': FieldValue.increment(int.parse(param))});      
            break;
          }
          default: {
            await transaction.update(reference, <String, dynamic>{column: param});       
            break;
          }
        }           
      // }
    });       
  }

  static Future<void> updateLesson(String code, String param, String column) async{
    DocumentReference reference = Firestore.instance.document('lessons/' + code);
    Firestore.instance.runTransaction((Transaction transaction) async {
      // DocumentSnapshot snapshot = await transaction.get(reference);
      // if (snapshot.exists) {
        switch(column){
          case "comments": {
            await transaction.update(reference, <String, dynamic>{'comments': FieldValue.increment(int.parse(param))});      
            break;
          }
          default: {
            await transaction.update(reference, <String, dynamic>{column: param});       
            break;
          }
        }           
      // }
    });     
  }

  static Future<void> updateCourse(String code, var param, String column) async{
    DocumentReference reference = Firestore.instance.document('courses/' + code);
    Firestore.instance.runTransaction((Transaction transaction) async {
      // DocumentSnapshot snapshot = await transaction.get(reference);
      // if (snapshot.exists) {
        switch(column){
          case "participants": {
            await transaction.update(reference, <String, dynamic>{'participants': FieldValue.increment(int.parse(param))});      
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
            await transaction.update(reference, <String, dynamic>{'lessons': FieldValue.increment(int.parse(param))});     
            break;        
          }
        }           
      // }
    }); 
  }

  static Future<Map> addCourseByAccessCode(String code, String uid) async{
    Map course;
    DocumentReference reference = Firestore.instance.collection('courses').document(code);
    await reference.get().then((snapshot){
      if(snapshot.data != null){
        print("snap: ${snapshot.data}");
        int participants = snapshot.data['participants'];
        updateCourse(code,"1","participants");
        addUsersPerCourse(code,uid);
        addCoursesPerUser(uid,code);
        course = {
          'accessCode': snapshot.data['accessCode'],
          'participants': participants + 1,
          'lessons': snapshot.data['lessons'],
          'name': snapshot.data['name'],
          'author': snapshot.data['author'],
          'authorId': snapshot.data['authorId'],
          'owner': false
        };
      }
    });
    return course;
  }


  static Future<dynamic> actionOnFieldFrom(String parent, String child1, String child2, String param, String column, var value, String type, String action) async{
    var data = "";
    switch(type){
      //means that update a node where value is equal to ...
      case "i":{
        await mDatabase.child(parent).child(child1).orderByChild(column).once().then((DataSnapshot snapshot){
          Map<dynamic, dynamic> map = snapshot.value;
          if(map != null){
            map.forEach((key, val) {
              print("VAL: $val");
              if(val[param] == child2){
                switch(action){
                  case "update":{
                    mDatabase.child(parent).child(child1).child(key).update({
                      column: (value * -1),
                    }).then((_){/*nothing*/});
                    break;
                  }
                  case "delete":{
                    mDatabase.child(parent).child(child1).child(key).remove().then((_){/*nothing*/});
                    break;
                  }
                  case "get":{
                    data = key;
                    break;
                  }                  
                }                
              }
            });
          }
        });
        break;
      }
      case "d":{
        //means that update a node directly
        switch(action){
          case "update":{
            await mDatabase.child(parent).child(child1).update({
              column: value,
            });            
            break;
          }
          case "delete":{
            mDatabase.child(parent).child(child1).remove();
            break;
          }         
        }
      }
    }
    return data;
  }

  static Future<dynamic> getFieldFrom(String collection, String document, String field) async{
    var val;
    DocumentReference reference = Firestore.instance.collection(collection).document(document);
    await reference.get().then((snapshot){
      val = snapshot.data[field];
    });        
    return field;
  }

  static Future<List<String>> getAnswersPerQuestion(String uid, String question) async{
    List<String> listAnswerString = List<String>();
    try{
      await mDatabase.child("answersPerQuestion").child(question).orderByChild("votes").once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> map = snapshot.value;
        if(map != null){
          map.forEach((key, val) {
            listAnswerString.add(val['answer']);
          });
        }
      }); 
    }catch(e){
      print("error getAnswersPerQuestion: $e");
    } 
    return listAnswerString;
  } 
  
  
  static Future<bool> getVotesToUserPerQuestion(String uid, String question) async{
    bool voted = false;
    try{
      await mDatabase.child("votesToUserPerQuestion").child(uid).child(question).once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> map = snapshot.value;
        if(map != null){
          map.forEach((key, val) {
            voted = val['voted'];
          });
        }
      }); 
    }catch(e){
      print("error getVotesPerQuestionAndUser: $e");
    } 
    return voted;
  } 
 
  static Future<List<Answer>> getAnswersPerQuestionByList(String lessonId, String questionId) async{
    List<Answer> answersList = new List<Answer>(); 
    CollectionReference reference = Firestore.instance.collection('lessons').document(lessonId).collection("questions").document(questionId).collection("answers");
    await reference.orderBy("votes", descending: true).getDocuments().then((snapshot){
      List<DocumentSnapshot> docs = snapshot.documents;
      for(var doc in docs){
        answersList.add(
          Answer( 
            answerId: doc.documentID,
            questionId: questionId,
            text: doc['text'],
            author: doc['author'],
            authorId: doc['authorId'],
            lessonId: lessonId,
            // day: doc['day'],
            // month: doc['month'],
            // year: doc['year'],
            // hours: doc['hours'],
            // minutes: doc['minutes'],                
            votes: doc['votes'],
          )
        );  
      }
    });  
    return answersList;
  } 


  static Future<List<Question>> getQuestionsPerLessonByList(List<String> listString, String lesson) async{
    List<Question> _questionsList = List<Question>();
    try{
      for (var eachQuestion in listString) {
        await mDatabase.child("questions").child(eachQuestion).once().then((DataSnapshot snapshot) {
          Map<dynamic,dynamic> question = snapshot.value;
          if(question != null){
            _questionsList.add(
              Question(
                lessonId: lesson,
                questionId: snapshot.key,
                text: question['text'],
                author: question['author'],
                authorId: question['authorId'],
                day: question['day'],
                month: question['month'],
                year: question['year'],
                hours: question['hours'],
                minutes: question['minutes'],                
                votes: question['votes'],
              )
            );  
          }    
        }); 
      }
    }catch(e){
      print("error getQuestionsPerLessonByList: $e");
    } 
    return _questionsList;
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
    List<String> _questionsList = List<String>();
    try{
      await mDatabase.child("questionsPerLesson").child(lesson).orderByChild("votes").once().then((DataSnapshot snapshot) {
        Map<dynamic,dynamic> map = snapshot.value;
        if(map != null){
          map.forEach((key, question) {
            if(map != null){
              _questionsList.add(question['question']);  
            }      
          });
        }
      }); 
    }catch(e){
      print("error getQuestionsPerUser: $e");
    } 
    return _questionsList;
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
        coursesList = List<String>.from(snapshot.data['courses']);
      });
    }catch(e){
      print("error getCoursesPerUser: $e");
    }
    return coursesList;
  }    
}