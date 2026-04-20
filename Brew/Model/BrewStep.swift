//
//  BrewStep.swift
//  Brew
//
//  Created by Teresa Kae on 20/04/26.
//

import Foundation

struct BrewStep: Identifiable {
    let id = UUID()
    var recipeName: String = ""
    var instructions: String = ""
    var minutes: String = ""
    var seconds: String = ""
}
