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
}
