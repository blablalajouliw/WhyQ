

import SwiftUI

struct QuizzesCreatedPanel: View {
    @StateObject var quizCreation = QuizCreationManager()
    @State private var createdQuizzes: [Quiz] = [Quiz()]
    @State private var chosenQuiz: Quiz = Quiz()
    
    
    var body: some View {
        NavigationStack {
            Form {
                List{
                    ForEach(createdQuizzes, id: \.id) { createdQuiz in
                        
                        NavigationLink(destination: QuizPreview(chosenQuiz: $chosenQuiz, quizzesCreated: $createdQuizzes)) {
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
                                    
                                    Text("subject: \(createdQuiz.questions)")
                                }
                            }
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            chosenQuiz = createdQuiz
                           
                        })
                    
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        UserQuizCreationView(quizzesCreated: $createdQuizzes, chosenQuiz: $chosenQuiz)
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                    
                }
            }
        }
        .onAppear {
            Task {
                createdQuizzes = try await quizCreation.readCreatedQuizzes() ?? []
                //try await quizCreation.readCreatedQuizzes() ?? []
                
            }
           
            
        }
    }
}



#Preview {
    NavigationStack {
        QuizzesCreatedPanel()
    }
}
