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
        if !inAnimation, let tappedView = sender.view {
            let index = tappedView.tag
            game.selectCard(atIndex: index)
            updateViewFromModel()
        }
    }
   
    @IBAction func findMatch(_ sender: UIButton) {
        startMatchFinder()
    }
    
    @IBAction func deal3Cards(_ sender: UISwipeGestureRecognizer) {
       deal3Cards()
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
    private weak var timer: PauseableTimer?
    private var inAnimation = false
    
    private func deal3Cards() {
        game.deal3Cards()
        updateViewFromModel()
    }
    
    private func deSelectCards() {
        game.deSelectCards()
        updateViewFromModel()
    }
    
    private func moveCardView(_ cardView: PlayingCardView, from: CGRect, to: CGRect) {
        cardView.frame = from
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 1.5,
            delay: 0,
            options: [],
            animations: { cardView.frame = to },
            completion: { _ in
                UIView.transition(with: cardView,
                                  duration: 0.5,
                                  options: [.transitionFlipFromRight],
                                  animations: {
                                    cardView.isFaceUp = true
                                    cardView.setNeedsDisplay()
                                    }
                )
            }
        )
    }
    
    private func matchShown() {
        if game.players.count > 1 {
            timer?.invalidate()
            timerInterval = minimumTimerInterval
            switchPlayers()
            let alert = UIAlertController(title: "Spielerwechsel", message: self.getPlayerName() + " ist dran", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default){ alertAction in
                self.deal3Cards()
                self.timer = self.createSwitchPlayerTimer()
            })
            self.present(alert, animated: true, completion: nil)
        } else {
            deal3Cards()
        }
    }
    
    private func createNewGame() {
        timer?.invalidate()
        grid = createGrid()
        timerInterval = minimumTimerInterval
        self.player2Score.isHidden = numberOfPlayers == 1
        
        game = Game(numberOfPlayers: numberOfPlayers)
        
        playerName.text = getPlayerName()
        updateViewFromModel()
        if numberOfPlayers > 1 {
            timer = createSwitchPlayerTimer()
        }
    }
    
    private func getPlayerName() -> String {
        return "\(self.game.players.current()?.name ?? "?")"
    }
    
    private func createSwitchPlayerTimer() -> PauseableTimer {
        let newTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: false) { timer in
            self.timer?.invalidate()
            self.timerInterval *= 2
            DispatchQueue.main.async {
                self.playingCardsView.isHidden = true
                self.switchPlayers()
                self.deSelectCards()
                let alert = UIAlertController(title: "Spielerwechsel", message: self.getPlayerName() + " ist dran", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { alertAction in
                        self.playingCardsView.isHidden = false
                        self.timer = self.createSwitchPlayerTimer()
                    })
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        return PauseableTimer(timer: newTimer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        var matchedCardViews = [PlayingCardView]()
        var unMatchedCardViews = [PlayingCardView]()
        
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
                        matchedCardViews.append(cardView)
                    } else {
                        cardView.cardColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
                        if game.selectedCards.count == 3 {
                            unMatchedCardViews.append(cardView)
                        }
                    }
                } else {
                    cardView.cardColor = UIColor.white
                }
                
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchCard(_:)))
                cardView.addGestureRecognizer(tapGestureRecognizer)
                cardView.tag = index
                playingCardsView.addSubview(cardView)
                
                cardView.isFaceUp = !card.isNew
                if card.isNew {
                    moveCardView(cardView, from: CGRect(origin: CGPoint(x: 0, y: 0), size: cardView.frame.size), to: cardView.frame)
                }
            }
        }
        
        for (index, cardView) in matchedCardViews.enumerated() {
            inAnimation = true
            timer?.invalidate()
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.65,
                delay: 0,
                options: [],
                animations: { cardView.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5) },
                completion: { position in
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.75,
                        delay: 0,
                        options: [],
                        animations: {
                            cardView.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                            cardView.alpha = 0
                        },
                        completion: {
                            position in
                            if index == 0 {
                                self.inAnimation = false
                                self.matchShown()
                            }
                        }
                    )
                }
            )
        }
        
        for (index, cardView) in unMatchedCardViews.enumerated() {
            inAnimation = true
            timer?.pause()
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 1.5,
                delay: 0,
                options: [],
                animations: {
                    cardView.alpha = 0.7
                },
                completion: {
                    position in
                    if index == 0 {
                        self.inAnimation = false
                        self.timer?.resume()
                        self.deSelectCards()
                    }
                }
            )
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
