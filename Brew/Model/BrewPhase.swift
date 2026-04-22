//
//  BrewPhase.swift
//  Brew
//
//  Created by Teresa Kae on 18/04/26.
//

import Foundation
struct BrewPhase: Identifiable {
    let id: UUID
    let name: String
    let duration: TimeInterval
    let instruction: String
    let ingredientAmount: Double?
    let soundName: String?

    init(
        id: UUID = UUID(),
        name: String,
        duration: TimeInterval,
        instruction: String,
        ingredientAmount: Double? = nil,
        soundName: String? = nil
    ) {
        self.id              = id
        self.name            = name
        self.duration        = duration
        self.instruction     = instruction
        self.ingredientAmount = ingredientAmount
        self.soundName       = soundName
    }

    // N
    var formattedDuration: String {
        let m = Int(duration) / 60
        let s = Int(duration) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Sample Data
extension BrewPhase {
    static let frenchPressSample: [BrewPhase] = [
        BrewPhase(
            name: "Bloom",
                duration: 3,
            instruction: "Pour 50ml of water in circular motion, let CO₂ escape",
            ingredientAmount: 50,
            soundName: "bloom_chime"
        ),
        BrewPhase(
            name: "First Pour",
            duration: 30,
            instruction: "Pour slowly to 150ml total, keep grounds saturated",
            ingredientAmount: 100,
            soundName: "pour_chime"
        ),
        BrewPhase(
            name: "Second Pour",
            duration: 30,
            instruction: "Continue pouring to 250ml, maintain even saturation",
            ingredientAmount: 100,
            soundName: "pour_chime"
        ),
        BrewPhase(
            name: "Drawdown",
            duration: 60,
            instruction: "Place lid, press gently. Wait for full drawdown.",
            ingredientAmount: nil,
            soundName: nil
        ),
    ]
    
    static let v60Sample: [BrewPhase] = [
        BrewPhase(
            name: "Bloom",
            duration: 30,
            instruction: "Pour 50ml in slow circles, let the bed expand",
            ingredientAmount: 50
        ),
        BrewPhase(
            name: "First Pour",
            duration: 30,
            instruction: "Pour to 150ml total in steady spirals from center out",
            ingredientAmount: 100
        ),
        BrewPhase(
            name: "Second Pour",
            duration: 30,
            instruction: "Pour to 250ml, maintain a slow steady stream",
            ingredientAmount: 100
        ),
        BrewPhase(
            name: "Drawdown",
            duration: 60,
            instruction: "Let remaining water drain fully through the filter",
            ingredientAmount: nil
        ),
    ]

    static let aeropressSample: [BrewPhase] = [
        BrewPhase(
            name: "Rinse",
            duration: 15,
            instruction: "Rinse paper filter with hot water, discard rinse water",
            ingredientAmount: nil
        ),
        BrewPhase(
            name: "Bloom",
            duration: 30,
            instruction: "Add 40ml water, stir gently for 10 seconds",
            ingredientAmount: 40
        ),
        BrewPhase(
            name: "Fill",
            duration: 30,
            instruction: "Pour remaining water to 200ml total",
            ingredientAmount: 160
        ),
        BrewPhase(
            name: "Press",
            duration: 30,
            instruction: "Press slowly and steadily for 30 seconds, stop at hiss",
            ingredientAmount: nil
        ),
    ]
}
