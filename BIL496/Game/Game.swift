//
//  Game.swift
//  BIL496
//
//  Created by Mahmut  Şahin on 6.03.2019.
//  Copyright © 2019 Mahmut  Şahin. All rights reserved.
//

import Foundation
import SpriteKit

protocol Game {
    init()
    func makeScene(_ viewController: ViewController) -> SpaceScene
}

