//
//  BrewTimerViewModel.swift
//  Brew
//
//  Created by Teresa Kae on 18/04/26.
//

import Foundation
import Observation
import UIKit

// MARK: - Timer State (J)
enum TimerState: Equatable {
    case idle
    case running
    case paused
    case transitioning
    case finished
}

// MARK: - Haptic Player (J)
enum HapticPlayer {
    static func playPhaseEnd() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    static func playCompletion() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
}

// MARK: - ViewModel (N)
@Observable
final class BrewTimerViewModel {

    // MARK: - Observed state
    private(set) var timerState: TimerState = .idle
    private(set) var currentPhaseIndex: Int = 0

    // G
    private(set) var segmentStartDate: Date = .now
    private(set) var priorElapsed: TimeInterval = 0

    // MARK: - Immutable inputs
    let phases: [BrewPhase]

    // MARK: - Private
    private var timerTask: Task<Void, Never>?

    // MARK: - Convenience
    var currentPhase: BrewPhase { phases[currentPhaseIndex] }
    var isLastPhase: Bool       { currentPhaseIndex == phases.count - 1 }

    // MARK: - Init
    init(phases: [BrewPhase]) {
        self.phases = phases
    }

    // MARK: - Public Controls
    func start() {
        guard timerState == .idle || timerState == .paused else { return }
        segmentStartDate = .now
        timerState = .running
        schedulePhaseEnd()
    }

    func pause() {
        guard timerState == .running else { return }
        timerTask?.cancel()
        priorElapsed += Date.now.timeIntervalSince(segmentStartDate)
        timerState = .paused
    }

    func reset() {
        timerTask?.cancel()
        currentPhaseIndex = 0
        priorElapsed      = 0
        timerState        = .idle
    }

    func skipToNextPhase() {
        guard timerState == .running || timerState == .paused else { return }
        timerTask?.cancel()
        priorElapsed = 0
        triggerPhaseTransition()
    }

    func jumpToPhase(at index: Int) {
        guard index >= 0, index < phases.count else { return }
        guard timerState != .finished else { return }

        timerTask?.cancel()
        currentPhaseIndex = index
        priorElapsed      = 0

        if timerState == .running {
            segmentStartDate = .now
            schedulePhaseEnd()
            playPhaseSound()
        } else {
            timerState = .paused
        }
    }

    // MARK: - Sound Placeholders
    func playPhaseSound() {
        guard let soundName = currentPhase.soundName else {
            HapticPlayer.playPhaseEnd()
            return
        }
        
        _ = soundName
        HapticPlayer.playPhaseEnd()
    }

    func playCompletionSound() {
        HapticPlayer.playCompletion()
    }

    // MARK: - Internal Scheduling
    private func schedulePhaseEnd() {
        timerTask = Task { @MainActor in
            let remaining = currentPhase.duration - priorElapsed
            try? await Task.sleep(for: .seconds(remaining))
            guard !Task.isCancelled, timerState == .running else { return }
            triggerPhaseTransition()
        }
    }

    @MainActor
    private func triggerPhaseTransition() {
        timerState = .transitioning

        Task {
            if isLastPhase {
                try? await Task.sleep(for: .seconds(1.5))
                playCompletionSound()
                timerState = .finished
            } else {
                playPhaseSound()
                try? await Task.sleep(for: .seconds(0))
                currentPhaseIndex += 1
                priorElapsed      = 0
                segmentStartDate  = .now
                timerState        = .running
                schedulePhaseEnd()
            }
        }
    }
}
