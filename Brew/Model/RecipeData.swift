//
//  RecipeData.swift
//  Brew
//
//  Created by Gabriella Dina Widieaster on 21/04/26.
//

import Foundation

enum RecipeMode {
    case add, edit
}

struct RecipeData {
    var title: String = ""
    var description: String = ""
    var notificationsOn: Bool = false
    var category: String = "V60"
    var coffeeDose: String = ""
    var waterDose: String = ""
    var grindSize: String = "Very fine"
    var waterTDS: String = ""
    var beanOrigin: String = ""
    var steps: [BrewStep] = [BrewStep()]
}
