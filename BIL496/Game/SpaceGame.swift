//
//  SpaceGame.swift
//  BIL496
//
//  Created by Mahmut  Şahin on 6.03.2019.
//  Copyright © 2019 Mahmut  Şahin. All rights reserved.
//

import Foundation
import SpriteKit

final class SpaceGame: Game {
        
    func makeScene(_ viewController: ViewController) -> SpaceScene {
        let size = UIScreen.main.bounds.size
        let scene = SpaceScene(size: CGSize(width: size.width, height: size.height))
        scene.gameDelegate = viewController
        return scene
    }
}
