

import SwiftUI

struct QuizSubView: View {
    
    @Binding var userAnswered: Bool
    @State private var userAnswer: String = ""
    @Binding var questions: [Question]
    let answers: [String: [String: Bool]]
    let question: Question
    
    @Binding var showAlert2: Bool
    @Binding var missedQuestions: [String]
    @Binding var correctQuestions: [String]
    @Binding var quizChosen: String
    @ObservedObject var databaseManager: DataBase
    
    
    var body: some View {
        
        ForEach(Array(answers.keys), id: \.self) { key in
            if let correct = answers[key] {
                QuizSubSubView(correct: correct, question: question, userScore: $databaseManager.score, questions: $questions, showAlert2: $showAlert2, missedQuestions: $databaseManager.missedQuestions, correctQuestions: $databaseManager.correctQuestions, quizChosen: $quizChosen, databaseManager: databaseManager)
            } else {
                
            }
        }
                .onAppear {
                    /*Task {
                        let result = try await databaseManager.readQuestions()
                                questions = result
                    
                    
                        try await databaseManager.didUserAnswerQuestion()
                    }
                     */
                }
            }
        }

#Preview {
    QuizSubView(userAnswered: .constant(false), questions: .constant([]), answers: ["": ["": false]], question: Question(questionAnswered: false), showAlert2: .constant(false), missedQuestions: .constant([]), correctQuestions: .constant([]), quizChosen: .constant(""), databaseManager: DataBase())
}
