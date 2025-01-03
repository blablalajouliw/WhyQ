
import SwiftUI

struct UserQuestionCreationView: View {
    @StateObject var quizCreation = QuizCreationManager()
    
    @State private var showQuestionCreationScreen = false
    //@State private var showQuizPanel = false
    @State private var showChosenQuizQuestions = false
    
    @Binding var questions: [Question]
    @Binding var quizName: String
    @Binding var quizSubject: String
    @Binding var grade: Int
    @Binding var difficultyLevel: String
    @Binding var quizzesCreated: [Quiz]
    @Binding var chosenQuiz: Quiz
    @Binding var quizzesPanelAppear: Bool
    
    func showCreatedQuestions(chosenQuiz: Quiz) {
        
        let questions = chosenQuiz.questions
        for question in questions {
            if question.prompt != "" {
                showChosenQuizQuestions.toggle()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            if !quizzesPanelAppear {
                Form {
                    if !questions.isEmpty {
                        Section {
                            ForEach(questions, id: \.id) { question in
                                HStack {
                                    Button(question.prompt) {
                                        //Question details view
                                    }
                                }
                            }
                        }
                        
                        VStack {
                            Button("Save Quiz") {
                                Task {
                                    
                                    chosenQuiz = try await quizCreation.saveQuiz(quizName: quizName, questions: questions, grade: grade, subject: quizSubject, difficultyLevel: difficultyLevel) ?? Quiz()
                                }
                                
                                quizzesPanelAppear.toggle()
                                //quizzesCreated.append(chosenQuiz)
                                
                            }
                        }
                    }
                    if showChosenQuizQuestions {
                        
                        Section {
                            ForEach(chosenQuiz.questions, id: \.id) { question in
                                HStack {
                                    Button(question.prompt) {
                                        //Question details view
                                    }
                                }
                            }
                        }
                        Spacer() 
                        VStack {
                            Button("Save Quiz") {
                                
                                Task {
                                    
                                
                                    try await quizCreation.saveQuiz(quizName: quizName, questions: questions, grade: grade, subject: quizSubject, difficultyLevel: difficultyLevel)
                                }
                                quizzesPanelAppear.toggle()
                                //quizzesCreated.append(chosenQuiz)
                                
                            }
                        }
                    }
                }
                
                
                .navigationTitle("Question creation")
                .sheet(isPresented: $showQuestionCreationScreen) {
                    UserQuestionCreationDetailsView(showQuestionCreationScreen: $showQuestionCreationScreen, questions: $questions, quizzesCreated: $quizzesCreated)
                }
                /*.toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add question", systemImage: "plus") {
                            showQuestionCreationScreen.toggle()
                        }
                        
                    }
                }
                 */
                .onAppear {
                    showCreatedQuestions(chosenQuiz: chosenQuiz)
                }
            } else {
                QuizzesCreatedPanel(quizCreation: quizCreation)
                
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add question", systemImage: "plus") {
                    showQuestionCreationScreen.toggle()
                }
                
            }
        }
    }
}

#Preview {
    UserQuestionCreationView(questions: .constant([Question(questionAnswered: false)]), quizName: .constant(""), quizSubject: .constant(""), grade: .constant(0), difficultyLevel: .constant(""), quizzesCreated: .constant([]), chosenQuiz: .constant(Quiz()), quizzesPanelAppear: .constant(false))
}
