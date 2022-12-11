//
//  ContentView.swift
//  WordScramble
//
//  Created by Andy Wu on 12/10/22.
//

import SwiftUI

func getStartingWord() -> String {
    let input = """
                a
                b
                c
                """
    let letters = input.components(separatedBy: "\n")
    
    let letter = letters.randomElement()
    return letter!
}

func isSpelledCorrectly(word: String) -> Bool {
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    
    return misspelledRange.location == NSNotFound
}

struct ContentView: View {
    @State private var word = getStartingWord()
    @State private var correctSpelling = isSpelledCorrectly(word: "oordvark")
    
    var body: some View {
        VStack {
            Text(word)
            Text(String(correctSpelling))
        }
        
    }

    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
