//
//  Recipes.swift
//  Brew
//
//  Created by Teresa Kae on 20/04/26.
//

import SwiftUI
import SwiftData

struct Recipes: View {
    var mode: RecipeMode = .add
    var item: RecipeItem? = nil

    @Environment(\.dismiss) private var dismiss // for the sheet
    @Environment(\.modelContext) private var context // to look into the database

    @State private var recipe = RecipeData()
    @State private var showDeleteConfirmation = false

    var totalBrewTime: String {
        let totalMinutes = recipe.steps.reduce(0) { $0 + (Int($1.minutes) ?? 0) }
        let totalSeconds = recipe.steps.reduce(0) { $0 + (Int($1.seconds) ?? 0) }
        let finalMinutes = totalMinutes + (totalSeconds / 60)
        let finalSeconds = totalSeconds % 60
        return String(format: "%d min %02d sec", finalMinutes, finalSeconds)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Recipe Name", text: $recipe.title)
                    Picker("Category", selection: $recipe.category) {
                        ForEach(BrewCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }

                Section("Ingredients") {
                    TextField("Coffee Dose (g)", text: $recipe.coffeeDose)
                        .keyboardType(.numberPad)
                    TextField("Water Dose (ml)", text: $recipe.waterDose)
                        .keyboardType(.numberPad)
                }

                Section("Details (optional)") {
                    Picker("Grind Size", selection: $recipe.grindSize) {
                        Text("Very fine").tag("Very fine")
                        Text("Fine").tag("Fine")
                        Text("Medium fine").tag("Medium fine")
                        Text("Medium").tag("Medium")
                        Text("Coarse").tag("Coarse")
                    }
                    TextField("Water TDS", text: $recipe.waterTDS)
                    TextField("Bean Origin", text: $recipe.beanOrigin)
                }

                Section("Brew Steps") {
                    ForEach($recipe.steps) { $step in
                        let index = recipe.steps.firstIndex(where: { $0.id == step.id }) ?? 0

                        VStack(spacing: 0) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 22, height: 22)
                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.black)
                                }
                                TextField("Step name", text: $step.recipeName)
                            }
                            .padding(.vertical, 11)
                            Divider()
                            TextField("Instructions", text: $step.instructions, axis: .vertical)
                                .lineLimit(3...6)
                                .padding(.vertical, 11)
                            Divider()
                            HStack {
                                Text("Time spent")
                                Spacer()
                                TextField("0", text: $step.minutes)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 40)
                                Text("min")
                                TextField("0", text: $step.seconds)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 40)
                                Text("sec")
                            }
                            .padding(.vertical, 11)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteStep(step)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                    .onMove(perform: moveStep)
                }

                Section {
                    Button { addStep() } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Step")
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Total brew time")
                        Spacer()
                        Text(totalBrewTime).foregroundStyle(.secondary)
                    }
                }

                if mode == .edit {
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Recipe")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(mode == .add ? "Add Recipe" : "Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveRecipe()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .tint(Color(red: 0.73, green: 0.84, blue: 0.18))
            .onAppear {
                guard let item else { return }
                recipe.title = item.name
                recipe.category = item.category
                recipe.coffeeDose = String(item.coffeeGrams)
                recipe.waterDose = String(item.waterMl)
                recipe.steps = item.phases
                    .sorted { $0.sortOrder < $1.sortOrder }
                    .map { phase in
                        var step = BrewStep()
                        step.recipeName = phase.name
                        step.instructions = phase.instruction
                        step.minutes = String(Int(phase.duration) / 60)
                        step.seconds = String(Int(phase.duration) % 60)
                        return step
                    }
            }
            .alert("Delete Recipe?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) { deleteRecipe() }
            } message: {
                Text("Are you sure you want to delete this recipe? This action cannot be undone.")
            }
        }
    }

    private func saveRecipe() {
        let phases = recipe.steps.enumerated().map { index, step in
            BrewPhase(
                name: step.recipeName,
                duration: TimeInterval((Int(step.minutes) ?? 0) * 60 + (Int(step.seconds) ?? 0)),
                instruction: step.instructions,
                sortOrder: index
            )
        }

        if let existing = item {
            existing.name = recipe.title.isEmpty ? "Untitled Recipe" : recipe.title
            existing.category = recipe.category
            existing.coffeeGrams = Int(recipe.coffeeDose) ?? 0
            existing.waterMl = Int(recipe.waterDose) ?? 0
            existing.phases.forEach { context.delete($0) }
            existing.phases = phases
        } else {
            let newItem = RecipeItem(
                name: recipe.title.isEmpty ? "Untitled Recipe" : recipe.title,
                category: recipe.category,
                phases: phases,
                coffeeGrams: Int(recipe.coffeeDose) ?? 0,
                waterMl: Int(recipe.waterDose) ?? 0
            )
            context.insert(newItem)
        }
    }

    func addStep() { recipe.steps.append(BrewStep()) }
    func deleteStep(_ step: BrewStep) { recipe.steps.removeAll { $0.id == step.id } }
    func moveStep(from source: IndexSet, to destination: Int) {
        recipe.steps.move(fromOffsets: source, toOffset: destination)
    }
    func deleteRecipe() {
        guard let item else { return }
        context.delete(item)
        dismiss()
    }
}

//#Preview {
//    Recipes(mode: .add)
//        .modelContainer(for: RecipeItem.self, inMemory: true)
//}
