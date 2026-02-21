import SwiftUI

struct MealSectionView: View {
    let mealType: MealType
    let entries: [FoodEntry]
    let totalCalories: Int
    let onAddFood: () -> Void
    let onTapEntry: (FoodEntry) -> Void
    let onDeleteEntry: (FoodEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: mealType.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color.cmPrimary)

                Text(mealType.displayName)
                    .font(.cmH3)
                    .foregroundStyle(Color.cmTextPrimary)

                Spacer()

                Text("\(totalCalories)\u{00A0}ккал")
                    .font(.cmNumberMd)
                    .foregroundStyle(Color.cmTextPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
                .background(Color.cmBorder)
                .padding(.horizontal, 16)

            // Entries
            if entries.isEmpty {
                Button(action: onAddFood) {
                    Text("+ \(mealType.addButtonTitle)")
                        .font(.cmBody)
                        .foregroundStyle(Color.cmPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(entries, id: \.id) { entry in
                        FoodEntryRow(entry: entry) {
                            onTapEntry(entry)
                        }
                        .padding(.horizontal, 16)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                onDeleteEntry(entry)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }

                    // Add button
                    Button(action: onAddFood) {
                        Text("+ Добавить")
                            .font(.cmBody)
                            .foregroundStyle(Color.cmPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
            }
        }
        .background(Color.cmBgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(mealType.displayName), \(totalCalories) килокалорий, \(entries.count) продуктов")
    }
}
