
import SwiftUI

struct EditAnswerOptions: View {
    @Binding var showSheet: Bool
    @Binding var answers: [String: Any]
    @Binding var correctAnswers: Set<String>
    @Binding var question: Question
    
    
    @State private var newAnswers1: [String: Bool] = [:]
    @State private var answerKey: String = ""
    @State private var answerKey2: String = ""
    @State private var showAlert: Bool = false
    @State private var showNewOptionAlert: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    /*func processAnswers(answers: [String: Bool]) {
     for answer in answers {
     answerKeys.insert(answer.key)
     answerValues.insert(answer.value)
     }
     }
     func processCorrectAnswer() {
     
     }
     */
    var body: some View {
        VStack {
            Form {
                ForEach(Array(answers), id: \.key) { answer in
                    HStack {
                        Section {
                            Button("\(answer.key)") {
                                showAlert.toggle()
                                answerKey = answer.key
                                answerKey2 = answer.key
                                
                            }
                            
                            Button(action: {
                                
                            }) {
                                if correctAnswers.contains(answer.key) {
                                    HStack {
                                        Button("correct") {
                                            if correctAnswers.contains(answer.key) {
                                                correctAnswers.remove(answer.key)
                                                
                                            } else {
                                                correctAnswers.insert(answer.key)
                                            }
                                            
                                        }
                                        .foregroundStyle(Color.green)
                                        
                                    }
                                } else {
                                    Button("incorrect") {
                                        if correctAnswers.contains(answer.key) {
                                            correctAnswers.remove(answer.key)
                                            
                                        } else {
                                            correctAnswers.insert(answer.key)
                                        }
                                        
                                    }
                                    .foregroundStyle(Color.blue)
                                }
                                
                            }
                        }
                    }
                }
            }
            
            Button("Save changes") {
                showSheet.toggle()
                question = Question(prompt: question.prompt, answers: answers, questionAnswered: false, correctAnswer: correctAnswers)
            }
            
            Button("Add a new answer option", systemImage: "plus") {
                showNewOptionAlert.toggle()
            }
        }
        .onAppear {
            answers = question.answers
        }
        
        .alert("Enter new answer", isPresented: $showAlert) {
            TextField("\(answerKey)", text: $answerKey)
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                if answerKey != answerKey2 {
                    let value = answers["\(answerKey2)"] ?? false
                    
                    answers.removeValue(forKey: answerKey2)
                    answers["\(answerKey)"] = value
                    showAlert.toggle()
                } else {
                    showAlert.toggle()
                } 
            }
        }
        .alert("Add another answer option", isPresented: $showNewOptionAlert) {
            TextField("\(answerKey)", text: $answerKey)
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                answers["\(answerKey)"] = false
            }
        }
        
        
    }
}

#Preview {
    EditAnswerOptions(showSheet: .constant(false), answers: .constant(["": false]), correctAnswers: .constant([]), question: .constant(Question(questionAnswered: false)))
}
