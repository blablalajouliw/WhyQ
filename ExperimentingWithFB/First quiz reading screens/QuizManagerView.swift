

import SwiftUI

struct QuizManagerView: View {
    @StateObject private var databaseManager = DataBase()
    @State private var quizChosen: String = ""
    @State private var quizNames: [String] = [""]
    @Binding var showProfileView: Bool
    
    func fetchQuizNames() async {
            do {
                quizNames = try await databaseManager.readQuizNames() ?? [""]
            } catch {
                print("Couldn't load quiz names.")
            }
        }

        func resetQuizNames() {
            quizNames = [""]
        }
    
    var body: some View {
        NavigationStack {
            ForEach(quizNames, id: \.self) { quizName in
                NavigationLink(destination: QuizView(quizChosen: $quizChosen, showProfileView: $showProfileView)) {
                    Text("\(quizName)")
                    
                }
                .simultaneousGesture(TapGesture().onEnded {
                    quizChosen = quizName
                    
                })
            }
            
            .navigationTitle("Choose your quiz")
            .onAppear {
                resetQuizNames()
                Task {
                    await fetchQuizNames()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        QuizManagerView(showProfileView: .constant(false))
    }
}
