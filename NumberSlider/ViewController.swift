//
//  ViewController.swift
//  NumberSlider
//
//  Created by Prakash Sachania on 9/30/17.
//  Copyright © 2017 Prakash Sachania. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    //**** Reference to IB ****
    
    @IBOutlet weak var no1Button: UIButton!
    @IBOutlet weak var no2Button: UIButton!
    @IBOutlet weak var no3Button: UIButton!
    @IBOutlet weak var no4Button: UIButton!
    @IBOutlet weak var no5Button: UIButton!
    @IBOutlet weak var no6Button: UIButton!
    @IBOutlet weak var no7Button: UIButton!
    @IBOutlet weak var no8Button: UIButton!
    @IBOutlet weak var no9Button: UIButton!
    @IBOutlet weak var no10Button: UIButton!
    @IBOutlet weak var no11Button: UIButton!
    @IBOutlet weak var no12Button: UIButton!
    @IBOutlet weak var no13Button: UIButton!
    @IBOutlet weak var no14Button: UIButton!
    @IBOutlet weak var no15Button: UIButton!
    @IBOutlet weak var blankButton: UIButton!

    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var solutionFoundLabel: UILabel!
    @IBOutlet weak var lowestMoveLabel: UILabel!
    
    @IBOutlet weak var movesLabel: UILabel!
    
    @IBOutlet weak var numberFrameLabel: UILabel!

    @IBOutlet weak var resetLowestMovesButton: UIButton!

    @IBOutlet weak var soundOnOffImage: UIButton!
    
    //var soundImageView: UIImageView
    
    //**** Global variables ****

    var playerClickCanMove = AVAudioPlayer()
    var playerClickCantMove = AVAudioPlayer()
    var playerFinishedSound = AVAudioPlayer()
    var playerResetSound = AVAudioPlayer()
    var playerNewLowSound = AVAudioPlayer()

    var cellindexBlank: Int = 15 //points to blank cell
    
    //solution array. -1 means blank cell
    var solutionArray = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,-1]
    
    /* holds all possible moves of a given cell. each row is for a given cell in the puzzle. each row has 4 values - move down, move right, move left, move up. For example, cell 1 is [-1, -1, 2, 5] means that if cell 1 is empty then ...
     nothing can move down (-1), nothing can move from right(-1), cell 2 can move left, cell 5 can move up
     */
    let possibleMoves = [[-1, -1, 2, 5],
                         [-1, 1, 3, 6],
                         [-1, 2, 4, 7],
                         [-1, 3, -1, 8],
                         [1, -1, 6, 9],
                         [2, 5, 7, 10],
                         [3, 6, 8, 11],
                         [4, 7, -1, 12],
                         [5, -1, 10, 13],
                         [6, 9, 11, 14],
                         [7, 10, 12, 15],
                         [8, 11, -1, 16],
                         [9, -1, 14, -1],
                         [10, 13, 15, -1],
                         [11, 14, 16, -1],
                         [12, 15, -1, -1]]
    
    //position of number based 4x4 grid. this is hard coded but should change based on size of the canvas i.e. phone screen size
    let positionNumbers = [[28, 202], [96, 202], [164, 202], [232, 202],
                           [28, 270], [96, 270], [164, 270], [232, 270],
                           [28, 338], [96, 338], [164, 338], [232, 338],
                           [28, 406], [96, 406], [164, 406], [232, 406]]

    var lowestMoves = -1    //will store lowest steps performed ever to solve a puzzle
    var numberOfMoves = 0   //counts number of steps in the current game
    var musicOn = true      //whether music should be on or off
    var gameTimeStarted = false     //tracks if game timer is started or stopped

    //**** Action methods ****
    @IBAction func resetPuzzle(_ sender: UIButton) {
        if (solutionFoundLabel.alpha == 0 && musicOn) {
            playerResetSound.play()
        }
        resetPuzzle()
    }
    
    @IBAction func resetLowestMovesAction(_ sender: UIButton) {
        //User defaults for lowest move to be reset to 1000 moves
        lowestMoves = 1000
        let lowestMoveDefaults = UserDefaults.standard
        lowestMoveDefaults.set(lowestMoves, forKey: "LowestMoves")
        lowestMoveLabel.text = "  Current Lowest Moves : " + String(lowestMoves)
    }
 
    
    @IBAction func changeSoundImage(_ sender: UIButton) {
        musicOn = !musicOn
        displayMusicChoiceImage()

        let slideNumberDefaults = UserDefaults.standard
        slideNumberDefaults.set(musicOn, forKey: "MusicOnOff")
    }
    
    @IBAction func numberButtonTouchDown(_ sender: UIButton) {
        numberButtonDown(button: sender)
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {

        var cellindexPressedNumberInSolutionArray = -1
        
        numberButtonFormatting(button: sender)
        
        for i in 0..<16 {
            if solutionArray[i] == sender.tag {
                cellindexPressedNumberInSolutionArray = i
            }
        }
        
        //check if clicked number button is close to blank cell
        if possibleMoves[cellindexBlank][0] == cellindexPressedNumberInSolutionArray+1 ||
            possibleMoves[cellindexBlank][1] == cellindexPressedNumberInSolutionArray+1 ||
            possibleMoves[cellindexBlank][2] == cellindexPressedNumberInSolutionArray+1 ||
            possibleMoves[cellindexBlank][3] == cellindexPressedNumberInSolutionArray+1 {

            blankButton.frame.origin = CGPoint(x:positionNumbers[cellindexPressedNumberInSolutionArray][0], y:positionNumbers[cellindexPressedNumberInSolutionArray][1])
            
            sender.frame.origin = CGPoint(x:positionNumbers[cellindexBlank][0], y:positionNumbers[cellindexBlank][1])

            //swap values in the solution
            solutionArray[cellindexBlank] = sender.tag
            solutionArray[cellindexPressedNumberInSolutionArray] = -1
            cellindexBlank = cellindexPressedNumberInSolutionArray

            numberOfMoves += 1
            self.movesLabel.text = "Moves: " + String(numberOfMoves)
            
            if musicOn {
                playerClickCanMove.play()
            }
        } else {
            if musicOn {
                playerClickCantMove.play()
            }
        }
        
        if foundSolution() {
            solutionFoundLabel.alpha = 1
            if numberOfMoves < lowestMoves {
                lowestMoves = numberOfMoves
                self.movesLabel.text = "Lowest moves!! Moves: " + String(numberOfMoves)
                
                if musicOn {
                    playerNewLowSound.play()
                }
                
                //Update user defaults for next time launch
                let lowestMoveDefaults = UserDefaults.standard
                lowestMoveDefaults.set(lowestMoves, forKey: "LowestMoves")
 
                //Update label on the screen with new lowest
                lowestMoveLabel.text = "  Current Lowest Moves : " + String(lowestMoves)
                
            } else {
                if musicOn {
                    playerFinishedSound.play()
                }
            }
        } else {
            solutionFoundLabel.alpha = 0
        }
        
    }

    //Search through solution array to find if the solution is found
    func foundSolution() -> (Bool) {
        
        //quick and easy is that if blank cell is not the last one then solution is not found
        if cellindexBlank != 15 {
            return false
        }
        
        //otherwise, loop through all cells to find if solution is found
        for i in 0..<15 {
            if solutionArray[i] != i+1 {
                return false
            }
        }
        
        flashFinishLabel()
        
        return true
    }
    
    //reset puzzle to a random starting position
    func resetPuzzle() {
        
        //randomize the puzzle
        randomPuzzle()

        //position buttons based on the randomization
        for i in 0..<16 {
            var position = positionNumbers[i]
            
            switch solutionArray[i] {
            case 1:
                no1Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case 2:
                no2Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case 3:
                no3Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case 4:
                no4Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case 5:
                no5Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case 6:
                no6Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case 7:
                no7Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case 8:
                no8Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case 9:
                no9Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case 10:
                no10Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case 11:
                no11Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case 12:
                no12Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case 13:
                no13Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case 14:
                no14Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case 15:
                no15Button.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            case -1:
                blankButton.frame.origin = CGPoint(x:position[0], y:position[1])
                break
            default:
                break
            }
        }
        
        solutionFoundLabel.alpha = 0
        
        numberOfMoves = 0
        
        self.movesLabel.text = "Moves: " + String(numberOfMoves)
        
    }
    
    //internal of this funciton should be replaced with some randomization that generated 1 to 16
    func randomPuzzle() {
        let seconds = Calendar.current.component(.second, from: Date())
        if seconds % 3 == 0 {
            solutionArray = [1, 4, 6, 2, 9, 5, -1, 3, 12, 13, 7, 8, 11, 14, 10, 15]
            cellindexBlank = 6
        } else if seconds % 3 == 1 {
            solutionArray = [10, 1, 13, 3, 11, 5, 2, -1, 14, 4, 12, 8, 7, 6, 9, 15]
            cellindexBlank = 7
        } else {
            solutionArray = [14, 1, 9, 4, 2, -1, 8, 12, 10, 3, 13, 5, 7, 6, 15, 11]
            cellindexBlank = 5
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let slideNumberDefaults = UserDefaults.standard

        if (slideNumberDefaults.value(forKey: "LowestMoves") == nil) {
            lowestMoves = 1000
        } else {
            lowestMoves = slideNumberDefaults.value(forKey: "LowestMoves") as! Int
        }
        
        if (slideNumberDefaults.value(forKey: "MusicOnOff") == nil) {
            musicOn = true
        } else {
            musicOn = slideNumberDefaults.value(forKey: "MusicOnOff") as! Bool
        }
        
        lowestMoveLabel.text = "  Current Lowest Moves : " + String(lowestMoves)
        
        resetButton.layer.cornerRadius = 5
        resetButton.layer.borderWidth = 1
        resetButton.layer.borderColor = UIColor.black.cgColor

        resetLowestMovesButton.layer.cornerRadius = 5
        resetLowestMovesButton.layer.borderWidth = 1
        resetLowestMovesButton.layer.borderColor = UIColor.darkGray.cgColor
        resetLowestMovesButton.layer.backgroundColor = UIColor.clear.cgColor

        lowestMoveLabel.layer.cornerRadius = 5
        lowestMoveLabel.layer.borderWidth = 1
        lowestMoveLabel.layer.borderColor = UIColor.darkGray.cgColor
        lowestMoveLabel.layer.masksToBounds = true;

        solutionFoundLabel.layer.borderWidth = 2
        solutionFoundLabel.layer.borderColor = UIColor.black.cgColor
        
        numberFrameLabel.layer.cornerRadius = 5
        numberFrameLabel.layer.borderWidth = 2
        numberFrameLabel.layer.borderColor = UIColor.white.cgColor
        numberFrameLabel.layer.masksToBounds = true;
        
        resetPuzzle()
        
        numberButtonFormatting(button: no1Button)
        numberButtonFormatting(button: no2Button)
        numberButtonFormatting(button: no3Button)
        numberButtonFormatting(button: no4Button)
        numberButtonFormatting(button: no5Button)
        numberButtonFormatting(button: no6Button)
        numberButtonFormatting(button: no7Button)
        numberButtonFormatting(button: no8Button)
        numberButtonFormatting(button: no9Button)
        numberButtonFormatting(button: no10Button)
        numberButtonFormatting(button: no11Button)
        numberButtonFormatting(button: no12Button)
        numberButtonFormatting(button: no13Button)
        numberButtonFormatting(button: no14Button)
        numberButtonFormatting(button: no15Button)

        do {
            //  make sure to add this sound to your project
            var audioPath = Bundle.main.path(forResource: "ClickCanMove", ofType: "mp3")
            try playerClickCanMove = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!) as URL)
            
            audioPath = Bundle.main.path(forResource: "ClickCantMove", ofType: "mp3")
            try playerClickCantMove = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!) as URL)

            audioPath = Bundle.main.path(forResource: "CompletedSound", ofType: "mp3")
            try playerFinishedSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!) as URL)

            audioPath = Bundle.main.path(forResource: "ResetSound", ofType: "mp3")
            try playerResetSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!) as URL)

            audioPath = Bundle.main.path(forResource: "NewLowest", ofType: "mp3")
            try playerNewLowSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!) as URL)
            
        } catch {
            print("Error with audio files!")
        }

        //enable swipe on number buttons
        enableSwipeOnNumberButton()

        //sound
        displayMusicChoiceImage()
        
    }

    func displayMusicChoiceImage() {
        if musicOn {
            soundOnOffImage.setImage(UIImage(named:"MusicOn.png"), for: .normal)
        } else {
            soundOnOffImage.setImage(UIImage(named:"MusicOff.png"), for: .normal)
        }
    }
    
    func enableSwipeOnNumberButton() {
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        var upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        var downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
        self.view.addGestureRecognizer(upSwipe)
        self.view.addGestureRecognizer(downSwipe)
        
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        upSwipe.direction = UISwipeGestureRecognizerDirection.up
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
    }
    
    @objc func handleSwipe(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            var cellindexClick = -1
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                if cellindexBlank - 1 >= 0 {
                    cellindexClick = cellindexBlank - 1
                }
            case UISwipeGestureRecognizerDirection.up:
                if cellindexBlank + 4 < 16 {
                    cellindexClick = cellindexBlank + 4
                }
            case UISwipeGestureRecognizerDirection.left:
                if cellindexBlank + 1 < 16 {
                    cellindexClick = cellindexBlank + 1
                }
            case UISwipeGestureRecognizerDirection.down:
                if cellindexBlank - 4 >= 0 {
                    cellindexClick = cellindexBlank - 4
                }
            default:
                break
            }
            
            if cellindexClick > -1 {
                switch solutionArray[cellindexClick] {
                case 1:
                    numberPressed(no1Button)
                    break
                case 2:
                    numberPressed(no2Button)
                    break
                case 3:
                    numberPressed(no3Button)
                    break
                case 4:
                    numberPressed(no4Button)
                    break
                case 5:
                    numberPressed(no5Button)
                    break
                case 6:
                    numberPressed(no6Button)
                    break
                case 7:
                    numberPressed(no7Button)
                    break
                case 8:
                    numberPressed(no8Button)
                    break
                case 9:
                    numberPressed(no9Button)
                    break
                case 10:
                    numberPressed(no10Button)
                    break
                case 11:
                    numberPressed(no11Button)
                    break
                case 12:
                    numberPressed(no12Button)
                    break
                case 13:
                    numberPressed(no13Button)
                    break
                case 14:
                    numberPressed(no14Button)
                    break
                case 15:
                    numberPressed(no15Button)
                    break
                default:
                    break
                }
            }
            
            numberButtonFormatting(button: no1Button)
            numberButtonFormatting(button: no2Button)
            numberButtonFormatting(button: no3Button)
            numberButtonFormatting(button: no4Button)
            numberButtonFormatting(button: no5Button)
            numberButtonFormatting(button: no6Button)
            numberButtonFormatting(button: no7Button)
            numberButtonFormatting(button: no8Button)
            numberButtonFormatting(button: no9Button)
            numberButtonFormatting(button: no10Button)
            numberButtonFormatting(button: no11Button)
            numberButtonFormatting(button: no12Button)
            numberButtonFormatting(button: no13Button)
            numberButtonFormatting(button: no14Button)
            numberButtonFormatting(button: no15Button)

        }
    }
    
    func numberButtonFormatting(button: UIButton) {
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor

        button.layer.shadowColor = UIColor.white.cgColor
        button.layer.shadowOffset = CGSize.init(width: 4, height: 4)
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.7
    }
    
    func numberButtonDown(button: UIButton) {
        button.layer.shadowOpacity = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func flashFinishLabel() {
        UIView.animate(withDuration: 1, delay: 0.0, options: .curveEaseIn, animations: {
            self.solutionFoundLabel.alpha = 1.0
        }, completion: {
            (finished: Bool) -> Void in
            
            //Once the label is completely invisible, set the text and fade it back in
            self.solutionFoundLabel.text = "Found solution !!!!"
            
            // Fade in
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.solutionFoundLabel.alpha = 1.0
            }, completion: {
                (finished: Bool) -> Void in
                
                //Once the label is completely invisible, set the text and fade it back in
                self.solutionFoundLabel.text = "Congratulations!!"
                
                // Fade in
                UIView.animate(withDuration: 1, delay: 0.0, options: .curveEaseIn, animations: {
                    self.solutionFoundLabel.alpha = 1.0
                }, completion:nil )
                
            })
        })
    }

}

