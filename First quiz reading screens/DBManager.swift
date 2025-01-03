

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


struct Question: Identifiable {
    
    let prompt: String
    let answers: [String: Any]
    var questionAnswered: Bool
    let correctAnswer: Set<String>
    let id = UUID()
    
    init(prompt: String = "", answers: [String: Any] = ["": ""], questionAnswered: Bool, correctAnswer: Set<String> = []) {
        self.prompt = prompt
        self.answers = answers
        self.questionAnswered = questionAnswered
        self.correctAnswer = correctAnswer
    }
}

final class DataBase: ObservableObject {
    var userAnswer: Set<String>? = []
    var correctAnswer: Set<String>? = []
    var quizChosen: String = ""
    var quizNames: [String] = [""]
    var questionAnswered: Bool? = nil
    @Published var question: Question = Question(questionAnswered: false)
    @Published var score: Int = 0
    @Published var correctQuestions: [String] = []
    @Published var missedQuestions: [String] = []
    @Published var questionsAnswered: [Question] = []
    
    
    func readQuizNames() async throws -> [String]? {
        quizNames = [""]
        do {
            let snapshot = try await Firestore.firestore().collection("New questions").document("collection_names").getDocument()
            if let quizzes = snapshot.data() {
                
                for (quizName, _) in quizzes {
                    
                    quizNames.append(quizName)
                }
                
            }
        } catch {
            print("No quizzes were found.")
        }
        return quizNames
    }
    
    
    func readQuestions(quizName: String) async throws -> [Question]? {
        
        var questions: [Question] = []
        let questionAnswered = false
        
        do {
            
            let snapshot = try await Firestore.firestore().collection("New questions").document("question_bank").collection("\(quizName)").getDocuments()
            
            
            for document in snapshot.documents {
                let data = document.data()
                
                guard let prompt = data["prompt"] as? String,
                      let _ = data["question_answered"] as? Bool,
                      let answers = data["answers"] as? [String: Any],
                      let correctAnswer1 = data["correct_answer"] as? [String] else {
                    
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
                let correctAnswer = Set(correctAnswer1)
                
                
                let question = Question(prompt: prompt, answers: answers, questionAnswered: questionAnswered, correctAnswer: correctAnswer)
                
                questions.append(question)
                
            }
            
        } catch {
            print("Couldn't find any data: \(error.localizedDescription)")
            
        }
        
        return questions
    }
    
    func checkUserAnswer(currentQuestion: Question, userAnswer: Set<String>, correctQuestions1: [String], missedQuestions1: [String], questionsAnswered1: [Question]) async throws -> ([Question], Set<String>, Int, [String], [String]) {
        
        question = currentQuestion
        correctQuestions = correctQuestions1
        missedQuestions = missedQuestions1
        questionsAnswered = questionsAnswered1
       
        if userAnswer != [] {
            question.questionAnswered = true
            
            for _ in Array(question.correctAnswer) {
                if userAnswer == question.correctAnswer {
                    score += 1
                    correctQuestions.append(question.prompt)
                } else {
                    missedQuestions.append(question.prompt)
                }
            }
        }
        if question.questionAnswered {
            questionsAnswered.append(question)
            
        }
        print(score)
        return (questionsAnswered, userAnswer, score, missedQuestions, correctQuestions)
    }
    
    
    
    func storeUserAnswers(quizName: String) async throws {
        guard let user = Auth.auth().currentUser else {
            print("No current user is logged in")
            return
        }
        let correctQuestions = try await checkUserAnswer(currentQuestion: question, userAnswer: userAnswer ?? [], correctQuestions1: correctQuestions, missedQuestions1: missedQuestions, questionsAnswered1: questionsAnswered).4
        
        
        let missedQuestions = try await checkUserAnswer(currentQuestion: question, userAnswer: userAnswer ?? [], correctQuestions1: correctQuestions, missedQuestions1: missedQuestions, questionsAnswered1: questionsAnswered).3
        
        let userScore = try await checkUserAnswer(currentQuestion: question, userAnswer: userAnswer ?? [], correctQuestions1: correctQuestions, missedQuestions1: missedQuestions, questionsAnswered1: questionsAnswered).2
        
        
        /*let quizActivity: [String: Any] = [
         "quizName" : [
         "missed_questions" : missedQuestions,
         "correct_questions" : correctQuestions
         ]
         ]
         */
        
        do {
            try await Firestore.firestore().collection("users").document(user.uid).collection("quiz_activity").document(quizName).updateData([
                "\(Date.now)" : [
                    "missed_questions" : missedQuestions,
                    "correct_questions" : correctQuestions,
                    "user_score": userScore
                    ]
            ])
            print("Document successfully written!")
        } catch {
            print("Couldn't add the data: \(error.localizedDescription)")
        }
        print("Created document")
    }
}
     

    /*func didUserAnswerQuestion() {
                //var snapshot: [QuerySnapshot]? = nil
        if questionAnswered ?? false {
                    Firestore.firestore().collection("New questions").document("question_bank").collection("quiz_1").getDocuments() { (querySnapshot, error) in
                        if let error {
                            print("Error getting documents: \(error)")
                        } else {
                            for question in querySnapshot!.documents {
                                if let question1 = question["question_1"] {
                                    print(question1)
                                }
                            }
                        }
                    }
                    
                    Firestore.firestore().collection("New questions").document("question_bank").collection("quiz_2").getDocuments() {
                        (querySnapshot, error) in
                        if let error {
                            print("Error getting documents: \(error)")
                        } else {
                            for question in querySnapshot!.documents {
                                if let question1 = question["question_1"] {
                                    print(question1)
     }
                            }
                        }
                        
                    }
                }
            }
        }
     */

/*struct Answer {
    let options: [String]
    let value: String
    let correct: Bool
    
    init(options: [String], value: String, correct: Bool) {
        self.options = options
        self.value = value
        self.correct = correct
    }
}
 */

/*func writeQuestions() async {
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
}
 */
 
