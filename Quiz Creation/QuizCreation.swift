

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct Quiz {
    let difficultyLevel: String
    let points: Int
    let grade: Int
    let questions: [Question]
    let nbOfQuestions: Int
    let subject: String
    let name: String
    let lastTimePlayed: Date
    let id = UUID()
    
    init(difficultyLevel: String = "", points: Int = 0, grade: Int = 0, questions: [Question] = [Question(questionAnswered: false)], nbOfQuestions: Int = 0 , subject: String = "", name: String = "", lastTimePlayed: Date = Date()) {
        self.difficultyLevel = difficultyLevel
        self.points = points
        self.grade = grade
        self.questions = questions
        self.nbOfQuestions = nbOfQuestions
        self.subject = subject
        self.name = name
        self.lastTimePlayed = lastTimePlayed
    }
}

final class QuizCreationManager: ObservableObject {
    @Published var chosenQuiz: Quiz = Quiz()
    @Published var createdQuizzes = [Quiz]()
    
    func readCreatedQuizzes() async throws -> [Quiz]? {
        var quizName: String = ""
        var quiz: Quiz = Quiz()
        var questions: [Question] = []
        var quizzesUnwrapped: [Quiz] = []
        guard let user = Auth.auth().currentUser else {
            print("No current user is logged in.")
            return nil
        }
        
        let quizzesCreated = try await Firestore.firestore().collection("users").document(user.uid).collection("quizzes_created").getDocuments()
        
        for quizCreated in quizzesCreated.documents {
            quizName = quizCreated.documentID
            let quizData = quizCreated.data()
            
            //print("\(quizCreated.data())")
            
            var nbOfQuestions = quizData["nb_of_questions"] as? Int ?? 3
            if nbOfQuestions != 0 {
                
                for n in 1...nbOfQuestions {
                    let questionInfo = quizData["question_\(n)"] as? [String: Any] ?? ["": ""]
                    
                    guard let prompt = questionInfo["prompt"] as? String,
                          let questionAnswered = questionInfo["question_answered"] as? Bool,
                          let answers = questionInfo["answers"] as? [String: Any],
                          let correctAnswer = questionInfo["correct_answer"] as? [String] else {
                        continue
                    }
                    let question = Question(prompt: prompt, answers: answers, questionAnswered: questionAnswered, correctAnswer: Set(correctAnswer))
                    questions.append(question)
                    
                }
            }
            
            
            guard let difficultyLevel = quizData["difficulty_level"] as? String,
                  let grade = quizData["grade"] as? Int,
                  //let points = quizData["points"] as? Int,
                  let subject = quizData["subject"] as? String else {
                continue
            }
            
            quiz = Quiz(difficultyLevel: difficultyLevel, grade: grade, questions: questions, nbOfQuestions: nbOfQuestions, subject: subject, name: quizName, lastTimePlayed: Date())
            
            quizzesUnwrapped.append(quiz)
            questions = []
        }
        
        return (quizzesUnwrapped)
    }
    
    
    
    func saveQuiz(quizName: String, questions: [Question], grade: Int, subject: String, difficultyLevel: String) async throws -> Quiz? {
        
        //let nbOfQuestions = questions.count
        guard let user = Auth.auth().currentUser else {
            print("No current user is logged in")
            return nil
        }
        
        
        if let quizData = try await Firestore.firestore().collection("users").document("\(user.uid)").collection("quizzes_created").document(quizName).getDocument().data() {
            
            //print("\(nbOfQuestions)")
            guard let _ = quizData["grade"] as? Int,
                  let _ = quizData["subject"] as? String,
                  let _ = quizData["difficulty_level"] as? String else {
                return nil
            }
            do {
                try await Firestore.firestore().collection("users").document("\(user.uid)").collection("quizzes_created").document(quizName).updateData([
                    "nb_of_questions": questions.count
                ])
            } catch {
                print("Could not complete the data.")
            }
            
           
                for (n, question) in zip(1...questions.count, questions) {
                    let question1 = Question(prompt: question.prompt, answers: question.answers, questionAnswered: question.questionAnswered, correctAnswer: question.correctAnswer)
                    print("\(question1)")
                    
                    let questionNB: String = "question_\(n)"
                    let questionDetails: [String: Any] = [
                        "answers": question1.answers,
                        "correct_answer": Array(question1.correctAnswer),
                        "prompt": question1.prompt,
                        "question_answered": question1.questionAnswered
                    ]
                    
                    do {
                        try await Firestore.firestore().collection("users").document(user.uid).collection("quizzes_created").document(quizName).updateData([questionNB: questionDetails])
                    } catch {
                        print("error: \(error.localizedDescription)")
                    }
                    
                }
           
            
        } else {
            let firstQuizDetails: [String: Any] = [
                "grade": grade,
                "subject": subject,
                "difficulty_level": difficultyLevel
            ]
            
            do {
                let _: Void = try await Firestore.firestore().collection("users").document(user.uid).collection("quizzes_created").document("\(quizName)").setData(firstQuizDetails)
                
                
            } catch {
                print("Document could not be created: \(error.localizedDescription)")
            }
            
        }
        print("\(questions)")
        print("\(questions.count)")
        chosenQuiz = Quiz(difficultyLevel: difficultyLevel, grade: grade, questions: questions, nbOfQuestions: questions.count, subject: subject, name: quizName)
        return chosenQuiz
    }
    
    func editQuiz(chosenQuiz: Quiz) async throws {
        var questions: [Question] = []
        var dataUpdates = [String: Any]()
        var updatedPrompt = [String: Any]()
        var updatedAnswers = [String: Any]()
        var updatedCorrectAnswers = [String: [String]]()
        var updatedQuestion = [String: Any]()
        
        guard let user = Auth.auth().currentUser else {
            print("No current user is logged in")
            return
        }
        
        
        if let quiz = try await Firestore.firestore().collection("users").document("\(user.uid)").collection("quizzes_created").document(chosenQuiz.name).getDocument().data() {
            
            if chosenQuiz.grade != quiz["grade"] as? Int {
                
                dataUpdates["grade"] = chosenQuiz.grade
            }
            if chosenQuiz.subject != quiz["subject"] as? String {
               
                dataUpdates["subject"] = chosenQuiz.subject
            }
            if chosenQuiz.difficultyLevel != quiz["difficulty_level"] as? String {
               
                dataUpdates["difficulty_level"] = chosenQuiz.difficultyLevel
            }
            if chosenQuiz.nbOfQuestions != quiz["nb_of_questions"] as? Int {
                
                dataUpdates["nb_of_questions"] = chosenQuiz.nbOfQuestions
            }
            try await Firestore.firestore().collection("users").document("\(user.uid)").collection("quizzes_created").document(chosenQuiz.name).updateData(dataUpdates)
            //print("\(dataUpdates)")
            
            for n in 1...chosenQuiz.nbOfQuestions {
                print("\(1)")
                if let question = quiz["question_\(n)"] as? [String: Any] {
                    
                    for newQuestion in chosenQuiz.questions {
                        if newQuestion.prompt != question["prompt"] as? String {
                        
                            updatedPrompt["prompt"] = newQuestion.prompt
                            
                        } else {
                            updatedPrompt["prompt"] = question["prompt"] as? String
                        }
                        
                        print("\(newQuestion.answers)")
                        print("\(question["answers"] ?? [:])")
                        for (answer1, answer2) in zip(newQuestion.answers, question["answers"] as? [String: Bool] ?? ["": false]) {
                            if answer1.key != answer2.key {
                                updatedAnswers["\(answer1.key)"] = answer1.value as? Bool
                                print("\(updatedAnswers)")
                                
                            } else {
                                updatedAnswers["answers"] = question["answers"] as? [String: Bool]
                            }
                            
                        }
                        for (correctAnswer1, correctAnswer2) in zip(newQuestion.correctAnswer, question["correct_answer"] as? [String] ?? [""]) {
                            if correctAnswer1 != correctAnswer2 {
                                updatedCorrectAnswers["correct_answer"] = Array(newQuestion.correctAnswer)
                                print("\(updatedCorrectAnswers)")
                                
                            } else {
                                updatedCorrectAnswers["correct_answer"] = question["correct_answer"] as? [String]
                            }
                            
                        }
                        updatedQuestion = [
                            "question_\(n)": [
                                "prompt": updatedPrompt["prompt"],
                                "answers": updatedAnswers["answers"],
                                "correct_answers": updatedCorrectAnswers["correct_answers"]
                            ]
                        ]
                        try await Firestore.firestore().collection("users").document("\(user.uid)").collection("quizzes_created").document(chosenQuiz.name).updateData(updatedQuestion)
                    }
                }
                
                //let question1 = Question(prompt: prompt, answers: answers, questionAnswered: questionAnswered, correctAnswer: correctAnswers)
                //questions.append(question1)
            }
            
        }
        
    }
    func deleteQuiz(createdQuizzes: [Quiz]) async throws {
        var retrievedQuizNames = [String]()
        var createdQuizNames = [String]()
        
        guard let user = Auth.auth().currentUser else {
            print("No current user is logged in")
            return
        }
        
        for createdQuiz in createdQuizzes {
            createdQuizNames.append(createdQuiz.name)
        }
        
        let snapshot = try await Firestore.firestore().collection("users").document("\(user.uid)").collection("quizzes_created").getDocuments()
        for document in snapshot.documents {
            retrievedQuizNames.append(document.documentID)
        }
        
        let deletedQuizNames = retrievedQuizNames.filter { !createdQuizNames.contains($0) }
        for deletedQuizName in deletedQuizNames {
            try await Firestore.firestore().collection("users").document("\(user.uid)").collection("quizzes_created").document(deletedQuizName).delete()
            /*{ error in
                if let error = error {
                    print("Error deleting document: \(error.localizedDescription)")
                    
                } else {
                    print("Document successfully deleted!")
                    
                }
            }
             */
             
        }
        
        for (retrievedQuizName, createdQuizName) in zip(retrievedQuizNames, createdQuizNames) {
            if retrievedQuizName != createdQuizName {
                
            }
        }
            
    }
    
}

/* func writeQuestions() async {
 do {
     
     let quizCreated: [String: Any] = [
         "quiz_name" : [
             "1": [
                 "prompt": "",
                 "answers": [
                     
                 ],
                 "correct_answer": ""
             ]
         ]
     ]
     let ref = try await Firestore.firestore().collection("New questions").addDocument(data: quizCreated)
     print("Document added with ID: \(ref.documentID)")
 } catch {
     print("Error adding document: \(error)")
 }
}*/

        
        /*func saveFirstQuizDetails(quizName: String, grade: Int, subject: String, difficultyLevel: String) async throws {
         
         guard let user = Auth.auth().currentUser else {
         print("No current user is logged in")
         return
         }
         
         
         
         let firstQuizDetails: [String: Any] = [
         "grade": grade,
         "subject": subject,
         "difficulty_level": difficultyLevel
         ]
         do {
         let _: Void = try await Firestore.firestore().collection("users").document(user.uid).collection("quizzes_created").document("\(quizName)").setData(firstQuizDetails)
         } catch {
         print("Document could not be created: \(error.localizedDescription)")
         }
         }
         func saveQuestions(quizName: String, questions: [Question]) async throws {
         let nbOfQuestions = questions.count
         guard let user = Auth.auth().currentUser else {
         print("No current user is logged in")
         return
         }
         
         for question in questions {
         for n in 1...nbOfQuestions {
         let question1 = Question(prompt: question.prompt, answers: question.answers, questionAnswered: question.questionAnswered, correctAnswer: question.correctAnswer)
         
         let questionDetails: [String: Any] = [
         "question_1": [
         "answers": question1.answers,
         "correct_answer": question1.correctAnswer,
         "prompt": question1.prompt,
         "question_answered": question1.questionAnswered
         ]
         ]
         
         let _: Void = try await Firestore.firestore().collection("users").document(user.uid).collection("quizzes_created").document(quizName).setData(questionDetails)
         }
         }
         }
         */
        
        /*func readQuestions() async throws -> [Question]? { 
            var questions: [Question] = []
            let questionAnswered = false
            let _: Quiz = Quiz()
            
            do {
                
                let snapshot = try await Firestore.firestore().collection("New questions").document("question_bank").collection("quiz_1").getDocuments()
                
                
                for document in snapshot.documents {
                    let data = document.data()
                    
                    
                    guard let prompt = data["prompt"] as? String,
                          let _ = data["question_answered"] as? Bool,
                          let answers = data["answers"] as? [String: Any],
                          let correctAnswer = data["correct_answer"] as? Set<String> else {
                        
                        continue
                    }
                    
                    /*for letter in letters {
                     if let answer = answers["\(letter)"] as? [String: Bool] {
                     for (key, value) in answer {
                     if value == true {
                     correctAnswers.append(key)
                     
                     }
                     }
                     */
                    
                    
                    let question = Question(prompt: prompt, answers: answers, questionAnswered: questionAnswered, correctAnswer: correctAnswer)
                    
                    questions.append(question)
                }
                
            } catch {
                print("Couldn't find any data: \(error.localizedDescription)")
                
            }
            
            return questions
        } */
        
        
        
    
 
