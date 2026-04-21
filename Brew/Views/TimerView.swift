//
//  TimerView.swift
//  Brew
//
//  Created by Teresa Kae on 18/04/26.
//

import Foundation
import SwiftUI

// MARK: - Countdown Ring
// TimelineView + J (ring math/wall-clock diffing)
struct CountdownRingView: View {
    let viewModel: BrewTimerViewModel

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { context in
            let metrics = calculateMetrics(at: context.date)

            ZStack {
                // Ring Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.accentColor.opacity(0.20), Color.clear],
                            center: .center,
                            startRadius: 50,
                            endRadius: 130
                        )
                    )

                // Background track
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 10)

                // Progress arc
                Circle()
                    .trim(from: 0, to: metrics.progress)
                    .stroke(Color.accentColor,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                // Remaining time label
                Text(metrics.timeString)
                    .font(.system(size: 56, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }
            .frame(width: 260, height: 260)
        }
    }

    private func calculateMetrics(at renderTime: Date) -> (progress: Double, timeString: String) {
        let duration = viewModel.currentPhase.duration
        var elapsed  = viewModel.priorElapsed

        if viewModel.timerState == .running || viewModel.timerState == .transitioning {
            elapsed += renderTime.timeIntervalSince(viewModel.segmentStartDate)
        }

        let clamped   = min(elapsed, duration)
        let remaining = max(duration - clamped, 0)
        let progress  = duration > 0 ? (clamped / duration) : 1.0
        let timeStr   = String(format: "%d:%02d", Int(remaining) / 60, Int(remaining) % 60)

        return (progress, timeStr)
    }
}

// MARK: - Horizontal Phase Tracker
struct PhaseTrackerView: View {
    let viewModel: BrewTimerViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 20) {
                    ForEach(Array(viewModel.phases.enumerated()), id: \.element.id) { index, phase in
                        PhaseChipView(
                            phase: phase,
                            isActive: isActive(index),
                            isCompleted: isCompleted(index)
                        )
                        .id(index)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0)) {
                                viewModel.jumpToPhase(at: index)
                            }
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, 24)
            }
            .scrollTargetBehavior(.viewAligned)
            .frame(height: 60)
            .onChange(of: viewModel.currentPhaseIndex) { _, newIndex in
                withAnimation(.easeInOut(duration: 0.35)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }

    private func isActive(_ index: Int) -> Bool {
        index == viewModel.currentPhaseIndex
            && viewModel.timerState != .idle
            && viewModel.timerState != .finished
    }

    private func isCompleted(_ index: Int) -> Bool {
        index < viewModel.currentPhaseIndex || viewModel.timerState == .finished
    }
}

// MARK: - Phase Chip
struct PhaseChipView: View {
    let phase: BrewPhase
    let isActive: Bool
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(phase.name)
                .font(.subheadline)
                .fontWeight(isActive ? .semibold : .regular)
                .foregroundStyle(labelColor)

            Text(phase.formattedDuration)
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(isActive ? Color.accentColor : .secondary)
        }
        .padding(.horizontal, 4)
        .frame(minWidth: 72)
        .animation(.easeInOut(duration: 0.1), value: isActive)
    }

    private var labelColor: Color {
        if isActive    { return Color.accentColor }
        if isCompleted { return .secondary }
        return .primary
    }
}

// MARK: - Controls Row
struct ControlsRowView: View {
    let viewModel: BrewTimerViewModel

    var body: some View {
        HStack(spacing: 28) {
            CircleControlButton(
                icon: "arrow.counterclockwise",
                size: .small,
                tinted: false,
                enabled: viewModel.timerState != .idle
            ) { viewModel.reset() }

            CircleControlButton(
                icon: primaryIcon,
                size: .large,
                tinted: true,
                enabled: viewModel.timerState != .finished
                      && viewModel.timerState != .transitioning
            ) {
                viewModel.timerState == .running ? viewModel.pause() : viewModel.start()
            }

            CircleControlButton(
                icon: "playpause.fill",
                size: .small,
                tinted: false,
                enabled: viewModel.timerState == .running || viewModel.timerState == .paused
            ) { viewModel.skipToNextPhase() }
        }
    }

    private var primaryIcon: String {
        switch viewModel.timerState {
        case .running:  return "pause.fill"
        case .finished: return "checkmark"
        default:        return "play.fill"
        }
    }
}

// MARK: - Circle Control Button
enum ButtonSize { case small, large }

struct CircleControlButton: View {
    let icon: String
    let size: ButtonSize
    let tinted: Bool
    let enabled: Bool
    let action: () -> Void

    private var diameter: CGFloat { size == .large ? 72 : 52 }
    private var iconFont: Font    { size == .large ? .title2 : .body }

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: diameter, height: diameter)

                Image(systemName: icon)
                    .font(iconFont)
                    .fontWeight(.medium)
                    .foregroundStyle(iconColor)
            }
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
    }

    private var iconColor: Color {
        guard enabled else { return .secondary }
        return tinted ? Color.accentColor : .primary
    }
}

// MARK: - Finished Overlay
struct FinishedBannerView: View {
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cup.and.heat.waves.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.accentColor)

            Text("Brew Complete")
                .font(.headline)

            Button("Brew Again", action: onReset)
                .buttonStyle(.borderedProminent)
                .tint(Color.accentColor)
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Timer View
struct TimerView: View {
    let store: RecipeStore
    @State private var activeRecipe: RecipeItem = RecipeItem.sampleData[0]
    @State private var viewModel = BrewTimerViewModel(phases: BrewPhase.frenchPressSample)
    @State private var showRecipeList = false
    @State private var showEditRecipe = false
    @State private var showAddRecipe  = false
    @State private var activeRecipeName   = "Classic French Press"
    @State private var activeCoffeeGrams  = 25
    @State private var activeWaterMl      = 250

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    Text("\(activeCoffeeGrams)g · \(activeWaterMl)ml")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.bottom, 28)

                    CountdownRingView(viewModel: viewModel)
                        .padding(.bottom, 28)

                    PhaseTrackerView(viewModel: viewModel)
                        .padding(.bottom, 75)

                    Text(instructionText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .frame(height: 60, alignment: .top)
                        .id(viewModel.currentPhaseIndex)
                        .animation(.easeInOut(duration: 0.35), value: viewModel.currentPhaseIndex)

                    Spacer()

                    ControlsRowView(viewModel: viewModel)
                        .padding(.bottom, 44)
                }

                if viewModel.timerState == .finished {
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    FinishedBannerView { viewModel.reset() }
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.1), value: viewModel.timerState)
            .navigationTitle(activeRecipeName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showRecipeList = true } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showEditRecipe = true } label: {
                            Label("Edit Recipe", systemImage: "pencil")
                        }
                        Button { showAddRecipe = true } label: {
                            Label("Add Recipe", systemImage: "plus")
                        }
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
            .sheet(isPresented: $showRecipeList) {
                Category(currentRecipe: activeRecipeName, store: store) { selected in
                    viewModel         = BrewTimerViewModel(phases: selected.phases)
                    activeRecipe = selected
                    activeRecipeName  = selected.name
                    activeCoffeeGrams = selected.coffeeGrams
                    activeWaterMl     = selected.waterMl
                }
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showEditRecipe) {
                Recipes(mode: .edit, item: activeRecipe, store: store)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showAddRecipe) {
                Recipes(mode: .add, store: store)
                    .presentationDragIndicator(.visible)
            }
        }
        .preferredColorScheme(.dark)
        .tint(Color(red: 0.73, green: 0.84, blue: 0.18))
    }

    private var instructionText: String {
        switch viewModel.timerState {
        case .idle, .finished: return ""
        default: return viewModel.currentPhase.instruction
        }
    }
}

// MARK: - Preview
#Preview {
    TimerView(store: RecipeStore())
}
