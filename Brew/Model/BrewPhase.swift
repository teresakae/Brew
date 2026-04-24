//
//  BrewPhase.swift
//  Brew
//
//  Created by Teresa Kae on 18/04/26.
//

import Foundation
import SwiftData

@Model
class BrewPhase: Identifiable {
    var id: UUID
    var name: String
    var duration: TimeInterval
    var instruction: String
    var ingredientAmount: Double?
    var soundName: String?
    var sortOrder: Int = 0

    init(
        id: UUID = UUID(),
        name: String,
        duration: TimeInterval,
        instruction: String,
        ingredientAmount: Double? = nil,
        soundName: String? = nil,
        sortOrder: Int = 0
    ) {
        self.id              = id
        self.name            = name
        self.duration        = duration
        self.instruction     = instruction
        self.ingredientAmount = ingredientAmount
        self.soundName       = soundName
        self.sortOrder = sortOrder
    }

    // N
    var formattedDuration: String {
        let m = Int(duration) / 60
        let s = Int(duration) % 60
        return String(format: "%d:%02d", m, s)
    }
}
