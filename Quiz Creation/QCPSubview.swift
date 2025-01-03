

import SwiftUI

struct QCPSubview: View {
    @Binding var createdQuizzes: [Quiz]
    let createdQuiz: Quiz
    @Binding var chosenQuiz: Quiz
    
    @State private var quizSheetAppear: Bool = false
    
    var body: some View {
        NavigationStack {
            Button {
                if chosenQuiz.name == "" {
                    chosenQuiz = createdQuiz
                    //print("\(chosenQuiz.questions)")
                }
                quizSheetAppear.toggle()
                
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("difficulty level: \(createdQuiz.difficultyLevel)")
                            .font(.headline)
                        Text("grade: \(createdQuiz.grade)")
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("number of questions: \(createdQuiz.nbOfQuestions)")
                            .foregroundStyle(.green)
                        Text("subject: \(createdQuiz.subject)")
                    }
                    VStack(alignment: .trailing) {
                        
                        Text("questions: \(createdQuiz.questions)")
                    }
                }
            }
            
            
        }
        .sheet(isPresented: $quizSheetAppear) {
            QuizPreview(chosenQuiz: $chosenQuiz, quizzesCreated: $createdQuizzes, quizSheetAppear: $quizSheetAppear)
        }
    }
}

#Preview {
    QCPSubview(createdQuizzes: .constant([]), createdQuiz: Quiz(), chosenQuiz: .constant(Quiz()))
}
