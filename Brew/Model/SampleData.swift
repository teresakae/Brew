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
            instruction: "Pour 50ml in slow circles, make sure all grounds are wet",
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

    static var chemexSample: [BrewPhase] = [
        BrewPhase(
            name: "Bloom",
            duration: 45,
            instruction: "Pour 100ml in circular motion, make sure all grounds are saturated",
            ingredientAmount: 100
        ),
        BrewPhase(
            name: "First Pour",
            duration: 75,
            instruction: "Pour 200ml slowly in circular motion, keep water level steady",
            ingredientAmount: 200
        ),
        BrewPhase(
            name: "Final Pour",
            duration: 120,
            instruction: "Pour remaining 225ml slowly, let it drain completely",
            ingredientAmount: 225
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
    
    static var mokapotSample: [BrewPhase] = [
        BrewPhase(
            name: "Heat",
            duration: 180,
            instruction: " Place bottom chamber with 150ml hot water and basket with 15g coffee leveled on stove over medium-low heat, leave lid open",
            ingredientAmount: nil
        ),
        BrewPhase(
            name: "Flow",
            duration: 90,
            instruction: "Coffee starts flowing into upper chamber",
            ingredientAmount: nil
        ),
        BrewPhase(
            name: "Remove",
            duration: 30,
            instruction: "Stream turns honey color, remove from heat immediately and when the bubbling stops pour immediately to serve",
            ingredientAmount: nil
        ),
    ]
}
