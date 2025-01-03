

import SwiftUI

struct EditQuiz: View {
    @StateObject var quizCreationManager = QuizCreationManager()
    
    @Binding var chosenQuiz: Quiz
    @Binding var editViewAppear: Bool
    @State private var quizName: String = ""
    @State private var quizSubject: String = ""
    @State private var grade: Int = 0
    @State private var difficultyLevel: String = ""
    
    let quizSubjects: [String] = ["Math", "Physics", "Chemistry", "History", "Geography", "Biology", "French", "English", "Spanish"]
    let grades: ClosedRange<Int> = 1...12
    let difficultyLevels: [String] = ["Easy", "Medium", "Advanced", "Expert"]
    
    @State private var questions: [Question] = []
    @State private var question: Question = Question(questionAnswered: false)
    //@State private var questionPrompt: String = ""
    @State private var correctAnswers: Set<String> = []
    @State private var answers: [String: Any] = [:]
    
    
    @State private var quizGradeSheet: Bool = false
    @State private var quizSubjectSheet: Bool = false
    @State private var quizDifficultyLevelSheet: Bool = false
    @State private var quizQuestionsSheet: Bool = false
    @State private var makeSheetAppear: Bool = false
    
    
    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading) {
                Button("Change quiz grade") {
                    quizGradeSheet.toggle()
                    makeSheetAppear.toggle()
                }
                
               
                Button("Change quiz subject") {
                    quizSubjectSheet.toggle()
                    makeSheetAppear.toggle()
                }
                Button("Change quiz difficulty") {
                    quizDifficultyLevelSheet.toggle()
                    makeSheetAppear.toggle()
                }
                Button("Change quiz questions") {
                    quizQuestionsSheet.toggle()
                    makeSheetAppear.toggle()
                }
                
                Spacer()
                Button("Edit") {
                    
                    //chosenQuiz = Quiz(difficultyLevel: difficultyLevel, grade: grade, questions: questions, nbOfQuestions: questions.count, subject: quizSubject, name: quizName)
                    
                    Task {
                        try await quizCreationManager.editQuiz(chosenQuiz: chosenQuiz)
                    }
                }
            }
        }
        
        .sheet(isPresented: $makeSheetAppear) {
            TestSheet(showGradeSheet: $quizGradeSheet, showSubjectSheet: $quizSubjectSheet, showDifficultyLevelSheet: $quizDifficultyLevelSheet, showQuestionsSheet: $quizQuestionsSheet, makeSheetAppear: $makeSheetAppear, chosenQuiz: $chosenQuiz)
        }
    }
}

#Preview {
    EditQuiz(chosenQuiz: .constant(Quiz()), editViewAppear: .constant(false))
}
