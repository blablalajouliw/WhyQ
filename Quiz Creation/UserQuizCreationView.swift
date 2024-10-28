

import SwiftUI

struct UserQuizCreationView: View {
    @StateObject var quizCreationManager = QuizCreationManager()
    
    @Binding var quizzesCreated: [Quiz]
    @Binding var chosenQuiz: Quiz
    @State private var quizName: String = ""
    @State private var quizSubject: String = ""
    let quizSubjects: [String] = ["Math", "Physics", "Chemistry", "History", "Geography", "Biology", "French", "English", "Spanish"]
    @State private var grade: Int = 0
    let grades: ClosedRange<Int> = 1...12
    @State private var difficultyLevel: String = ""
    let difficultyLevels: [String] = ["Easy", "Medium", "Advanced", "Expert"]
    
    @State private var questions: [Question] = []
    @State private var questionPrompt: String = ""
    @State private var answers: [String] = []
    @State private var correctAnswer: String = ""
    // @State private var questionAnswered // We can't really define that for now, we'll see
    
    @State private var showAlert: Bool = false
    @State private var navigationLinkActive: Bool = false
    
    var body: some View {
        NavigationStack {
            if !navigationLinkActive {
                VStack(alignment: .leading) {
                    if chosenQuiz.name != "" {
                        TextField("\(chosenQuiz.name)", text: $quizName)
                    } else {
                        TextField("Enter the quiz name", text: $quizName)
                    }
                    HStack {
                        if chosenQuiz.grade != 0 {
                            Text("For what grade is this quiz designed?")
                                .foregroundStyle(.blue)
                            Spacer()
                            Picker("What grade?", selection: $grade) {
                                ForEach(grades, id: \.self) { grade1 in
                                    Text("\(chosenQuiz.grade)")
                                }
                            }
                        } else {
                            Text("For what grade is this quiz designed?")
                                .foregroundStyle(.blue)
                            Spacer()
                            Picker("What grade?", selection: $grade) {
                                ForEach(grades, id: \.self) {
                                    Text("\($0)")
                                }
                            }
                        }
                    }
                    HStack {
                        if chosenQuiz.subject != "" {
                            Text("What subject does it relate to?")
                                .foregroundStyle(.blue)
                            Spacer()
                            Picker("What subject?", selection: $quizSubject) {
                                ForEach(quizSubjects, id: \.self) { subject in
                                    Text("\(chosenQuiz.subject)")
                                }
                            }
                        } else {
                            Text("What subject does it relate to?")
                                .foregroundStyle(.blue)
                            Spacer()
                            Picker("What subject?", selection: $quizSubject) {
                                ForEach(quizSubjects, id: \.self) {
                                    Text("\($0)")
                                }
                            }
                        }
                    }
                    HStack {
                        if chosenQuiz.difficultyLevel != "" {
                            Text("How hard is your quiz?")
                                .foregroundStyle(.blue)
                            Spacer()
                            Picker("How hard is your quiz?", selection: $difficultyLevel) {
                                ForEach(difficultyLevels, id: \.self) { level in
                                    Text("\(chosenQuiz.difficultyLevel)")
                                }
                            }
                        } else {
                            Text("How hard is your quiz?")
                                .foregroundStyle(.blue)
                            Spacer()
                            Picker("How hard is your quiz?", selection: $difficultyLevel) {
                                ForEach(difficultyLevels, id: \.self) {
                                    Text("\($0)")
                                }
                            }
                        }
                    }
                    Button("Edit") {
                        print("\(questions)")
                        print("\(chosenQuiz)")
                        print("\(quizName)")
                        print("\(grade)")
                        print("\(quizSubject)")
                        print("\(difficultyLevel)")
                        
                        Task {
                            try await quizCreationManager.editQuiz(chosenQuiz: chosenQuiz, newName: quizName, newGrade: grade, newQuestions: questions, newSubject: quizSubject, newNbOfQuestions: questions.count, newDifficultyLevel: difficultyLevel)
                        }
                    }
                    Spacer()
                    Button("Next") {
                        showAlert.toggle()
                    }
                    
                    .alert("Do you want to move on to the next screen?", isPresented: $showAlert) {
                        Text("You will not be able to modify this section again")
                        Button("OK") {
                            Task {
                                try await quizzesCreated.append( quizCreationManager.saveQuiz(quizName: quizName, questions: questions, grade: grade, subject: quizSubject, difficultyLevel: difficultyLevel) ?? Quiz())
                            }
                            navigationLinkActive.toggle()
                        }
                        
                    }
                }
            } else {
                UserQuestionCreationView(questions: $questions, quizName: $quizName, quizSubject: $quizSubject, grade: $grade, difficultyLevel: $difficultyLevel, quizzesCreated: $quizzesCreated, chosenQuiz: $chosenQuiz)
            }
        }
    }
}

#Preview {
    UserQuizCreationView(quizzesCreated: .constant([]), chosenQuiz: .constant(Quiz()))
}
