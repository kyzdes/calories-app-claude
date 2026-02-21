import SwiftUI
import SwiftData

struct AddFoodSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = FoodLogViewModel()
    let date: Date
    var preselectedMealType: MealType?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar

                Divider()
                    .background(Color.cmBorder)

                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if viewModel.searchText.count >= 2 {
                            searchResultsSection
                        } else {
                            recentSection
                            frequentSection
                        }

                        // Create product button
                        Button {
                            viewModel.showCreateSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Создать свой продукт")
                            }
                            .font(.cmBody)
                            .foregroundStyle(Color.cmPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .background(Color.cmBgPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                        .foregroundStyle(Color.cmPrimary)
                }
            }
            .onAppear {
                viewModel.loadRecentsAndFrequents(context: modelContext)
                if let meal = preselectedMealType {
                    viewModel.selectedMealType = meal
                }
            }
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.onSearchTextChanged(context: modelContext)
            }
            .sheet(isPresented: $viewModel.showPortionSheet) {
                PortionSheet(viewModel: viewModel, date: date) {
                    viewModel.addFoodEntry(date: date, context: modelContext)
                    dismiss()
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $viewModel.showCreateSheet) {
                CreateProductSheet(viewModel: viewModel, date: date) {
                    viewModel.createAndAddProduct(date: date, context: modelContext)
                    dismiss()
                }
                .presentationDetents([.large])
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.cmTextTertiary)
                    .font(.system(size: 20))

                TextField("Поиск продуктов", text: $viewModel.searchText)
                    .font(.cmBody)

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.cmTextTertiary)
                    }
                }
            }
            .padding(10)
            .background(Color.cmBgTertiary)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // TODO: Итерация 5 — кнопка сканера
            Button {
                // Scanner will be added in Iteration 5
            } label: {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.cmPrimary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Сканировать штрих-код")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Search Results

    @ViewBuilder
    private var searchResultsSection: some View {
        if viewModel.isSearching {
            // Skeleton loader
            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { _ in
                    skeletonRow
                }
            }
        } else if viewModel.searchResults.isEmpty {
            VStack(spacing: 12) {
                Text("Ничего не найдено")
                    .font(.cmBody)
                    .foregroundStyle(Color.cmTextSecondary)

                Button {
                    viewModel.showCreateSheet = true
                } label: {
                    Text("Создать продукт")
                        .font(.cmBodyBold)
                        .foregroundStyle(Color.cmPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        } else {
            if viewModel.isOffline {
                HStack(spacing: 8) {
                    Image(systemName: "wifi.slash")
                        .foregroundStyle(Color.cmWarning)
                    Text("Показаны только локальные результаты")
                        .font(.cmCaption)
                        .foregroundStyle(Color.cmTextSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cmBgSecondary)
            }

            LazyVStack(spacing: 0) {
                ForEach(viewModel.searchResults, id: \.id) { product in
                    FoodSearchResultRow(product: product) {
                        viewModel.selectProduct(product, preselectedMeal: preselectedMealType)
                    }
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
    }

    // MARK: - Recent

    @ViewBuilder
    private var recentSection: some View {
        if !viewModel.recentProducts.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Недавние")
                    .font(.cmH3)
                    .foregroundStyle(Color.cmTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                Divider().padding(.horizontal, 16)

                ForEach(viewModel.recentProducts, id: \.id) { product in
                    FoodSearchResultRow(product: product) {
                        viewModel.selectProduct(product, preselectedMeal: preselectedMealType)
                    }
                    Divider().padding(.leading, 16)
                }
            }
        }
    }

    // MARK: - Frequent

    @ViewBuilder
    private var frequentSection: some View {
        if !viewModel.frequentProducts.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Частые")
                    .font(.cmH3)
                    .foregroundStyle(Color.cmTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                Divider().padding(.horizontal, 16)

                ForEach(viewModel.frequentProducts, id: \.id) { product in
                    FoodSearchResultRow(product: product) {
                        viewModel.selectProduct(product, preselectedMeal: preselectedMealType)
                    }
                    Divider().padding(.leading, 16)
                }
            }
        }
    }

    // MARK: - Skeleton

    private var skeletonRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.cmBgTertiary)
                .frame(width: 200, height: 16)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.cmBgTertiary)
                .frame(width: 150, height: 12)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .shimmering()
    }
}

// MARK: - Shimmer Effect

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .opacity(0.4 + 0.3 * sin(phase))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    phase = .pi
                }
            }
    }
}

private extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}
