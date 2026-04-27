//
//  SampleData.swift
//  Brew
//
//  Created by Teresa Kae on 23/04/26.
//

import Foundation

extension BrewPhase {
    static var frenchPressSample: [BrewPhase] = [
        BrewPhase(
            name: "Bloom",
            duration: 3,
            instruction: "Pour 50ml of water in circular motion, let CO₂ escape",
            ingredientAmount: 50
        ),
        BrewPhase(
            name: "First Pour",
            duration: 30,
            instruction: "Pour slowly to 150ml total, keep grounds saturated",
            ingredientAmount: 100
        ),
        BrewPhase(
            name: "Second Pour",
            duration: 30,
            instruction: "Continue pouring to 250ml, maintain even saturation",
            ingredientAmount: 100
        ),
        BrewPhase(
            name: "Drawdown",
            duration: 60,
            instruction: "Place lid, press gently. Wait for full drawdown.",
            ingredientAmount: nil
        ),
    ]
    
    static var v60Sample: [BrewPhase] = [
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

    static var aeropressSample: [BrewPhase] = [
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
