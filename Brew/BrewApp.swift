//
//  BrewApp.swift
//  Brew
//
//  Created by Teresa Kae on 18/04/26.
//

import SwiftUI

@main
struct BrewApp: App {
    @State private var store = RecipeStore()

    var body: some Scene {
        WindowGroup {
            TimerView(store: store)
        }
    }
}
