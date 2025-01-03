
import SwiftUI

struct UserQuestionCreationDetailsView: View {
    @Binding var showQuestionCreationScreen: Bool
    @StateObject var quizCreationManager = QuizCreationManager()
    
    @Binding var questions: [Question]
    @Binding var quizzesCreated: [Quiz]
    
    @State private var questionPrompt: String = ""
    @State private var showAnswerAlert: Bool = false
    @State private var showSavingAlert: Bool = false
    @State private var answerOption: String = ""
    @State private var answers: [String: Any] = [:]
    @State private var answersArray: [String] = []
    @State private var correctAnswers: Set<String> = []
    //@State private var multipleChoice: Bool = false
    @State private var showDeletingOptionAlert: Bool = false
    
    
    func deleteOption(at indice: IndexSet) {
        answersArray.remove(atOffsets: indice)
    }
    
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Question prompt:") {
                    TextField("Enter your prompt", text: $questionPrompt)
                }
                
                Section("Answer options:") {
                    ForEach(answersArray, id: \.self) { answer in
                        Button(action: {
                            answerOption = answer
                            
                            if correctAnswers.contains(answer) {
                                correctAnswers.remove(answer)
                                
                            } else {
                                correctAnswers.insert(answer)
                                
                                
                            }
                            
                        }) {
                            
                            if correctAnswers.contains(answer) {
                                HStack {
                                    Text(answer)
                                        .foregroundStyle(Color.green)
                                    Text("correct answer")
                                        .foregroundStyle(Color.gray)
                                }
                            } else {
                                Text(answer)
                                    .foregroundStyle(Color.blue)
                            }
                            
                        }
                        
                    }
                    .onDelete(perform: deleteOption)
                    
                    Button(action: {
                        if answersArray.count + 1 <= 4 {
                            showAnswerAlert.toggle()
                            
                            
                            
                        } else {
                            showDeletingOptionAlert.toggle()
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                    
                }
                
                
                
            }
            
        }
        Button("Save question", systemImage: "plus") {
            showSavingAlert.toggle()
        }
        .navigationTitle("Question \(questions.count + 1)")
        .alert("Answer option", isPresented: $showAnswerAlert) {
            TextField("Write an option", text: $answerOption)
            Button("OK") {
                answersArray.append(answerOption)
                
                
            }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Answer option limit", isPresented: $showDeletingOptionAlert) {
            Text("You can't add any more options")
                .foregroundStyle(.red)
            Button("Cancel", role: .cancel) { }
        }
        .alert("Question saving", isPresented: $showSavingAlert) {
            Text("Are you sure you want to save this question?")
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                showQuestionCreationScreen.toggle()

                for answerValue in answersArray {
                    answers["\(answerValue)"] = false
                    
                    if correctAnswers.contains(answerValue) {
                        answers["\(answerOption)"] = true
                        
                    } else {
                        answers["\(answerOption)"] = false
                    }
                }
                questions.append(Question(prompt: questionPrompt, answers: answers, questionAnswered: false, correctAnswer: correctAnswers))
                
                
                
            }
        }
        
    }
}



#Preview {
    UserQuestionCreationDetailsView(showQuestionCreationScreen: .constant(false), questions: .constant([]), quizzesCreated: .constant([]))
}


//@State private var multipleChoice: Bool = false
/*Section("Is your quiz multiple-choice?") {
    Button(action: {
        multipleChoice.toggle()
    }){
        ZStack {
            Circle()
                .stroke(.blue, lineWidth: 1)
                .frame(width: 10, height: 10)
            if multipleChoice {
                Circle()
                    .fill(.blue)
                    .frame(width: 10, height: 10)
            }
        }
    }
}*/


