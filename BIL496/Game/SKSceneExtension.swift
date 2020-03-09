//
//  SKSceneExtension.swift
//  BIL496
//
//  Created by Mahmut  Şahin on 6.03.2019.
//  Copyright © 2019 Mahmut  Şahin. All rights reserved.
//

import SpriteKit
import SceneKit

extension SKScene {
    var center: CGPoint {
        return CGPoint(x: frame.midX, y: frame.midY)
    }
    var buttonCenter: CGPoint {
        return CGPoint(x: frame.midX, y: frame.midY - 100)
    }
    var scoreCenter: CGPoint {
        return CGPoint(x: frame.midX, y: frame.midY - 50)
    }
    func randomXPosition() -> CGFloat {
        var xPosition = CGFloat(arc4random_uniform(UInt32(size.width)))
        if xPosition < 50 {
            xPosition = 50
        } else if xPosition > UIScreen.main.bounds.width - 50 {
            xPosition = UIScreen.main.bounds.width - 50
        }
        return xPosition
    }
    func randomYPosition() -> CGFloat {
        return CGFloat(arc4random_uniform(UInt32(size.height)))
    }
}

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
}

func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
}

extension Collection where Element == CGFloat, Index == Int {
    var average: CGFloat? {
        guard !isEmpty else {
            return nil
        }
        let sum = reduce(CGFloat(0)) { current, next -> CGFloat in
            return current + next
        }
        return sum / CGFloat(count)
    }
}
