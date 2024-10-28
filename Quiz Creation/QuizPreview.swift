

import SwiftUI

struct QuizPreview: View {
    @Binding var chosenQuiz: Quiz
    @Binding var quizzesCreated: [Quiz]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Last time attempted by you: \(chosenQuiz.lastTimePlayed)")
                    if chosenQuiz.lastTimePlayed != nil { //For testing purposes the date is initialised in the struct, but it shouldn't be and should rather be set by a user's attempt of the quiz
                        Text("Number of points on last attempt: \(chosenQuiz.points)") // The points should then actually be stored as a dictionary with them being associated with each attempt's date
                    }
                    Text("Subject tested: \(chosenQuiz.subject)")
                    Text("Number of questions: \(chosenQuiz.nbOfQuestions)")
                    Text("Difficulty level: ") // Insert stars rating
                    Text("Grade: \(chosenQuiz.grade)")
                }
                
                Section("Question preview") {
                    Text("\(chosenQuiz.questions)")
                    ForEach(chosenQuiz.questions, id: \.id) { question in
                        Text("\(question.prompt)")
                    }
                }
                NavigationLink {
                    UserQuizCreationView(quizzesCreated: $quizzesCreated, chosenQuiz: $chosenQuiz)
                } label: {
                    Image(systemName: "pencil")
                        .font(.headline)
                }
            }
            
        
        
        }
        .navigationTitle("\(chosenQuiz.name)")
        .onAppear {
            print("\(chosenQuiz.questions)")
        }
        
    }
}

 
 #Preview {
     NavigationStack {
         QuizPreview(chosenQuiz: .constant(Quiz()), quizzesCreated: .constant([]))
     }
 }
 
 
