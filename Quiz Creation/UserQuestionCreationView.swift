
import SwiftUI

struct UserQuestionCreationView: View {
    @StateObject var quizCreation = QuizCreationManager()
    
    @State private var showQuestionCreationScreen = false
    @State private var showQuizPanel = false
    @State private var showChosenQuizQuestions = false
    
    @Binding var questions: [Question]
    @Binding var quizName: String
    @Binding var quizSubject: String
    @Binding var grade: Int
    @Binding var difficultyLevel: String
    @Binding var quizzesCreated: [Quiz]
    @Binding var chosenQuiz: Quiz
    
    func showCreatedQuestions(chosenQuiz: Quiz) {
        print("\(chosenQuiz.questions)")
        let questions = chosenQuiz.questions
        for question in questions {
            if question.prompt != "" {
                showChosenQuizQuestions.toggle()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            if !showQuizPanel {
                Form {
                    if !questions.isEmpty {
                        Section {
                            ForEach(questions, id: \.id) { question in
                                HStack {
                                    Button(question.prompt) {
                                        //Add view that shows the question's details, and a possibility to edit
                                    }
                                }
                            }
                        }
                        Spacer() // See how it looks like on an actual build
                        VStack {
                            Button("Save Quiz") {
                                Task {
                                    
                                    chosenQuiz = try await quizCreation.saveQuiz(quizName: quizName, questions: questions, grade: grade, subject: quizSubject, difficultyLevel: difficultyLevel) ?? Quiz()
                                }
                                print(questions.count)
                                showQuizPanel.toggle()
                                
                            }
                        }
                    }
                    if showChosenQuizQuestions {
                        
                        Section {
                            ForEach(chosenQuiz.questions, id: \.id) { question in
                                HStack {
                                    Button(question.prompt) {
                                        //Add view that shows the question's details, and maybe a possibility to edit
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
                                showQuizPanel.toggle()
                                
                            }
                        }
                    }
                }
                
                
                .navigationTitle("Question creation")
                .sheet(isPresented: $showQuestionCreationScreen) {
                    UserQuestionCreationDetailsView(showQuestionCreationScreen: $showQuestionCreationScreen, questions: $questions, quizzesCreated: $quizzesCreated)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add question", systemImage: "plus") {
                            showQuestionCreationScreen.toggle()
                        }
                        
                    }
                }
                .onAppear {
                    showCreatedQuestions(chosenQuiz: chosenQuiz)
                }
            } else {
                QuizzesCreatedPanel(quizCreation: quizCreation)
                
            }
        }
    }
}

#Preview {
    UserQuestionCreationView(questions: .constant([Question(questionAnswered: false)]), quizName: .constant(""), quizSubject: .constant(""), grade: .constant(0), difficultyLevel: .constant(""), quizzesCreated: .constant([]), chosenQuiz: .constant(Quiz()))
}
