//
//  ViewController.swift
//  Set
//
//  Created by Heiko Goes on 30.08.18.
//  Copyright © 2018 Heiko Goes. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    @objc
    func touchCard(_ sender: UITapGestureRecognizer) {
        if let tappedView = sender.view {
            let index = tappedView.tag
            game.selectCard(atIndex: index)
            if game.scorer.hasNewScore && timer != nil {
                timer?.invalidate()
                updateViewFromModel()
                timerInterval = minimumTimerInterval
                switchPlayers()
                let alert = UIAlertController(title: "Spielerwechsel", message: self.getPlayerName() + " ist dran", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default){ alertAction in
                    self.timer = self.createSwitchPlayerTimer()
                })
                self.present(alert, animated: true, completion: nil)
            } else {
                updateViewFromModel()
            }
        }
    }
   
    @IBAction func findMatch(_ sender: UIButton) {
        startMatchFinder()
    }
    
    @IBAction func deal3Cards(_ sender: UISwipeGestureRecognizer) {
        game.deal3Cards()
        updateViewFromModel()
    }
    
    @IBAction func shuffleCards(_ sender: UIRotationGestureRecognizer) {
        if game.hasRemainingCards && sender.state == .ended {
            game.reshuffleCards()
            updateViewFromModel()
        }
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        createNewGame()
    }
    
    @IBOutlet var playingCardsView: UIView!
    @IBOutlet var playerName: UILabel!
    @IBOutlet var scorePlayer1: UILabel!
    @IBOutlet var scorePlayer2: UILabel!
    @IBOutlet var player2Score: UIStackView!
    
    var numberOfPlayers: Int!
    
    private let  minimumTimerInterval = 10.0
    private var game: Game!
    private var grid: Grid?
    private var timerInterval: Double!
    private weak var timer: Timer?
    
    private func createNewGame() {
        timer?.invalidate()
        grid = createGrid()
        timerInterval = minimumTimerInterval
        self.player2Score.isHidden = numberOfPlayers == 1
        
        game = Game(numberOfPlayers: numberOfPlayers)
        
        playerName.text = getPlayerName()
        updateViewFromModel()
        if numberOfPlayers > 1 {
            self.timer = self.createSwitchPlayerTimer()
        }
    }
    
    private func getPlayerName() -> String {
        return "\(self.game.players.current()?.name ?? "?")"
    }
    
    private func createSwitchPlayerTimer() -> Timer {
        let newTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: false) { timer in
            self.switchPlayers()
            self.timerInterval *= 2
            DispatchQueue.main.async {
                self.playingCardsView.isHidden = true
                let alert = UIAlertController(title: "Spielerwechsel", message: self.getPlayerName() + " ist dran", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { alertAction in
                        self.playingCardsView.isHidden = false
                        self.timer = self.createSwitchPlayerTimer()
                    })
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        return newTimer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createNewGame()
    }

    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createGrid() -> Grid {
        return Grid(layout: .aspectRatio(5.0 / 8.0), frame: playingCardsView.bounds)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if grid != nil && grid?.frame != playingCardsView.bounds {
            grid = createGrid()
            updateViewFromModel()
        }
    }

    private func updateViewFromModel() {
        removePlayingCardViews()
        grid?.cellCount = game.cards.count
        scorePlayer1.text = String(format: "%2d", game.players.getValue(atIndex: 0)?.score ?? "?")
        scorePlayer2.text = String(format: "%2d", game.players.getValue(atIndex: 1)?.score ?? "?")
        
        for (index, card) in game.cards.enumerated() {
            if let frame = grid?[index] {
                let cardView = PlayingCardView(frame: frame.insetBy(dx: 3, dy: 3))
                switch card.color {
                case .color1: cardView.suitColor = UIColor.red
                case .color2: cardView.suitColor = UIColor.blue
                case .color3: cardView.suitColor = UIColor.green
                }
                switch card.shading {
                case .shading1: cardView.shading = .filled
                case .shading2: cardView.shading = .open
                case .shading3: cardView.shading = .striped
                }
                switch card.symbol {
                case .symbol1 : cardView.suit = .diamond
                case .symbol2: cardView.suit = .oval
                case .symbol3: cardView.suit = .squiggle
                }
                cardView.rank = Rank(rawValue: card.rank) ?? .one
                
                if game.selectedCards.contains(card) {
                    if game.matchedCards.contains(card) {
                        cardView.cardColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                    } else {
                        cardView.cardColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
                    }
                } else {
                    cardView.cardColor = UIColor.white
                }
                
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchCard(_:)))
                cardView.addGestureRecognizer(tapGestureRecognizer)
                cardView.tag = index
                playingCardsView.addSubview(cardView)
            }
        }
    }
    
    private func switchPlayers() {
        game.nextPlayer()
        playerName.text = getPlayerName()
    }
    
    private func removePlayingCardViews() {
        for view in playingCardsView.subviews {
            if view is PlayingCardView {
                view.removeFromSuperview()
            }
        }
    }
    
    private func startMatchFinder() {
        let backgroundQueue = DispatchQueue.global(qos: .background)
        backgroundQueue.async {
            if let matchingCards = self.game.findMatchingCards() {
                DispatchQueue.main.async {
                    self.game.selectMatchingCards(matchingCards)
                    self.updateViewFromModel()
                }
            }
        }
    }
}
