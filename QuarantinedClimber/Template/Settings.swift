//
//  Settings.swift
//  QuarantinedClimber
//
//  Created by Kevin Nogales on 5/24/20.
//  Copyright © 2020 Kevin Nogales. All rights reserved.
//

import SpriteKit

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let climberCategory: UInt32 = 0x1 << 1
    static let routeCategory: UInt32 = 0x1
}

enum ZPositions {
    static let label: CGFloat = 0
    static let route: CGFloat = 1
    static let climber: CGFloat = 2
}
