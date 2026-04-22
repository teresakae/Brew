import SwiftUI

struct Category: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: BrewCategory? = nil
    let currentRecipe: String
    let store: RecipeStore
    var onSelect: (RecipeItem) -> Void
    
    var filteredRecipes: [RecipeItem] {
        guard let selected = selectedCategory else { return store.recipes }
        return store.recipes.filter { $0.category == selected }
    }

    let accent = Color(red: 0.765, green: 0.839, blue: 0.427)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChip(title: "All", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(BrewCategory.allCases, id: \.self) { category in
                            filterChip(title: category.rawValue, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)

                List(filteredRecipes) { recipe in
                    HStack(spacing: 14) {
                        
                        if recipe.category == .others {
                            Image(systemName: recipe.category.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(accent)
                        } else {
                            Image(recipe.category.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                        }
                        
                    VStack(alignment: .leading, spacing: 2) {
                            Text(recipe.name)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(recipe.name == currentRecipe ? accent : .primary)
                            Text(recipe.category.rawValue)
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

    @ViewBuilder
    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Text(title)
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(
                    isSelected
                    ? AnyShapeStyle(accent.opacity(0.65))
                    : AnyShapeStyle(.ultraThinMaterial)
                )
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    action()
                }
            }
    }
}

#Preview {
    Category(
        currentRecipe: "Classic French Press",
        store: RecipeStore(),
        onSelect: { _ in }
    )
}
