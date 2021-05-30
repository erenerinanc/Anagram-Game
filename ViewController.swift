//
//  ViewController.swift
//  Project5
//
//  Created by Eren Erinanc on 22.12.2020.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Game", style: .plain, target: self, action: #selector(newGame))
        
        //Find the url of listed words file and pull it out from our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //Put the text content in startWords constant as a String
            if let startWords = try? String(contentsOf: startWordsURL){
                //Create an array from the text which has each words
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    func startGame(action: UIAlertAction! = nil) {
        //Choose a random word from the word array and set it as our title
        title = allWords.randomElement()
        
        //Empty the used words array which contains the answers of the user from the previous round
        usedWords.removeAll(keepingCapacity: true)
        
        //Clean up our table view so there won't be any previous answers
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        
        //Show answers of the user
        cell.textLabel?.text = usedWords[indexPath.row]
        
        return cell
    }
    
    @objc func newGame() {
        let ac = UIAlertController(title: "New Game", message: "Do you want to start a new game?", preferredStyle: .alert)
        present(ac, animated: true)
        
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: startGame))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }

    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        //Check the word user typed can be made from our question word
        if isPossible(word: lowerAnswer){
            //Check the word is not submitted before
            if isOriginal(word: lowerAnswer){
                //Check the word is correct
                if isReal(word: lowerAnswer){
                    //Check the word is not same as the question word
                    if !isSame(word: lowerAnswer){
                    usedWords.insert(answer, at: 0)
                    
                    //Sort the words from newest to latest
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                        
                    } else {
                        // If the answer is same as the question word
                        errorTitle = "Word is same"
                        errorMessage = "You can do better c'mon!"
                    }
                } else {
                    //If the answer is not correct
                    errorTitle = "Word not recognised"
                    errorMessage = "You can't just make them up you know!"
                }
            } else {
                //If user typed the same word before
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        } else {
            //If the question does not contain the letters of the answer
            guard let title = title?.lowercased() else {return}
            errorTitle = " Word not possible"
            errorMessage = "You can't spell that word from \(title) "
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {return false}
        
        for letter in word {
            //For each letter in answer, check if the question word contains them
            if let position = tempWord.firstIndex(of: letter) {
                //If it does, remove it for not double counting
                tempWord.remove(at: position)
            }
            //If the letter can not be found
            else {return false}
        }
        //We have each letter
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        if word.count < 3 {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isSame(word: String) -> Bool{
        guard let title = title?.lowercased() else {return false}
        
        if word == title {return true}
        
        return false
    }
}

