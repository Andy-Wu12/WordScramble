//
//  ContentView.swift
//  WordScramble
//
//  Created by Andy Wu on 12/10/22.
//

import SwiftUI

func isReal(word: String) -> Bool {
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    
    return misspelledRange.location == NSNotFound
}

struct ContentView: View {
    @FocusState private var inputIsFocused: Bool
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                Text("Score: \(score)")
                    .textSelection(.disabled)
                Section {
                    TextField("Enter your word", text: $newWord)
                        .keyboardType(.alphabet)
                        .autocorrectionDisabled(true)
                        .onSubmit(addNewWord)
                        .onAppear(perform: startGame)
                        .alert(errorTitle, isPresented: $showingError) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text(errorMessage)
                        }
                        .textInputAutocapitalization(.never)
                        .focused($inputIsFocused)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .toolbar {
                Button("New Word") {
                    resetGame()
                    startGame()
                }
            }
            .navigationTitle(rootWord)
        }
    }
    
    func addNewWord() {
        // Convert user input to lowercase and trim to support preventing duplicates
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Do nothing if input empty
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Repeated guess", message: "Word already found")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "Guesses must be real words")
            return
        }
        
        guard isValidLength(word: answer) else {
            wordError(title: "Word too short", message: "Guesses must be longer than two characters")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        score += getWordValue(word: answer)
        newWord = ""
        inputIsFocused = true
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                rootWord = getStartingWord(from: startWords)
                // If we are here everything has worked, so we can exit
                return
            }
        }

        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    func resetGame() {
        usedWords = [String]()
        score = 0
        rootWord = ""
        newWord = ""
    }
    
    func getStartingWord(from words: String) -> String {
        let wordList = words.components(separatedBy: "\n")
        
        return wordList.randomElement() ?? "snapshot"
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word) && word != rootWord
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    
    func isValidLength(word: String) -> Bool {
        return word.count > 2
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func getWordValue(word: String) -> Int {
        // Random made-up equation
        // (Input length x # words found) + (100 x # words found)
        return (word.count * usedWords.count) + (100 * usedWords.count)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
