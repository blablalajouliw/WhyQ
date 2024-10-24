
import SwiftUI
import SwiftUI


struct QuizSubSubView: View {
    let correct: [String: Bool]
    let question: Question
    @Binding var userScore: Int
    @Binding var questions: [Question]
    @State private var isProcessing = false
    @State private var result: ([Question], Set<String>, Int, [String], [String]) = ([Question(questionAnswered: false)], [], 0, [], [])
    @State private var showAlert1: Bool = false
    @State private var variableKey = ""
    @State private var userAnswer: Set<String> = []
    
    @Binding var showAlert2: Bool
    @Binding var missedQuestions: [String]
    @Binding var correctQuestions: [String]
    @Binding var quizChosen: String
    @ObservedObject var databaseManager: DataBase
    
    func wereQuestionsAnswered(questions: [Question], questionsAnswered: [Question]) {
        
        if questionsAnswered.count == questions.count {
            print("Same count, verifying the contents...")
            for (questionAnswered, question) in zip(questionsAnswered, questions) {
                    if question.prompt == questionAnswered.prompt {
                        showAlert1 = true
                        print("Yay, they correspond.")
                        if showAlert1 {
                            showAlert2 = true
                        } else {
                            showAlert2 = false
                        }
                    } else {
                        print("The contents don't correspond.")
                        showAlert1 = false
                        
                    }
                }
            print(showAlert1, showAlert2)
        } else {
            print("Not the same count.")
        }
    } // Once we can check that all questions have been answered, we store the corresponding values inside a Quiz struct: is that really needed?
    
    var body: some View {
        
        ForEach(Array(correct.keys) as [String], id: \.self) { key in
            Button(action: {
                    guard !isProcessing else { return }
                
                    isProcessing = true
                userAnswer.insert(key)
                Task {
                        do {
                           
                            result = try await databaseManager.checkUserAnswer(currentQuestion: question, userAnswer: userAnswer, correctQuestions1: correctQuestions, missedQuestions1: missedQuestions, questionsAnswered1: result.0)
                            wereQuestionsAnswered(questions: questions, questionsAnswered: result.0)
                            
                            
                        } catch {
                            print("Could not check the user's answers")
                        }
                        
                        isProcessing = false
                    }
                
                
            }, label: {
                Text(key)
            })
            
        }
        /*.onAppear {
            Task {
                do {
                    questions = try await databaseManager.readQuestions() ?? []
                } catch {
                    print("error fetching the questions data: \(error.localizedDescription)")
                }
            }
        }
         */
    }
}


#Preview {
    QuizSubSubView(correct: ["": false], question: Question(questionAnswered: false), userScore: .constant(0), questions: .constant([]), showAlert2: .constant(false), missedQuestions: .constant([]), correctQuestions: .constant([]), quizChosen: .constant(""), databaseManager: DataBase())
}


