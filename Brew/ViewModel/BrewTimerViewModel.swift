//
//  BrewTimerViewModel.swift
//  Brew
//
//  Created by Teresa Kae on 18/04/26.
//

import Foundation
import Observation
import UIKit
import AVFoundation

// Timer state (J)
enum TimerState: Equatable {
    case idle
    case running
    case paused
    case transitioning
    case finished
}

@Observable
final class BrewTimerViewModel {
    
    private var audioPlayer: AVAudioPlayer?
    
    // Current state and phase
    private(set) var timerState: TimerState = .idle
    private(set) var currentPhaseIndex: Int = 0

    // Starting point and check if previously paused or not
    private(set) var segmentStartDate: Date = .now
    private(set) var priorElapsed: TimeInterval = 0

    // Phase initiation
    let phases: [BrewPhase]
    private var timerTask: Task<Void, Never>?
    var currentPhase: BrewPhase {
        guard !phases.isEmpty else { return BrewPhase(name: "", duration: 0, instruction: "")}
        return phases[currentPhaseIndex]
    }
    var isLastPhase: Bool       { currentPhaseIndex == phases.count - 1 }

    init(phases: [BrewPhase]) {
        self.phases = phases
        //trying to override the silent mode
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Audio session error: \(error)")
            }
    }

    // Functions
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
        audioPlayer?.stop()
        audioPlayer = nil
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
            playPhaseSignal()
        } else {
            timerState = .paused
        }
    }
    //buat code soundnya
    func playPhaseSignal(isCompletion: Bool = false) {
        audioPlayer?.stop()
        audioPlayer = nil
        
        // haptic
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(isCompletion ? .warning : .success)
        
        //sound
        let audioFileName = isCompletion ? "Final" : "Handoff"
            
            guard let soundName = NSDataAsset(name: audioFileName) else {
                print ("No sound found for \(audioFileName)")
                return
            }

            do {
                audioPlayer = try AVAudioPlayer(data: soundName.data)
                audioPlayer?.play()
            } catch {
                print("Audio error: \(error)")
            }
        }
    
    // Phase switches
    private func schedulePhaseEnd() {
        timerTask = Task { @MainActor in
            let remaining = currentPhase.duration - priorElapsed
            try? await Task.sleep(for: .seconds(remaining))
            guard !Task.isCancelled, timerState == .running else { return }
            triggerPhaseTransition()
        }
    }

    @MainActor // the only one to redraw the UI
    private func triggerPhaseTransition() {
        timerState = .transitioning

        Task {
            if isLastPhase {
                try? await Task.sleep(for: .seconds(0))
                playPhaseSignal(isCompletion: true)
                timerState = .finished
                
            } else {
                playPhaseSignal()
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
