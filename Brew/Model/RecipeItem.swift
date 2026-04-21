//
//  RecipeItem.swift
//  Brew
//
//  Created by Teresa Kae on 20/04/26.
//

import Foundation

struct RecipeItem: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let icon: String
    let phases: [BrewPhase]
    let coffeeGrams: Int
    let waterMl: Int
}

extension RecipeItem {
    static let sampleData: [RecipeItem] = [
        RecipeItem(name: "Classic French Press", category: "French Press", icon: "cup.and.saucer.fill", phases: BrewPhase.frenchPressSample, coffeeGrams: 25, waterMl: 250),
        RecipeItem(name: "V60", category: "Pour Over", icon: "cup.and.saucer.fill", phases: BrewPhase.v60Sample, coffeeGrams: 15, waterMl: 250),
        RecipeItem(name: "Classic Aero Press", category: "Aero Press", icon: "cup.and.saucer.fill", phases: BrewPhase.aeropressSample, coffeeGrams: 18, waterMl: 200)
    ]
}
