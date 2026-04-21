//
//  Category.swift
//  Brew
//
//  Created by Teresa Kae on 20/04/26.
//

import SwiftUI

struct Category: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selected = "All"
    let currentRecipe: String

    let store: RecipeStore
    var onSelect: (RecipeItem) -> Void

    let filterCategories = ["All", "Pour Over", "French Press", "Aero Press", "Moka Pot", "Espresso", "Others"]

    var filteredRecipes: [RecipeItem] {
        selected == "All" ? store.recipes : store.recipes.filter { $0.category == selected }
    }

    let accent = Color(red: 0.765, green: 0.839, blue: 0.427)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filterCategories, id: \.self) { category in
                            Text(category)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule().fill(
                                        selected == category
                                            ? AnyShapeStyle(accent.opacity(0.65))
                                            : AnyShapeStyle(.ultraThinMaterial)
                                    )
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selected = category
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)

                List(filteredRecipes) { recipe in
                    HStack(spacing: 14) {
                        Image(systemName: recipe.icon)
                            .font(.title2)
                            .foregroundStyle(accent)
                            .frame(width: 36)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(recipe.name)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(recipe.name == currentRecipe ? accent : .primary)
                            Text(recipe.category)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if recipe.name == currentRecipe {
                            Circle()
                                .fill(accent)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect(recipe)
                        dismiss()
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Choose the Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}
