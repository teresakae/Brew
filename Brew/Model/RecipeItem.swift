//
//  RecipeItem.swift
//  Brew
//
//  Created by Teresa Kae on 20/04/26.
//

import Foundation
import SwiftData

@Model
class RecipeItem: Identifiable {
    var id: UUID
    var name: String
    var category: BrewCategory
    @Relationship(deleteRule: .cascade) var phases: [BrewPhase]
    var coffeeGrams: Int
    var waterMl: Int
    
    var totalBrewTime: TimeInterval {
        phases.reduce(0) { $0 + $1.duration }
    }
    var formattedTotalTime: String {
        let total = Int(totalBrewTime)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
    init(id: UUID = UUID(), name: String, category: BrewCategory, phases: [BrewPhase], coffeeGrams: Int, waterMl: Int) {
        self.id = id
        self.name = name
        self.category = category
        self.phases = phases
        self.coffeeGrams = coffeeGrams
        self.waterMl = waterMl
    }
}

extension RecipeItem {
    static let sampleData: [RecipeItem] = [
        RecipeItem(name: "Classic French Press", category: .frenchPress, phases: BrewPhase.frenchPressSample, coffeeGrams: 25, waterMl: 250),
        RecipeItem(name: "V60", category: .pourOver, phases: BrewPhase.v60Sample, coffeeGrams: 15, waterMl: 250),
        RecipeItem(name: "Chemex", category: .pourOver, phases: BrewPhase.chemexSample, coffeeGrams: 35, waterMl: 525),
        RecipeItem(name: "Classic Aero Press", category: .aeroPress, phases: BrewPhase.aeropressSample, coffeeGrams: 18, waterMl: 200),
        RecipeItem(name: "Classic Moka Pot", category: .mokaPot, phases: BrewPhase.mokapotSample, coffeeGrams: 15, waterMl: 150)
    ]
}

enum BrewCategory: String, CaseIterable, Codable {
    case pourOver = "Pour Over"
    case frenchPress = "French Press"
    case aeroPress = "Aero Press"
    case mokaPot = "Moka Pot"
    case others = "Others"
    
    var iconName: String {
        switch self {
        case .pourOver:    return "pour over"
        case .frenchPress: return "french press"
        case .aeroPress:   return "aeropress"
        case .mokaPot:     return "moka pot"
        case .others:      return "cup.and.saucer.fill"
        }
    }
}
