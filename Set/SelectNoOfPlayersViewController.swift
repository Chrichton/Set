//
//  SelectNoOfPlayersViewController.swift
//  Set
//
//  Created by Heiko Goes on 08.10.18.
//  Copyright © 2018 Heiko Goes. All rights reserved.
//

import UIKit

class SelectNoOfPlayersViewController: UIViewController {

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "SelectOnePlayerSegue" {
                if let vc = segue.destination as? GameViewController {
                    vc.numberOfPlayers = 1
                }
            } else if identifier == "SelectTwoPlayersSegue"  {
                if let vc = segue.destination as? GameViewController {
                    vc.numberOfPlayers = 2
                }
            }
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
