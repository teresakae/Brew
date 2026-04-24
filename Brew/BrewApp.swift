//
//  BrewApp.swift
//  Brew
//
//  Created by Teresa Kae on 18/04/26.
//

import SwiftUI
import SwiftData

@main
struct BrewApp: App {
    var body: some Scene {
        WindowGroup {
            TimerView()
        }
        .modelContainer(for: RecipeItem.self)
    }
}
