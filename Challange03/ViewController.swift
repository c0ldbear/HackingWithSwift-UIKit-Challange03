//
//  ViewController.swift
//  Challange03
//
//  Created by teddy on 2022-09-06.
//

import UIKit

class ViewController: UIViewController {
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var scoreLabel: UILabel!
    
    var nrGuessesLeft = 0 {
        didSet {
            guessLeftLabel.text = "Guess Left: \(nrGuessesLeft)"
        }
    }
    var guessLeftLabel: UILabel!
    
    var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    var letterButtons = [UIButton]()
    var usedLetters = [UIButton]()
    
    var words = [String]()
    
    var guessWordLabel: UILabel!
    var guessWord = ""
    var guessWordLetters = [String]()
    
    override func loadView() {
        
        // Load words from file to array
        if let wordsFile = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let fileContent = try? String(contentsOf: wordsFile) {
                words = fileContent.components(separatedBy: "\n")
            }
        }
        
        
        // Layout of UI Elements
        view = UIView() // Canvas to add all the UI elements to
        view.backgroundColor = .systemBackground
        
        // score label
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.font = UIFont.systemFont(ofSize: 24)
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)
        
        // Number of guesses left label
        guessLeftLabel = UILabel()
        guessLeftLabel.translatesAutoresizingMaskIntoConstraints = false
        guessLeftLabel.textAlignment = .right
        guessLeftLabel.font = UIFont.systemFont(ofSize: 24)
        guessLeftLabel.text = "Guess Left: \(nrGuessesLeft)"
        view.addSubview(guessLeftLabel)
        
        // guess word label
        guessWordLabel = UILabel()
        guessWordLabel.translatesAutoresizingMaskIntoConstraints = false
        guessWordLabel.textAlignment = .center
        guessWordLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        view.addSubview(guessWordLabel)
        
        // Button Canvas
        let buttonCanvas = UIView()
        buttonCanvas.translatesAutoresizingMaskIntoConstraints = false
        buttonCanvas.layer.borderWidth = 1
        buttonCanvas.layer.cornerRadius = 25
        buttonCanvas.layer.borderColor = UIColor.systemGray6.cgColor
        view.addSubview(buttonCanvas)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            scoreLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            
            guessLeftLabel.topAnchor.constraint(equalTo: scoreLabel.topAnchor),
            guessLeftLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            
            guessWordLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 100),
            guessWordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonCanvas.widthAnchor.constraint(equalTo: view.widthAnchor),
            buttonCanvas.topAnchor.constraint(equalTo: guessWordLabel.bottomAnchor, constant: 200),
            buttonCanvas.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonCanvas.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        
        // Layout button canvas
        let width = 50
        let height = width
        
        var temp = alphabet.reversed().map { $0 }
        
        for row in 0..<4 {
            for column in 0..<7 {
                guard let letter = temp.popLast() else {
                    return
                }
                
                let letterButton = UIButton(type: .system)
                letterButton.addTarget(self, action: #selector(letterButtonTapped), for: .touchUpInside)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
                letterButton.setTitle(String(letter), for: .normal)
                letterButton.sizeToFit()
                
                let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                
                letterButtons.append(letterButton)
                
                buttonCanvas.addSubview(letterButton)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newGame()
    }

    @objc func letterButtonTapped(_ sender: UIButton) {
        guard let letter = sender.self.titleLabel?.text else {
            return
        }
        
        var tempWord = [String]()
        for char in guessWordLabel.text! {
            tempWord.append(String(char))
        }
        
        if guessWord.contains(letter) {
            print("Yes")
            score += 1
            for (index, char) in guessWord.enumerated() {
                if char == Character(letter) {
                    tempWord[index] = String(char)
                }
            }
            guessWordLabel.text = tempWord.joined(separator: "")
            if !tempWord.contains("?") {
                let ac = UIAlertController(title: "Winner!", message: "You guessed the word!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: loadNextWord))
                present(ac, animated: true)
            }
        } else {
            print("No")
            nrGuessesLeft -= 1
            if nrGuessesLeft == 0 {
                let ac = UIAlertController(title: "Game Over", message: "You lost. The correct word:\n'\(guessWord)'", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "New Game", style: .default, handler: loadNextWord))
                present(ac, animated: true)
            }
        }
        
        sender.isHidden = true
        usedLetters.append(sender)
    }
    
    func loadNextWord(_ action: UIAlertAction! = nil) {
        print("Loading next word...")
        addPointsToScore()
        newGame()
        
        for button in usedLetters {
            button.isHidden = false
        }
        
        usedLetters = [] // reset
    }
    
    func newGame() {
        words.shuffle()
        guessWord = words.popLast()?.uppercased() ?? ""
        print("Word: \(guessWord), length: \(guessWord.count)")
        
        if !guessWordLetters.isEmpty {
            guessWordLetters = []
        }
        
        var questionMarkLetters = [String]()
        for char in guessWord {
            guessWordLetters.append(String(char))
            questionMarkLetters.append("?")
        }
        
        guessWordLabel.text = questionMarkLetters.joined(separator: "")
        
        nrGuessesLeft = guessWordLetters.count + 1
    }
    
    func addPointsToScore() {
        if guessWord.count > 0 { score += guessWord.count }
        if nrGuessesLeft > 0 { score += nrGuessesLeft }
    }
    
}

