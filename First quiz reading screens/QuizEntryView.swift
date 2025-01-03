

//This only turned out to be an experimentation file

import SwiftUI

struct QuizEntryView: View {
    @StateObject private var databaseManager = DataBase()
    @Binding var quizChosen: String
    @State private var animationAmount = 3.0
    @State private var animationRepetition: Int = 0
    
    
    var body: some View {
        
        Text("\(databaseManager.quizChosen)")
            .overlay(
                Circle()
                    .stroke(.red) // stroked red circle above the object
                    .scaleEffect(animationAmount)
                    .opacity(animationAmount)
                    .animation(
                        .bouncy(duration: 2)
                        .repeatCount(animationRepetition, autoreverses: false),
                        value: animationAmount
                    )
            )
            .animation(.spring(duration: 1, bounce: 0.9), value: animationAmount)
            .animation(
                .bouncy(duration: 2)
                .repeatCount(animationRepetition, autoreverses: true),
                value: animationAmount
            )
            .blur(radius: animationAmount)
            .bold(true)
            .font(.title)
            .onAppear {
                Task {
                    
                }
            }
    }
}

#Preview {
    QuizEntryView(quizChosen: .constant(""))
}
