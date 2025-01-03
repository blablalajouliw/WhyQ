

import SwiftUI

struct QuizView: View {
    @StateObject var databaseManager = DataBase()
    @State private var hasAppeared: Bool = false
    @State private var questions: [Question] = []
    @Binding var quizChosen: String
    
    @State private var showAlert2: Bool = false
    @State private var missedQuestions: [String] = []
    @State private var correctQuestions: [String] = []
    @State private var question: Question = Question(questionAnswered: false)
    @Binding var showProfileView: Bool
    
    var processedQuestions: [Question] {
        
        questions.map { question in
            Question(prompt: question.prompt, answers: question.answers, questionAnswered: question.questionAnswered, correctAnswer: question.correctAnswer)
        }
    }
    
    
    var body: some View {
        
        NavigationStack {
            ForEach(processedQuestions, id: \.id) { processedQuestion in
                Section(header: Text("\(processedQuestion.prompt)")) {
                    
                    QuizSubView(userAnswered: .constant(false), questions: $questions, answers: processedQuestion.answers as? [String: [String: Bool]] ?? ["": ["": false]], question: processedQuestion, showAlert2: $showAlert2, missedQuestions: $missedQuestions, correctQuestions: $correctQuestions, quizChosen: $quizChosen, databaseManager: databaseManager)
                    
                    
                }
            }
            .onAppear {
                if !hasAppeared {
                    hasAppeared = true
                    Task {
                        questions = try await databaseManager.readQuestions(quizName: quizChosen) ?? []
                        
                    }
                }
            }
        }
        .navigationTitle("Quiz")
        .alert("Are you sure you want to submit your quiz ?", isPresented: $showAlert2) {
            
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                print("\(correctQuestions)")
                Task {
                    print(quizChosen)
                    try await databaseManager.storeUserAnswers(quizName: quizChosen)
                }
            }
        }
    }
}
  

#Preview {
    NavigationStack {
        QuizView(quizChosen: .constant(""), showProfileView: .constant(false))
    }
}
