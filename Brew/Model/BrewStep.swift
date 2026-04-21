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

extension BrewStep {
    func toBrewPhase() -> BrewPhase {
        let duration = (Int(minutes) ?? 0) * 60 + (Int(seconds) ?? 0)
        return BrewPhase(
            name: recipeName,
            duration: TimeInterval(duration),
            instruction: instructions
        )
    }
}
