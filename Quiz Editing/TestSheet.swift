

import SwiftUI

struct TestSheet: View {
    @StateObject var quizCreationManager = QuizCreationManager()
    
    @Binding var showGradeSheet: Bool
    @Binding var showSubjectSheet: Bool
    @Binding var showDifficultyLevelSheet: Bool
    @Binding var showQuestionsSheet: Bool
    @Binding var makeSheetAppear: Bool
    @Binding var chosenQuiz: Quiz
    
    @State private var quizSubject: String = ""
    @State private var grade: Int = 0
    @State private var difficultyLevel: String = ""
    @State private var questions: [Question] = []
    @State private var question: Question = Question(questionAnswered: false)
    //@State private var questionPrompt: String = ""
    @State private var correctAnswers: Set<String> = []
    @State private var answers: [String: Any] = [:]
    
    let quizSubjects: [String] = ["Math", "Physics", "Chemistry", "History", "Geography", "Biology", "French", "English", "Spanish"]
    let grades: ClosedRange<Int> = 1...12
    let difficultyLevels: [String] = ["Easy", "Medium", "Advanced", "Expert"]
    
    var body: some View {
        if showGradeSheet {
            HStack {
                
                Text("For what grade is this quiz designed?")
                    .foregroundStyle(.blue)
                
                Picker("What grade?", selection: $grade) {
                    ForEach(grades, id: \.self) { grade1 in
                        Text("\(grade1)")
                    }
                }
            }
            Button("Save changes") {
                chosenQuiz = Quiz(difficultyLevel: chosenQuiz.difficultyLevel, points: chosenQuiz.points, grade: grade, questions: chosenQuiz.questions, nbOfQuestions: chosenQuiz.nbOfQuestions, subject: chosenQuiz.subject, name: chosenQuiz.name)
                
                showGradeSheet.toggle()
                makeSheetAppear.toggle()
                
            }
        }
        if showSubjectSheet {
            
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
            Button("Save changes") {
                chosenQuiz = Quiz(difficultyLevel: chosenQuiz.difficultyLevel, points: chosenQuiz.points, grade: chosenQuiz.grade, questions: chosenQuiz.questions, nbOfQuestions: chosenQuiz.nbOfQuestions, subject: quizSubject, name: chosenQuiz.name)
                
                showSubjectSheet.toggle()
                makeSheetAppear.toggle()
            }
        }
        if showDifficultyLevelSheet {
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
            Button("Save changes") {
                chosenQuiz = Quiz(difficultyLevel: difficultyLevel, points: chosenQuiz.points, grade: chosenQuiz.grade, questions: chosenQuiz.questions, nbOfQuestions: chosenQuiz.nbOfQuestions, subject: chosenQuiz.subject, name: chosenQuiz.name)
                
                
                showDifficultyLevelSheet.toggle()
                makeSheetAppear.toggle()
            }
        }
        if showQuestionsSheet {
            EditQuizSubView(questions: $questions, bindingQuestion: $question, chosenQuiz: $chosenQuiz, correctAnswers: $correctAnswers, answers: $answers)
            Button("Save changes") {
                chosenQuiz = Quiz(difficultyLevel: chosenQuiz.difficultyLevel, points: chosenQuiz.points, grade: chosenQuiz.grade, questions: questions, nbOfQuestions: chosenQuiz.nbOfQuestions, subject: chosenQuiz.subject, name: chosenQuiz.name)
                
                
                showQuestionsSheet.toggle()
                makeSheetAppear.toggle()
                
            }
            
        }
            
        
        
    }
}

#Preview {
    TestSheet(showGradeSheet: .constant(false), showSubjectSheet: .constant(false), showDifficultyLevelSheet: .constant(false), showQuestionsSheet: .constant(false), makeSheetAppear: .constant(false), chosenQuiz: .constant(Quiz()))
}
