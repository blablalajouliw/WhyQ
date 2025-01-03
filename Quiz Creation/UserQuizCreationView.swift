

import SwiftUI

struct UserQuizCreationView: View {
    @StateObject var quizCreationManager = QuizCreationManager()
    
    @Binding var quizzesCreated: [Quiz]
    @Binding var chosenQuiz: Quiz
    @Binding var quizzesPanelAppear: Bool
    
    @State private var quizName: String = ""
    @State private var quizSubject: String = ""
    let quizSubjects: [String] = ["Math", "Physics", "Chemistry", "History", "Geography", "Biology", "French", "English", "Spanish"]
    @State private var grade: Int = 0
    let grades: ClosedRange<Int> = 1...12
    @State private var difficultyLevel: String = ""
    let difficultyLevels: [String] = ["Easy", "Medium", "Advanced", "Expert"]
    
    @State private var questions: [Question] = []
    //@State private var questionPrompt: String = ""
    @State private var answers: [String] = []
    @State private var correctAnswer: String = ""
    
    
    @State private var showAlert: Bool = false
    @State private var navigationLinkActive: Bool = false
    
    var body: some View {
        NavigationStack {
            if !navigationLinkActive && !quizzesPanelAppear {
                VStack(alignment: .leading) {
                    TextField("Enter the quiz name", text: $quizName)
                }
                HStack {
                    Text("For what grade is this quiz designed?")
                        .foregroundStyle(.blue)
                    Spacer()
                    Picker("What grade?", selection: $grade) {
                        ForEach(grades, id: \.self) {
                            Text("\($0)")
                        }
                    }
                }
                HStack {
                    Text("What subject does it relate to?")
                        .foregroundStyle(.blue)
                    Spacer()
                    Picker("What subject?", selection: $quizSubject) {
                        ForEach(quizSubjects, id: \.self) {
                            Text("\($0)")
                        }
                    }
                }
                HStack {
                    Text("How hard is your quiz?")
                        .foregroundStyle(.blue)
                    Spacer()
                    Picker("How hard is your quiz?", selection: $difficultyLevel) {
                        ForEach(difficultyLevels, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    Spacer()
                    HStack {
                        Button("Next") {
                            showAlert.toggle()
                        }
                        
                        Button("Cancel") {
                            quizzesPanelAppear.toggle()
                        }
                    }
                    
                    .alert("Do you want to move on to the next screen?", isPresented: $showAlert) {
                        Text("You will not be able to modify this section again")
                        Button("Cancel", role: .cancel) { }
                        Button("OK") {
                            Task {
                                try await quizzesCreated.append( quizCreationManager.saveQuiz(quizName: quizName, questions: questions, grade: grade, subject: quizSubject, difficultyLevel: difficultyLevel) ?? Quiz())
                            }
                            navigationLinkActive.toggle()
                            
                        }
                        
                    }
                }
            } else if navigationLinkActive && !quizzesPanelAppear {
                UserQuestionCreationView(questions: $questions, quizName: $quizName, quizSubject: $quizSubject, grade: $grade, difficultyLevel: $difficultyLevel, quizzesCreated: $quizzesCreated, chosenQuiz: $chosenQuiz, quizzesPanelAppear: $quizzesPanelAppear)
            }
        }
    }
}

#Preview {
    UserQuizCreationView(quizzesCreated: .constant([]), chosenQuiz: .constant(Quiz()), quizzesPanelAppear: .constant(false))
}
