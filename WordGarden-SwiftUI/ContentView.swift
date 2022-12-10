//
//  ContentView.swift
//  WordGarden-SwiftUI
//
//  Created by Remi Pacifico Hansen on 9/19/22.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    @State private var currentWordIndex = 0
    @State private var wordToGuess = ""
    @State private var lettersGuessed = ""
    @State private var guessesRemaining = 8
    @State private var revealedWord = ""
    @State private var gameStatusMessage = "How many guesses to uncover the hidden word?"
    @State private var guessedLetter = ""
    @State private var imageName = "flower8"
    @State private var playAgainHidden = true
    @State private var playAgainButtonLabel = "Another Word?"
    @State private var audioPlayer: AVAudioPlayer!
    @FocusState private var textFieldIsFocused: Bool
    
    private let wordsToGuess = ["SWIFT", "DOG", "CAT"]
    private let maximumGuesses = 8
    
    
    var body: some View {
        VStack {
            
            HStack{
                VStack (alignment: .leading) {
                    Text("Words Guessed: \(wordsGuessed)")
                    Text("Words Missed: \(wordsMissed)")
                }
                Spacer()
                VStack (alignment: .trailing) {
                    Text("Words To Guess: \(wordsToGuess.count - (wordsGuessed + wordsMissed))")
                    Text("Words in Game: \(wordsToGuess.count)")
                    
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Text(gameStatusMessage)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(height: 80)
                .minimumScaleFactor(0.5)
                .padding()
            
            //TODO: Switch to wordToGuess[CurrentWord]
            Text(revealedWord)
                .font(.title)
            
            if playAgainHidden{
                HStack{
                    TextField("", text: $guessedLetter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 30)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray, lineWidth: 2)
                        }
                        .keyboardType(.asciiCapable)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .onChange(of: guessedLetter) { _ in
                            guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
                            guard let lastChar = guessedLetter.last else {
                                return
                            }
                            guessedLetter = String(lastChar).uppercased()
                        }
                        .onSubmit {
                            guard guessedLetter != "" else{
                                return
                            }
                            guessALetter()
                            updateGameplay()
                        }
                        .focused($textFieldIsFocused)
                    
                    
                    Button("Guess a Letter!") {
                        guessALetter()
                        updateGameplay()
                    }
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    .disabled(guessedLetter.isEmpty)
                }
            }else{
                Button(playAgainButtonLabel) {
                    //                    if all the the words have been guessed
                    if currentWordIndex == wordsToGuess.count {
                        currentWordIndex = 0
                        wordsGuessed = 0
                        wordsMissed = 0
                        playAgainButtonLabel = "Another Word?"
                    }
                    //                    reset after word was guessed
                    wordToGuess = wordsToGuess[currentWordIndex]
                    revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
                    lettersGuessed = ""
                    guessesRemaining = maximumGuesses
                    imageName = "flower\(guessesRemaining)"
                    gameStatusMessage = "How many guesses to uncover the hidden word?"
                    playAgainHidden = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)
            }
            
            
            Spacer()
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .animation(.easeIn(duration: 0.75), value: imageName)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear(){
            wordToGuess = wordsToGuess[currentWordIndex]
            revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
            guessesRemaining = maximumGuesses
        }
    }
    func guessALetter(){
        textFieldIsFocused = false
        lettersGuessed = lettersGuessed + guessedLetter
        revealedWord = ""
        for letter in wordToGuess {
            if lettersGuessed.contains(letter) {
                revealedWord = revealedWord + "\(letter) "
            }else {
                revealedWord = revealedWord + "_ "
            }
        }
        revealedWord.removeLast()
        
    }
    func updateGameplay() {
        
        if !wordToGuess.contains(guessedLetter) {
            guessesRemaining -= 1
            //            animate crumbling leaf
            imageName = "wilt\(guessesRemaining)"
            playsound(soundName: "incorrect")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                imageName = "flower\(guessesRemaining)"
            }
        }else{
            playsound(soundName: "correct")
        }
        if !revealedWord.contains("_") {//guessed when there are no underscores remaining
            gameStatusMessage = "You guessed it! It took you \(lettersGuessed.count) guesses to guess the word!"
            wordsGuessed += 1
            currentWordIndex += 1
            playAgainHidden = false
            playsound(soundName: "word-guessed")
        }else if guessesRemaining == 0{
            gameStatusMessage = "So Sorry. You're all out of guesses!"
            wordsMissed += 1
            currentWordIndex += 1
            playAgainHidden = false
            playsound(soundName: "word-not-guessed")
        }else { // when you haven't run out of guesses or guessed the word
            gameStatusMessage = "You've made \(lettersGuessed.count) guess\(lettersGuessed.count == 1 ? "" : "es")!"
        }
        if currentWordIndex == wordsToGuess.count {
            playAgainButtonLabel = "Restart Game?"
            gameStatusMessage = gameStatusMessage + "\nYou've tried all the words, restart from the beginning?"
        }
        guessedLetter = ""
    }
    func playsound(soundName: String){
        guard let soundFile = NSDataAsset(name: soundName) else{
            print("😡 Could not read filename \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        }catch{
            print("😡 Error: \(error.localizedDescription) creating audio player")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
