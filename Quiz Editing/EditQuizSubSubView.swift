

import SwiftUI


/*struct QuestionPrompt: Identifiable {
    let id = UUID()
    var userQuestion: String
 } */

struct EditQuizSubSubView: View {
    //@Binding var question: Question
    let question: Question
    @State private var questionPrompt: String = ""
    @State private var answers: [String: Any] = [:]
    @State private var promptEditAlert: Bool = false
    //@State private var userQuestions: [QuestionPrompt] = []
    @Binding var questions: [Question]
    @Binding var showSheet: Bool
    @Binding var correctAnswers: Set<String>
    
    var body: some View {
        Button("\(question.prompt)") {
            promptEditAlert.toggle()
        }
        ForEach(Array(question.answers), id: \.key) { answer in
            Button("\(answer.key)") {
                showSheet.toggle()
                answers = question.answers
                correctAnswers = Set(question.correctAnswer)
            }
        }
        /*VStack(alignment: .leading) {
            Button("Save question") {
                question = Question(prompt: questionPrompt, answers: answers, questionAnswered: false, correctAnswer: correctAnswers)
                
                questions.append(question)
            }
            
            Text("Click to save the question")
                .font(.caption)
                .foregroundStyle(.gray)
        }
         */
        .onAppear {
            answers = question.answers
            
            
        }
        .alert("Enter your new question prompt", isPresented: $promptEditAlert) {
            TextField("\(question.prompt)", text: $questionPrompt)
            Button("Save") {
                
                questions.append(Question(prompt: questionPrompt, answers: question.answers, questionAnswered: false, correctAnswer: question.correctAnswer))
                questions.removeAll { $0.prompt == question.prompt }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

#Preview {
    EditQuizSubSubView(question: Question(questionAnswered: false), questions: .constant([]), showSheet: .constant(false), correctAnswers: .constant([]))
}
