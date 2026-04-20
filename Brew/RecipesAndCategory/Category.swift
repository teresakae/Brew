import SwiftUI

struct RecipeItem: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let icon: String
}

struct Category: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selected = "All"
    @State private var currentRecipe = "V60"

    let filterCategories = ["All", "Pour Over", "French Press", "Aero Press", "Moka Pot", "Espresso", "Others"]

    let recipes: [RecipeItem] = [
        RecipeItem(name: "V60",                  category: "Pour Over",    icon: "cup.and.saucer.fill"),
        RecipeItem(name: "Chemex",               category: "Pour Over",    icon: "cup.and.saucer.fill"),
        RecipeItem(name: "Classic French Press", category: "French Press", icon: "cup.and.saucer.fill"),
        RecipeItem(name: "Classic Aero Press",   category: "Aero Press",   icon: "cup.and.saucer.fill"),
        RecipeItem(name: "Inverted",             category: "Aero Press",   icon: "cup.and.saucer.fill"),
        RecipeItem(name: "Classic Moka",         category: "Moka Pot",     icon: "cup.and.saucer.fill"),
        RecipeItem(name: "Single Shot",          category: "Espresso",     icon: "cup.and.saucer.fill"),
        RecipeItem(name: "Double Shot",          category: "Espresso",     icon: "cup.and.saucer.fill"),
    ]

    var filteredRecipes: [RecipeItem] {
        selected == "All" ? recipes : recipes.filter { $0.category == selected }
    }

    let accent = Color(red: 0.765, green: 0.839, blue: 0.427)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Filter scroll view
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

                // Recipe list
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
                        currentRecipe = recipe.name
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Choose the Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    Color.black.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            Category()
                .presentationDragIndicator(.visible)
        }
}

