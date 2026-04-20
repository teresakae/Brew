//
//  ContentView.swift
//  BrewCofffee
//
//  Created by Gabriella Dina Widieaster on 19/04/26.
//

import SwiftUI

struct Recipes: View {
    @State private var title = ""
    @State private var description = ""
    @State private var notificationsOn = false
    @State private var category = "Work"
    @State private var coffeeDose = ""
    @State private var waterDose = ""
    @State private var grindSize = "Very fine"
    @State private var waterTDS = ""
    @State private var beanOrigin = ""
    
    // Array to store steps
    @State private var steps: [BrewStep] = [BrewStep()]
    
    // State for showing delete confirmation
    @State private var showDeleteConfirmation = false
    
    // Computed property for total brew time
    var totalBrewTime: String {
        let totalMinutes = steps.reduce(0) { $0 + (Int($1.minutes) ?? 0) }
        let totalSeconds = steps.reduce(0) { $0 + (Int($1.seconds) ?? 0) }
        let finalMinutes = totalMinutes + (totalSeconds / 60)
        let finalSeconds = totalSeconds % 60
        return String(format: "%d min %02d sec", finalMinutes, finalSeconds)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Recipe Name", text: $title)
                    Picker("Category", selection: $category) {
                        Text("V60").tag("V60")
                        Text("Personal").tag("Personal")
                    }
                }
                Section("Ingredients") {
                    TextField("Coffee Dose", text: $coffeeDose)
                    TextField("Water Dose", text: $waterDose)
                }
                Section("Details (optional)") {
                    Picker("Grind Size", selection: $grindSize) {
                        Text("Very fine").tag("Very fine")
                    }
                    TextField("Water TDS", text: $waterTDS)
                    TextField("Bean Origin", text: $beanOrigin)
                }
                
                // Each step in its own section
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    Section("Step \(index + 1)") {
                        VStack(spacing: 0) {
                            // Recipe name placeholder
                            TextField("Recipe name", text: binding(for: step).recipeName)
                                .padding(.vertical, 11)
                            
                            Divider()
                                .padding(.leading, 0)
                            
                            // Instructions placeholder
                            TextField("Instructions", text: binding(for: step).instructions, axis: .vertical)
                                .lineLimit(3...6)
                                .padding(.vertical, 11)
                            
                            Divider()
                                .padding(.leading, 0)
                            
                            // Time spent
                            HStack {
                                Text("Time spent")
                                
                                Spacer()
                                
                                // Minutes text field
                                TextField("0", text: binding(for: step).minutes)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 40)
                                
                                Text("min")
                                
                                // Seconds text field
                                TextField("0", text: binding(for: step).seconds)
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
                        }
                    }
                }
                .onMove(perform: moveStep)
                
                // Add new step button
                Section {
                    Button {
                        addStep()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Step")
                        }
                    }
                }
                
                // Total brew time outside the Steps section
                Section {
                    HStack {
                        Text("Total brew time")
                        Spacer()
                        Text(totalBrewTime)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Delete Recipe button at the bottom
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
            .navigationTitle("Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addStep()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .tint(Color(red: 0.73, green: 0.84, blue: 0.18))
            .alert("Delete Recipe?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteRecipe()
                }
            } message: {
                Text("Are you sure you want to delete this recipe? This action cannot be undone.")
            }
        }
    }
    
    // Helper to get binding for a specific step
    private func binding(for step: BrewStep) -> Binding<BrewStep> {
        guard let index = steps.firstIndex(where: { $0.id == step.id }) else {
            fatalError("Step not found")
        }
        return $steps[index]
    }
    
    // Function to add new step
    func addStep() {
        steps.append(BrewStep())
    }
    
    // Function to delete a specific step
    func deleteStep(_ step: BrewStep) {
        steps.removeAll { $0.id == step.id }
    }
    
    // Function to move/reorder steps
    func moveStep(from source: IndexSet, to destination: Int) {
        steps.move(fromOffsets: source, toOffset: destination)
    }
    
    // Function to delete the entire recipe
    func deleteRecipe() {
        print("Recipe deleted")
    }
}

#Preview {
    Recipes()
}
