//
//  EditQuiz.swift
//  ExperimentingWithFB
//
//  Created by Abla El Kasmi on 29/10/2024.
//

import SwiftUI

struct EditQuiz: View {
    @StateObject var quizCreationManager = QuizCreationManager()
    
    @Binding var chosenQuiz: Quiz
    @State private var quizName: String = ""
    @State private var quizSubject: String = ""
    @State private var grade: Int = 0
    @State private var difficultyLevel: String = ""
    
    let quizSubjects: [String] = ["Math", "Physics", "Chemistry", "History", "Geography", "Biology", "French", "English", "Spanish"]
    let grades: ClosedRange<Int> = 1...12
    let difficultyLevels: [String] = ["Easy", "Medium", "Advanced", "Expert"]
    
    @State private var questions: [Question] = []
    @State private var questionPrompt: String = ""
    @State private var correctAnswer: String = ""
    
    @State private var showSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                TextField("\(chosenQuiz.name)", text: $quizName)
                
                HStack {
                    
                    Text("For what grade is this quiz designed?")
                        .foregroundStyle(.blue)
                    Spacer()
                    Picker("What grade?", selection: $grade) {
                        ForEach(grades, id: \.self) { grade1 in
                            Text("\(grade1)")
                        }
                    }
                    
                }
                HStack {
                    
                    Text("What subject does it relate to?")
                        .foregroundStyle(.blue)
                    Spacer()
                    Picker("What subject?", selection: $quizSubject) {
                        ForEach(quizSubjects, id: \.self) { subject in
                            Text("\(subject)")
                        }
                    }
                    
                }
                HStack {
                    Text("How hard is your quiz?")
                        .foregroundStyle(.blue)
                    Spacer()
                    Picker("How hard is your quiz?", selection: $difficultyLevel) {
                        ForEach(difficultyLevels, id: \.self) { level in
                            Text("\(level)")
                        }
                    }
                }
                ForEach(chosenQuiz.questions, id: \.id) { question in
                    TextField("\(question.prompt)", text: $questionPrompt)
                    ForEach(Array(question.answers), id: \.key) { answer in
                        Button("\(answer.key)") {
                            showSheet.toggle()
                        }
                    }
                    
                }
                
                Spacer()
                Button("Edit") {
                    print("\(questions)")
                    print("\(chosenQuiz)")
                    
                    
                    Task {
                        try await quizCreationManager.editQuiz(chosenQuiz: chosenQuiz, newName: quizName, newGrade: grade, newQuestions: questions, newSubject: quizSubject, newNbOfQuestions: questions.count, newDifficultyLevel: difficultyLevel)
                    }
                }
            }
        }
        
    }
}

#Preview {
    EditQuiz(chosenQuiz: .constant(Quiz()))
}
