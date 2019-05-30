
import 'package:firebase_database/firebase_database.dart';
import 'package:classroom/course.dart';
import 'package:classroom/lesson.dart';
import 'package:classroom/question.dart';
import 'package:classroom/auth.dart';
import 'package:classroom/answer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';

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
    mDatabase.child("coursesPerUser").child(uid).push().set({
      'course': course,    }).then((_) { });
  }

  static void addLessonPerCourse(String lesson, String course){
    mDatabase.child("lessonsPerCourse").child(course).push().set({
      'lesson': lesson,
    }).then((_) { });
  }  

  static void addQuestionsPerLesson(String question, String lesson, var val) async{
    await mDatabase.child("questionsPerLesson").child(lesson).push().set({
      'question': question,
      'votes': val,
    }).then((_) { });
  }  

  static void addQuestionsPerUser(String uid, String question) async{
    mDatabase.child("questionsPerUser").child(uid).push().set({
      'question': question,
    }).then((_) { });
  }

  static void addAnswersPerQuestion(String answer, String question, int votes) async{
    await mDatabase.child("answersPerQuestion").child(question).push().set({
      'answer': answer,
      'votes': votes,
    }).then((_) { });
  }

  static void addAnswersPerUser(String uid, String answer) async{
    await mDatabase.child("answersPerUser").child(uid).push().set({
      'answer': answer,
    }).then((_) { });
  }

  static void removeVotesToParamPerUser(String uid, String question, String param){
    mDatabase.child(param).child(uid).child(question).remove();
  }

  static void removeVotesToUserPerParam(String uid, String val, String param){
    mDatabase.child(param).child(val).child(uid).remove();
  }
  
  static void addVotesToUserPerQuestion(String uid, String val, String param){
    mDatabase.child(param).child(uid).child(val).runTransaction((MutableData transaction) async{
      transaction.value = (transaction.value ?? 0) + 1;
      return transaction;
    }).then((transaction){
      print("TRANSACTION : $transaction");
    });
    // mDatabase.child(param).child(uid).child(val).push().set({
    //   'voted': true,
    // }).then((_) {/*nothing*/});
  }

  static void addVotesToParamPerUser(String uid, String question, String param){
    mDatabase.child(param).child(question).child(uid).push().set({
      'voted': true,
    }).then((_) {/*nothing*/});
  }  

  static void addVoteToQuestion(String lessonId, String authorId, String question, String val){

    updateQuestion(lessonId,question, val, "votes");
    if(val == "1"){
      addVotesToUserPerQuestion(authorId, question, "votesToUserPerQuestion");
      addVotesToParamPerUser(authorId, question, "votesToQuestionPerUser");
    }else{
      removeVotesToUserPerParam(authorId, question, "votesToQuestionPerUser");
      removeVotesToParamPerUser(authorId, question, "votesToUserPerQuestion");
    }
  }

  static void addVoteToAnswer(String questionId, String authorId, String answer, String val){
    print("answer here: $answer");
    updateAnswer(questionId, answer, val, "votes");
    if(val == "1"){
      addVotesToUserPerQuestion(authorId, answer, "votesToUserPerAnswer");
      addVotesToParamPerUser(authorId, answer, "votesToAnswerPerUser");
    }else{
      removeVotesToUserPerParam(authorId, answer, "votesToAnswerPerUser");
      removeVotesToParamPerUser(authorId, answer, "votesToUserPerAnswer");
    }
  }

  static Future<String> addAnswers(String question, String author, String authorId, String lesson, String text, int day, int month, int year, int hours, int minutes) async{
    DatabaseReference answer;
    answer = mDatabase.child("answers").push();
    await answer.set({
      'text': text,
      'author': author,
      'authorId': authorId,
      'day': day,
      'month': month,
      'year': year,
      'hours': hours,
      'minutes': minutes,
      'votes': 0,
    }).then((_) {
      addAnswersPerQuestion(answer.key, question,0);
      addAnswersPerUser(authorId, answer.key);
      updateQuestion(lesson, question, "", "comments");
    });
    return answer.key;
  }

  static Future<String> addQuestions(String author, String authorId, String lesson, String text, int day, int month, int year, int hours, int minutes) async{
    DatabaseReference question;
    question = mDatabase.child("questions").push();
    await question.set({
      'text': text,
      'author': author,
      'authorId': authorId,
      'day': day,
      'month': month,
      'year': year,
      'hours': hours,
      'minutes': minutes,
      'votes': 0,
    }).then((_) {
      updateLesson(lesson,"1","comments");
      addQuestionsPerLesson(question.key, lesson, 0);
      addQuestionsPerUser(authorId, question.key);
    });
    return question.key;
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

  static Future<void> deleteQuestion(String questionId, String lessonId, String uid) async{
    await mDatabase.child("questions").child(questionId).remove().then((_){
      updateLesson(lessonId,"-1","comments");
      actionOnFieldFrom("questionsPerLesson", lessonId, questionId, "question", "question", "", "i", "delete");
      actionOnFieldFrom("answersPerQuestion", questionId, "", "", "", "", "d", "delete");
      actionOnFieldFrom("questionsPerUser", uid, questionId, "question", "question", "", "i", "delete");
    });
  }


  static Future<void> deleteLesson(String lessonId, String uid) async{
    await mDatabase.child("lessons").child(lessonId).remove().then((_){
      actionOnFieldFrom("questionsPerLesson", lessonId, "", "", "", "", "d", "delete");
      // actionOnFieldFrom("lessonsPerCourse", courseId, lessonId, "lesson", "lesson", "", "i", "delete");
    });
  } 

  static Future<void> deleteCourse(String courseId, String uid) async{
    await mDatabase.child("courses").child(courseId).remove().then((_){
      actionOnFieldFrom("lessonsPerCourse", courseId, "", "", "", "", "d", "delete");
      actionOnFieldFrom("coursesPerUser", uid, courseId, "course", "course", "", "i", "delete");
    });
  }  

  static String addZero(int param){
    String paramString = param.toString();
    if(paramString.length > 1) return paramString;
    else return "0"+paramString;
  }

  static Future<String> addLesson(String uid, String name, String description, int day, int month, int year, String course) async{
    DatabaseReference lesson;;
    int date = int.parse(addZero(day)+addZero(month)+addZero(year));
    lesson = mDatabase.child("lessons").push();
    await lesson.set({
      'name': name,
      'presentation' : false,
      'description': description,
      'date': date,
      'comments' : 0
    }).then((_) {
      addLessonPerCourse(lesson.key,course);
      updateCourse(course,"","lessons");
    });
    return lesson.key;
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
      // addUserPerCourse(authorId,course.key);
      addCoursePerUser(authorId,course.key);
      updateCourse(course.key,course.key,"accessCode");
    });
    return course.key;
  }

  static Future<void> updateAnswer(String questionId, String code, String param, String column) async{
    DatabaseReference answer;
    int newVotes;
    switch(column){
      case "votes": {
        await mDatabase.child("answers").child(code).once().then((DataSnapshot snapshot){
          Map<dynamic,dynamic> currentAnswer = snapshot.value;
          newVotes = currentAnswer['votes'] + int.parse(param);
          mDatabase.child("answers").child(code).update({
            'votes': newVotes,
          }).then((_){
            actionOnFieldFrom("answersPerQuestion",questionId,code,"answer","votes",newVotes,"i","update");
          });
        });         
        break;        
      }      
    }    
  }

  static Future<String> getFiles(String type, String lessonId) async{
    StorageReference ref = storageRef.child(type).child(lessonId);
    String path = ""; 
    if(ref != null){
      Directory tempDir = Directory.systemTemp;
      File file = File('${tempDir.path}/$lessonId.pdf');
      if(!(await file.exists())){
        StorageFileDownloadTask downloadTask = ref.writeToFile(file);
        int byteNumber = (await downloadTask.future).totalByteCount;
      }
      path = file.path;
    }
    return path;
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
        updateLesson(lessonId, "", "presentation");
        break;        
      }
    }    
    return filePath;
  }

  static Future<void> updateQuestion(String lesson, String code, String param, String column) async{
    DatabaseReference question;
    int newVotes;
    switch(column){
      case "votes": {
        await mDatabase.child("questions").child(code).once().then((DataSnapshot snapshot){
          Map<dynamic,dynamic> currentQuestion = snapshot.value;
          newVotes = currentQuestion['votes'] + int.parse(param);
          mDatabase.child("questions").child(code).update({
          'votes': newVotes,
          }).then((_){
            actionOnFieldFrom("questionsPerLesson",lesson,code,"question","votes",newVotes,"i","update");  
          });
        });       
        break;        
      }
    }    
  }

  static Future<void> updateLesson(String code, String param, String column) async{
    DatabaseReference lesson;
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
      case "date": {
        await mDatabase.child("lessons").child(code).update({
          'date': int.parse(param), 
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

  static Future<void> updateCourse(String code, String param, String column) async{
    DatabaseReference course;
    switch(column){
      case "participant": {
        int participants = int.parse(param);
        course = await mDatabase.child("courses").child(code).update({
          'participants': participants + 1,
        }).then((_){/*nothing*/});        
        break;
      }
      case "accessCode": {
         course = await mDatabase.child("courses").child(code).update({
          'accessCode': param,
        }).then((_){/*nothing*/});       
        break;
      }
      case "lessons": {
        await mDatabase.child("courses").child(code).once().then((DataSnapshot snapshot){
          Map<dynamic,dynamic> currentCourse = snapshot.value;
          mDatabase.child("courses").child(code).update({
          'lessons': currentCourse['lessons'] + 1,
          }).then((_){/*nothing*/});
        });       
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
        // addUserPerCourse(uid,code);
        addCoursePerUser(uid,code);
        updateCourse(code,(participants).toString(),"participants");
        _course = {
          'accessCode': course['accessCode'],
          'participants': participants,
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
          }
        }
      }
    }
    return data;
  }

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

   static Future<bool> getVotesToUserPerAnswer(String uid, String answer) async{
    bool voted = false;
    try{
      await mDatabase.child("votesToUserPerAnswer").child(uid).child(answer).once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> map = snapshot.value;
        if(map != null){
          map.forEach((key, val) {
            voted = val['voted'];
          });
        }
      }); 
    }catch(e){
      print("error getVotesToUserPerAnswer: $e");
    } 
    return voted;
  }  

  static Future<List<Answer>> getAnswersPerQuestionByList(List<String> listString, String questionId) async{
    List<Answer> _answersList = List<Answer>();
    try{
      for (var eachAnswer in listString) {
        await mDatabase.child("answers").child(eachAnswer).once().then((DataSnapshot snapshot) {
          Map<dynamic,dynamic> answer = snapshot.value;
          if(answer != null){
            _answersList.add(
              Answer( 
                answerId: snapshot.key,
                questionId: questionId,
                text: answer['text'],
                author: answer['author'],
                authorId: answer['authorId'],
                // day: answer['day'],
                // month: answer['month'],
                // year: answer['year'],
                // hours: answer['hours'],
                // minutes: answer['minutes'],                
                votes: answer['votes'],
              )
            );  
          }    
        }); 
      }
    }catch(e){
      print("error getAnswersPerLessonByList: $e");
    } 
    return _answersList;
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
    List<Lesson> _lessonsList = List<Lesson>();
    bool userOwner;
    try{
      for (var eachLesson in listString) {
        await mDatabase.child("lessons").child(eachLesson).once().then((DataSnapshot snapshot) {
          Map<dynamic,dynamic> lesson = snapshot.value;
          if(lesson != null){
            if(lesson['authorId'] == uid) userOwner = true;
            else userOwner = false;
            String date = (lesson['date']).toString();
            _lessonsList.add(
              Lesson(
                presentation: lesson['presentation'],
                lessonId: eachLesson,
                courseId: courseId,
                comments: lesson['comments'],
                day: int.parse(date.substring(0,2)),
                month: int.parse(date.substring(2,4)),
                year: int.parse(date.substring(5,date.length)),
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
    return _lessonsList;
  } 

  static Future<List<Course>> getCoursesPerUserByList(List<String> listString, String uid) async{
    List<Course> _coursesList = List<Course>();
    bool userOwner;
    try{
      for (var eachCourse in listString) {
        await mDatabase.child("courses").child(eachCourse).once().then((DataSnapshot snapshot) {
          Map<dynamic,dynamic> course = snapshot.value;
          if(course != null){
            if(course['authorId'] == uid) userOwner = true;
            else userOwner = false;
            _coursesList.add(
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
    return _coursesList;
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
    List<String> _lessonsList = List<String>();
    try{
      await mDatabase.child("lessonsPerCourse").child(course).once().then((DataSnapshot snapshot) {
        Map<dynamic,dynamic> map = snapshot.value;
        if(map != null){
          map.forEach((key, lesson) {
            if(map != null){
              _lessonsList.add(lesson['lesson']);  
            }      
          });
        }
      }); 
    }catch(e){
      print("error getLessonsPerUser: $e");
    } 
    return _lessonsList;
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
                  courseId: course['accessCode'],
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