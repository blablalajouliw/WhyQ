

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
    
    func readCreatedQuizzes() async throws -> [Quiz]? {
        var quizName: String = ""
        var quiz: Quiz = Quiz()
        var questions: [Question] = []
        var quizzesUnwrapped: [Quiz] = []
        guard let user = Auth.auth().currentUser else {
            print("No current user is logged in")
            return nil
        }
        
        let quizzesCreated = try await Firestore.firestore().collection("users").document(user.uid).collection("quizzes_created").getDocuments()
        
        for quizCreated in quizzesCreated.documents {
            quizName = quizCreated.documentID
            let quizData = quizCreated.data()
            let nbOfQuestions = quizData["nb_of_questions"] as? Int ?? 3
            
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
                
                print("\(questionInfo)")
                print("\(prompt)")
                print("\(questionAnswered)")
            }
            
            
            guard let difficultyLevel = quizData["difficulty_level"] as? String,
                  let grade = quizData["grade"] as? Int,
                  //let points = quizData["points"] as? Int,
                  let subject = quizData["subject"] as? String else {
                continue
            }
            
            quiz = Quiz(difficultyLevel: difficultyLevel, grade: grade, questions: questions, nbOfQuestions: nbOfQuestions, subject: subject, name: quizName, lastTimePlayed: Date())
            
            quizzesUnwrapped.append(quiz)
            
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
            
            for question in questions {
                for n in 1...questions.count {
                    let question1 = Question(prompt: question.prompt, answers: question.answers, questionAnswered: question.questionAnswered, correctAnswer: question.correctAnswer)
                    
                    
                    let questionDetails: [String: Any] = [
                        "question_\(n)": [
                            "answers": question1.answers,
                            "correct_answer": Array(question1.correctAnswer),
                            "prompt": question1.prompt,
                            "question_answered": question1.questionAnswered
                        ]
                    ]
                    
                    do {
                        try await Firestore.firestore().collection("users").document(user.uid).collection("quizzes_created").document(quizName).updateData(questionDetails)
                    } catch {
                        print("error: \(error.localizedDescription)")
                    }
                    
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
        chosenQuiz = Quiz(difficultyLevel: difficultyLevel, grade: grade, questions: questions, nbOfQuestions: questions.count, subject: subject, name: quizName)
        return chosenQuiz
    }
    
    func editQuiz(chosenQuiz: Quiz, newName: String, newGrade: Int, newQuestions: [Question], newSubject: String, newNbOfQuestions: Int, newDifficultyLevel: String) async throws { // Still a work in progress
        var questions: [Question] = []
        var dataUpdates = [String: Any]()
        
        guard let user = Auth.auth().currentUser else {
            print("No current user is logged in")
            return
        }
        
        if let quiz = try await Firestore.firestore().collection("users").document("\(user.uid)").collection("quizzes_created").document(chosenQuiz.name).getDocument().data() {
            if newGrade != quiz["grade"] as? Int {
                dataUpdates["grade"] = newGrade
            }
            if newSubject != quiz["subject"] as? String {
                dataUpdates["subject"] = newSubject
            }
            if newDifficultyLevel != quiz["difficulty_level"] as? String {
                dataUpdates["difficulty_level"] = newDifficultyLevel
            }
            if newNbOfQuestions != quiz["nb_of_questions"] as? Int {
                dataUpdates["nb_of_questions"] = newNbOfQuestions
            }
            
            for n in 1...newNbOfQuestions { // See if this actually works, what value does it take if the user has not changed anything?
                if let question = quiz["question_\(n)"] as? [String: Any] {
                    for newQuestion in newQuestions {
                        for (key, value) in zip(newQuestion.answers, question["answers"] as? [String: Any] ?? ["": ""]) {
                            print(key)
                            print(value)
                        }
                        
                    }
                }
                
                //let question1 = Question(prompt: prompt, answers: answers, questionAnswered: questionAnswered, correctAnswer: correctAnswers)
                //questions.append(question1)
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

        
        /*func saveFirstQuizDetails(quizName: String, grade: Int, subject: String, difficultyLevel: String) async throws { // The details will be saved in two distinct phases: saving the details selected on the first screen, then moving on to the 2nd screen after a condition is verified
         
         guard let user = Auth.auth().currentUser else {
         print("No current user is logged in")
         return
         }
         
         
         // For "if the quiz was already created" I don't think we should deal with it, unless there could be some errors with quizzes being created more than once.
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
         func saveQuestions(quizName: String, questions: [Question]) async throws { // The details will be saved in two distinct phases: saving the details selected on the first screen, then moving on to the 2nd screen after a condition is verified
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
        
        /*func readQuestions() async throws -> [Question]? { //pass in quiz name to generalize it
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
        
        //The only thing the user won't be able to change is the quiz name
        
    
 
