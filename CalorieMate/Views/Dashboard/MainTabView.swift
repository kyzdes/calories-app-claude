import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .today
    @State private var showAddFoodSheet = false

    enum Tab {
        case today, progress, body, profile
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(Tab.today)
                    .tabItem {
                        Label("Сегодня", systemImage: "flame.fill")
                    }

                ProgressTabView()
                    .tag(Tab.progress)
                    .tabItem {
                        Label("Прогресс", systemImage: "chart.line.uptrend.xyaxis")
                    }

                // Пустой таб-заглушка для FAB
                Color.clear
                    .tag("fab")
                    .tabItem {
                        Label("", systemImage: "")
                    }

                BodyTrackingView()
                    .tag(Tab.body)
                    .tabItem {
                        Label("Тело", systemImage: "figure.stand")
                    }

                ProfileView()
                    .tag(Tab.profile)
                    .tabItem {
                        Label("Профиль", systemImage: "person.circle")
                    }
            }
            .tint(Color.cmPrimary)

            // FAB button
            fabButton
        }
        .sheet(isPresented: $showAddFoodSheet) {
            AddFoodSheet(date: Date())
                .presentationDetents([.large])
        }
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button {
            showAddFoodSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.cmPrimary)
                .clipShape(Circle())
                .shadow(color: Color.cmPrimary.opacity(0.3), radius: 6, x: 0, y: 4)
        }
        .offset(y: -28)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: showAddFoodSheet)
        .accessibilityLabel("Добавить еду")
        .accessibilityHint("Откроет экран добавления продукта")
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [
            Product.self, FoodEntry.self, WeightEntry.self,
            BodyMeasurement.self, UserProfile.self
        ], inMemory: true)
}
