import SwiftUI

private enum Theme {
    static let primary = Color.accentColor
    static let green = Color(hue: 0.36, saturation: 0.42, brightness: 0.58) // Sage
    static let blue = Color(hue: 0.57, saturation: 0.38, brightness: 0.68)  // Slate blue
    static let orange = Color(hue: 0.08, saturation: 0.55, brightness: 0.95) // Soft apricot

    static let brandGradient = LinearGradient(
        colors: [Color(.systemBackground), blue.opacity(0.18)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let headerGradient = LinearGradient(
        colors: [blue.opacity(0.20), green.opacity(0.18)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

struct ContentView: View {
    var body: some View {
        ZStack {
            Theme.brandGradient.ignoresSafeArea()
            TabView {
                OrdersView()
                    .tabItem { Label("Orders", systemImage: "cart") }

                ListingView()
                    .tabItem { Label("Listing", systemImage: "square.and.pencil") }

                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person") }

                MenuView()
                    .tabItem { Label("Menu", systemImage: "fork.knife") }
            }
            .background(.clear)
            .tint(Theme.blue)
        }
    }
}

// MARK: - Primary: Listing flow

struct ListingView: View {
    @State private var title: String = ""
    @State private var price: String = ""
    @State private var quantity: Int = 1
    @State private var pickupWindow: String = "Today 5–8 PM"
    @State private var pickupAvailableNow: Bool = true
    @State private var pickupStart: Date = Date()
    @State private var pickupEnd: Date = Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date()
    @State private var leadTimeMinutes: Int = 10
    @State private var sellUntilEndTime: Bool = true
    @State private var pickupInstructions: String = "Ring bell on arrival; pickup at side door."
    @State private var pickupLocation: String = "123 Market St, Side Entrance"
    
    @State private var dietaryTags: Set<String> = []
    private let tagOptions: [String] = [
        // Dietary patterns
        "Vegan", "Vegetarian", "Pescatarian", "Keto", "Paleo", "Low Carb", "Low Fat", "High Protein",
        // Allergen-friendly / free-from
        "Gluten Free", "Dairy Free", "Lactose Free", "Nut Free", "Peanut Free", "Tree Nut Free", "Egg Free", "Soy Free", "Sesame Free", "Shellfish Free", "Fish Free",
        // Ingredients / sourcing
        "Organic", "Non-GMO", "Locally Sourced", "Seasonal",
        // Religious / certification
        "Kosher", "Halal",
        // Other labels
        "No Added Sugar", "Sugar Free", "Spicy", "Mild", "Kids Menu", "Contains Alcohol"
    ]

    private var estimatedEarnings: String {
        let p = Double(price) ?? 0
        let total = p * Double(quantity)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        return formatter.string(from: NSNumber(value: total)) ?? "$0.00"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 0) {
                            TextField("Item title (e.g., Surplus Sandwiches)", text: $title)
                                .textInputAutocapitalization(.words)
                                .font(.headline)
                                .padding(.vertical, 12)
                        }

                        DisclosureGroup("Tags") {
                            VStack(spacing: 0) {
                                ForEach(tagOptions, id: \.self) { option in
                                    Toggle(isOn: Binding(
                                        get: { dietaryTags.contains(option) },
                                        set: { newValue in
                                            if newValue { dietaryTags.insert(option) } else { dietaryTags.remove(option) }
                                        }
                                    )) {
                                        Text(option)
                                    }
                                    .toggleStyle(.switch)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 2)
                                    Divider()
                                }
                            }
                            .padding(.top, 4)
                        }
                    } header: {
                        Text("Details")
                    }

                    Section {
                        HStack {
                            Text("Price")
                            Spacer()
                            HStack(spacing: 6) {
                                Text("$")
                                    .foregroundStyle(.secondary)
                                TextField("0.00", text: $price)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(minWidth: 60)
                            }
                        }
                        Stepper(value: $quantity, in: 1...500) {
                            HStack {
                                Text("Quantity")
                                Spacer()
                                Text("\(quantity)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } header: {
                        Text("Pricing & Inventory")
                    }

                    Section {
                        Toggle("Available now", isOn: $pickupAvailableNow)
                        if !pickupAvailableNow {
                            DatePicker("Start", selection: $pickupStart, displayedComponents: [.date, .hourAndMinute])
                            DatePicker("End", selection: $pickupEnd, displayedComponents: [.date, .hourAndMinute])
                        }
                        Stepper(value: $leadTimeMinutes, in: 0...120, step: 5) {
                            HStack {
                                Text("Prep lead time")
                                Spacer()
                                Text("\(leadTimeMinutes) min").foregroundStyle(.secondary)
                            }
                        }
                        Toggle("Sell until end of window", isOn: $sellUntilEndTime)
                    } header: {
                        Text("Availability")
                    }

                    Section {
                        TextField("Pickup instructions (shown after purchase)", text: $pickupInstructions, axis: .vertical)
                            .lineLimit(1...3)
                        TextField("Pickup location (optional)", text: $pickupLocation)
                    } header: {
                        Text("Pickup")
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                .contentMargins(.top, 0, for: .scrollContent)
                .contentMargins(.bottom, 24, for: .scrollContent)
                // Bounce behavior: new API on iOS 18+
                .applyBounceBehavior()
            }
            .navigationTitle("Make a Listing")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Estimated earnings")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(estimatedEarnings)
                                .font(.headline)
                        }
                        Spacer()
                        Button {
                            // TODO: validate and publish listing
                        } label: {
                            Text("Publish")
                                .fontWeight(.semibold)
                                .frame(maxWidth: 180)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.blue)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.primary.opacity(0.06)))
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
}

struct ActiveListingsView: View {
    var body: some View {
        List {
            Section("Active") {
                ForEach(0..<3) { idx in
                    NavigationLink("Listing #\(200 + idx)", destination: Text("Listing details (placeholder)"))
                        .listRowBackground(Color.clear)
                }
            }
            Section("Drafts") {
                ForEach(0..<2) { idx in
                    NavigationLink("Draft #\(10 + idx)", destination: Text("Draft details (placeholder)"))
                        .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Your Listings")
        .tint(Theme.blue)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
        .headerProminence(.increased)
    }
}

// MARK: - Orders (unchanged core, prioritized tab position)

struct OrdersView: View {
    struct Order: Identifiable {
        let id: UUID
        let number: String
        let customer: String
        let total: String
        let placedAt: Date
        let status: String
    }

    @State private var orders: [Order] = [] // No fake orders by default
    @State private var isRefreshing: Bool = false

    private func refresh() async {
        await MainActor.run { isRefreshing = true }
        // TODO: hook up to real data fetch
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run { isRefreshing = false }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                if orders.isEmpty {
                    VStack {
                        Spacer(minLength: 0)
                        emptyState
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ordersList
                }
            }
            .refreshable { await refresh() }
            .overlay(alignment: .top) {
                if isRefreshing {
                    Text("Refreshing…")
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(Capsule().strokeBorder(Color.primary.opacity(0.08)))
                        .padding(.top, 8)
                }
            }
            .navigationTitle("Orders")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .background(Color(.systemGroupedBackground))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(colors: [Theme.blue.opacity(0.28), Theme.green.opacity(0.28)], startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.25))
            }
            .frame(height: 180)
            .overlay(
                Image(systemName: "cart")
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(.white)
            )

            VStack(spacing: 6) {
                Text("No orders yet")
                    .font(.title2).bold()
                Text("When an order is received, you’ll be notified here.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 16)
        .padding(.horizontal) // system default horizontal padding
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.thinMaterial)
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
        )
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.primary.opacity(0.06)))
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal) // bring card closer to edges
        .background(Color(.systemGroupedBackground))
    }

    private var ordersList: some View {
        List {
            Section("Incoming") {
                ForEach(orders) { order in
                    NavigationLink(
                        destination: Text("Order details for #\(order.number) (placeholder)"),
                        label: { OrderRow(order: order) }
                    )
                    .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .headerProminence(.increased)
    }
}

private struct OrderRow: View {
    let order: OrdersView.Order

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(LinearGradient(colors: [Theme.blue.opacity(0.55), Theme.green.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing))
                Image(systemName: "shippingbox")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("#\(order.number)")
                        .font(.headline)
                    Spacer()
                    Text(order.total)
                        .font(.headline)
                }
                HStack(spacing: 6) {
                    Text(order.customer)
                    Text("•")
                    Text(order.status)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Color.primary.opacity(0.06)))
    }
}

// MARK: - Profile (unchanged)

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 72))
                Text("Restaurant Admin")
                    .font(.title2).bold()
                Text("Sign in to sync menu, orders, and reservations across devices.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                HStack {
                    Button("Sign In") {}
                        .buttonStyle(.borderedProminent)
                    Button("Create Account") {}
                        .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.primary.opacity(0.06)))
            .shadow(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 8)
            .padding()
            .navigationTitle("Profile")
            .tint(Theme.blue)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
        }
    }
}

// MARK: - De-emphasized Menu (set menu vs giveaways)

struct MenuView: View {
    @State private var selection: MenuSection = .giveaways

    enum MenuSection: String, CaseIterable, Identifiable { case setMenu = "Set Menu", giveaways = "Giveaways"; var id: String { rawValue } }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Section", selection: $selection) {
                    ForEach(MenuSection.allCases) { sec in
                        Text(sec.rawValue).tag(sec)
                    }
                }
                .pickerStyle(.segmented)
                .padding(12)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.primary.opacity(0.06)))
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)

                Group {
                    switch selection {
                    case .setMenu:
                        SetMenuList()
                    case .giveaways:
                        GiveawaysList()
                    }
                }
            }
            .navigationTitle("Menu")
            .tint(Theme.blue)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
        }
    }
}

struct SetMenuList: View {
    var body: some View {
        List {
            Section("Set Menu") {
                ForEach(0..<5) { idx in
                    HStack {
                        Image(systemName: "fork.knife.circle")
                        VStack(alignment: .leading) {
                            Text("Menu Item #\(idx + 1)")
                            Text("Always available").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
            Section("Actions") {
                Button("Manage set menu") {}
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .headerProminence(.increased)
        .tint(Theme.blue)
    }
}

struct GiveawaysList: View {
    var body: some View {
        List {
            Section("Available Now") {
                ForEach(0..<3) { idx in
                    NavigationLink("Giveaway #\(idx + 1)", destination: Text("Giveaway details (placeholder)"))
                        .listRowBackground(Color.clear)
                }
            }
            Section("Actions") {
                Button("Upload giveaway") {}
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .headerProminence(.increased)
        .tint(Theme.blue)
    }
}

struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let spacing: CGFloat
    let lineSpacing: CGFloat
    let content: (Data.Element) -> Content

    init(items: Data, spacing: CGFloat = 8, lineSpacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            self.generateContent(in: proxy.size.width)
        }
        .frame(minHeight: 0)
    }

    private func generateContent(in availableWidth: CGFloat) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
                    .alignmentGuide(.leading) { d in
                        if abs(width - d.width) > availableWidth {
                            width = 0
                            height -= d.height + lineSpacing
                        }
                        let result = width
                        if item == items.last { width = 0 } else { width -= d.width + spacing }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == items.last { height = 0 }
                        return result
                    }
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func applyBounceBehavior() -> some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            self.scrollBounceBehavior(.basedOnSize, axes: [])
        } else {
            self
        }
    }
}

#Preview {
    ContentView()
}
