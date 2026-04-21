//
//  RecipeItem.swift
//  Brew
//
//  Created by Teresa Kae on 20/04/26.
//

import Foundation

struct RecipeItem: Identifiable {
    let id: UUID
    let name: String
    let category: String
    let icon: String
    let phases: [BrewPhase]
    let coffeeGrams: Int
    let waterMl: Int
    
    var totalBrewTime: TimeInterval {
        phases.reduce(0) { $0 + $1.duration }
    }
    
    var formattedTotalTime: String {
        let total = Int(totalBrewTime)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
    
    init(id: UUID = UUID(), name: String, category: String, icon: String, phases: [BrewPhase], coffeeGrams: Int, waterMl: Int) {
        self.id = id
        self.name = name
        self.category = category
        self.icon = icon
        self.phases = phases
        self.coffeeGrams = coffeeGrams
        self.waterMl = waterMl
    }
}

extension RecipeItem {
    static let sampleData: [RecipeItem] = [
        RecipeItem(name: "Classic French Press", category: "French Press", icon: "cup.and.saucer.fill", phases: BrewPhase.frenchPressSample, coffeeGrams: 25, waterMl: 250),
        RecipeItem(name: "V60", category: "Pour Over", icon: "cup.and.saucer.fill", phases: BrewPhase.v60Sample, coffeeGrams: 15, waterMl: 250),
        RecipeItem(name: "Classic Aero Press", category: "Aero Press", icon: "cup.and.saucer.fill", phases: BrewPhase.aeropressSample, coffeeGrams: 18, waterMl: 200)
    ]
}
