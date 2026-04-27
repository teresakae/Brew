//
//  TimerView.swift
//  Brew
//
//  Created by Teresa Kae on 18/04/26.
//

import Foundation
import SwiftUI
import SwiftData

struct CountdownRingView: View {
    let viewModel: BrewTimerViewModel

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) // redraws the screen in 60 fps
            { context in
            let metrics = calculateMetrics(at: context.date)
            // asks the brain on where we're at
                
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.accentColor.opacity(0.20), Color.clear],
                            center: .center,
                            startRadius: 50,
                            endRadius: 130
                        )
                    )

                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: metrics.progress)
                    .stroke(Color.accentColor,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text(metrics.timeString)
                    .font(.system(size: 56, weight: .regular, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }
            .frame(width: 300, height: 300)
        }
    }
    
    // the dashboard (tuple, returns more than 1 value without making a new class/struct)
    private func calculateMetrics(at renderTime: Date) -> (progress: Double, timeString: String) {
        let duration = viewModel.currentPhase.duration
        var elapsed  = viewModel.priorElapsed

        if viewModel.timerState == .running || viewModel.timerState == .transitioning {
            elapsed += renderTime.timeIntervalSince(viewModel.segmentStartDate)
        }

        let clamped   = min(elapsed, duration)
        let remaining = max(duration - clamped, 0)
        let progress  = duration > 0 ? (clamped / duration) : 1.0 // turns time into % (passes it to view, to know how much to trim the circl)
        let timeStr   = String(format: "%d:%02d", Int(remaining) / 60, Int(remaining) % 60) // for the time text
        return (progress, timeStr)
    }
}

struct PhaseTrackerView: View {
    let viewModel: BrewTimerViewModel

    var body: some View {
        ScrollViewReader { proxy in
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 20) {
                        ForEach(viewModel.phases.indices, id: \.self) { index in
                            let phase = viewModel.phases[index]

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
                    //force the geo to be as wide as the screen
                    .frame(minWidth: geo.size.width, alignment: .center)
                }
                .scrollTargetBehavior(.viewAligned)
                .frame(height: 60)
                .onChange(of: viewModel.currentPhaseIndex) { _, newIndex in
                    withAnimation(.easeInOut(duration: 0.35)) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
            .frame(height: 60) //expand to fill all available space, if not it can ngambil smua height yg di vstack dan bkin layout jelek
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

struct ControlsRowView: View {
    let viewModel: BrewTimerViewModel // links the brains

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
                viewModel.timerState == .running ? viewModel.pause() : viewModel.start() // clicks play
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

// circle buttons
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

struct TimerView: View {
    @Query var recipes: [RecipeItem]
    @Environment(\.modelContext) private var context

    @State private var activeRecipe: RecipeItem? = nil
    @State private var viewModel = BrewTimerViewModel(phases: [])
    @State private var showRecipeList = false
    @State private var showEditRecipe = false
    @State private var showAddRecipe  = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    if let recipe = activeRecipe {
                        Text("\(recipe.coffeeGrams)g · \(recipe.waterMl)ml · \(recipe.formattedTotalTime)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 28)
                    }

                    if viewModel.phases.isEmpty {
                        ProgressView()
                            .frame(width: 260, height: 260)
                            .padding(.bottom, 28)
                    } else {
                        CountdownRingView(viewModel: viewModel)
                            .padding(.bottom, 28)

                        PhaseTrackerView(viewModel: viewModel)
                            .padding(.bottom, 75)
                    }

                    Text(instructionText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, 32)
                        .frame(height: 72, alignment: .top)
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
            .navigationTitle(activeRecipe?.name ?? "Brew")
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
            .onAppear {
                if recipes.isEmpty { seedSampleData() }
                if activeRecipe == nil, let first = recipes.first {
                    activeRecipe = first
                    viewModel = BrewTimerViewModel(phases: first.phases.sorted { $0.sortOrder < $1.sortOrder })
                }
            }
            .onChange(of: recipes) { _, newRecipes in
                if activeRecipe == nil, let first = newRecipes.first {
                    activeRecipe = first
                    viewModel = BrewTimerViewModel(phases: first.phases.sorted { $0.sortOrder < $1.sortOrder })
                } else if let current = activeRecipe, !newRecipes.contains(where: { $0.id == current.id }) {
                    activeRecipe = newRecipes.first
                    viewModel = BrewTimerViewModel(phases: newRecipes.first?.phases.sorted { $0.sortOrder < $1.sortOrder } ?? [])
                }
            }
            .sheet(isPresented: $showRecipeList) {
                // passing current recipe
                Category(currentRecipeName: activeRecipe?.name ?? "") { selected in
                    activeRecipe = selected
                    viewModel = BrewTimerViewModel(phases: selected.phases.sorted { $0.sortOrder < $1.sortOrder })
                }
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showEditRecipe) {
                Recipes(mode: .edit, item: activeRecipe)
                    .presentationDragIndicator(.visible)
            }
            .onChange(of: showEditRecipe) { _, isShowing in
                guard !isShowing, let current = activeRecipe else { return }
                viewModel = BrewTimerViewModel(phases: current.phases.sorted { $0.sortOrder < $1.sortOrder })
            }
            .sheet(isPresented: $showAddRecipe) {
                Recipes(mode: .add)
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

    private func seedSampleData() {
        let samples: [RecipeItem] = [
            RecipeItem(name: "Classic French Press", category: .frenchPress,
                       phases: BrewPhase.frenchPressSample, coffeeGrams: 25, waterMl: 250),
            RecipeItem(name: "Chemex", category: .pourOver,
                       phases: BrewPhase.chemexSample, coffeeGrams: 35, waterMl: 525),
            RecipeItem(name: "Classic Aero Press", category: .aeroPress,
                       phases: BrewPhase.aeropressSample, coffeeGrams: 18, waterMl: 200),
            RecipeItem(name: "Classic Moka Pot", category: .mokaPot,
                       phases: BrewPhase.mokapotSample, coffeeGrams: 15, waterMl: 150),
            RecipeItem(name: "V60", category: .pourOver,
                       phases: BrewPhase.v60Sample, coffeeGrams: 15, waterMl: 250),
        ]
        samples.forEach { context.insert($0) }
    }
}

// MARK: - Preview
#Preview {
    TimerView()
        .modelContainer(for: RecipeItem.self, inMemory: true)
}
