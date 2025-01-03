

import SwiftUI

struct EditQuizSubView: View {
    @State private var isAssigned: Bool = false
    @State private var showSheet: Bool = false
    
    @Binding var questions: [Question]
    @Binding var bindingQuestion: Question
    @Binding var chosenQuiz: Quiz
    //@State private var questionPrompt: String = ""
    @Binding var correctAnswers: Set<String>
    @Binding var answers: [String: Any]
    
    /*var processedQuestions: [Question] {
        
        chosenQuiz.questions.map { question in
            Question(prompt: question.prompt, answers: question.answers, questionAnswered: question.questionAnswered, correctAnswer: question.correctAnswer)
        }
    }
     */
    
    var body: some View {
        ForEach(Array(chosenQuiz.questions), id: \.id) { question in
            
            EditQuizSubSubView(question: question, questions: $questions, showSheet: $showSheet, correctAnswers: $correctAnswers)
                /*.onAppear {
                    if !chosenQuiz.questions.isEmpty && !isAssigned {
                        bindingQuestion = question
                        isAssigned.toggle()
                        print("\(bindingQuestion)")
                    }
                }
                 */
            VStack(alignment: .leading) {
                Button("Save question") {
                    
                    questions.append(question)
                }
                
                Text("Click to save the question")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .sheet(isPresented: $showSheet) {
            EditAnswerOptions(showSheet: $showSheet, answers: $answers, correctAnswers: $correctAnswers, question: $bindingQuestion)
        }
        .onAppear {
            questions = chosenQuiz.questions
            print("\(questions)")
        }
    }
    
}

#Preview {
    EditQuizSubView(questions: .constant([]), bindingQuestion: .constant(Question(questionAnswered: false)), chosenQuiz: .constant(Quiz()), correctAnswers: .constant([]), answers: .constant([:]))
}
