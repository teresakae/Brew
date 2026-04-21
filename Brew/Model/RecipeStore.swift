//
//  RecipeStore.swift
//  Brew
//
//  Created by Teresa Kae on 21/04/26.
//

import Foundation

@Observable class RecipeStore {
    var recipes: [RecipeItem] = RecipeItem.sampleData
}
