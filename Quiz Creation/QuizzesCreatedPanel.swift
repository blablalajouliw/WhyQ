

import SwiftUI

struct QuizzesCreatedPanel: View {
    @ObservedObject var quizCreation = QuizCreationManager()
    @State private var createdQuizzes: [Quiz] = []
    @State private var chosenQuiz: Quiz = Quiz()
    @State private var deleteQuiz: Bool = false
    @State private var deleteIndexSet: IndexSet? = nil
    @State private var quizzesPanelAppear: Bool = true
    
    func deleteOption(at indice: IndexSet) async throws {
        quizCreation.createdQuizzes.remove(atOffsets: indice)
        try await quizCreation.deleteQuiz(createdQuizzes: quizCreation.createdQuizzes)
    }
    
    var body: some View {
        NavigationStack {
            if quizzesPanelAppear {
                Form {
                    List{
                        ForEach(quizCreation.createdQuizzes, id: \.id) { createdQuiz in
                            QCPSubview(createdQuizzes: $createdQuizzes, createdQuiz: createdQuiz, chosenQuiz: $chosenQuiz)
                        }
                        
                        .onDelete { createdQuiz in
                            deleteIndexSet = createdQuiz
                            deleteQuiz.toggle()
                        }
                    }
                    
                }
                .onAppear {
                    chosenQuiz = Quiz()
                    Task {
                        quizCreation.createdQuizzes = try await quizCreation.readCreatedQuizzes() ?? []
                        createdQuizzes = quizCreation.createdQuizzes
                    }
                    
                }
            .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        /*NavigationLink {
                         UserQuizCreationView(quizzesCreated: $createdQuizzes, chosenQuiz: $chosenQuiz, quizzesPanelAppear: $quizzesPanelAppear)
                         */
                        Button {
                            quizzesPanelAppear.toggle()
                        } label: {
                            Image(systemName: "plus")
                                .font(.headline)
                        }
                        
                    }
                }
                .alert("Are you sure you want to delete this quiz?", isPresented: $deleteQuiz) {
                    Button("Delete", role: .destructive) {
                        if let indexSet = deleteIndexSet {
                            Task {
                                try await deleteOption(at: indexSet)
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                }
            } else {
                UserQuizCreationView(quizzesCreated: $createdQuizzes, chosenQuiz: $chosenQuiz, quizzesPanelAppear: $quizzesPanelAppear)
            }
        }
        
    }
}


#Preview {
    NavigationStack {
        QuizzesCreatedPanel()
    }
}
