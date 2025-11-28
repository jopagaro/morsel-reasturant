import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ListingView()
                .tabItem { Label("Listing", systemImage: "square.and.pencil") }

            OrdersView()
                .tabItem { Label("Orders", systemImage: "cart") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }

            MenuView()
                .tabItem { Label("Menu", systemImage: "fork.knife") }
        }
        .background(Color(.systemGroupedBackground))
        .tint(.accentColor)
    }
}

// MARK: - Primary: Listing flow

struct ListingView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var quantity: Int = 1
    @State private var category: String = "Prepared Food"
    @State private var pickupWindow: String = "Today 5–8 PM"
    @State private var pickupAvailableNow: Bool = true
    @State private var pickupStart: Date = Date()
    @State private var pickupEnd: Date = Calendar.current.date(byAdding: .hour, value: 3, to: Date()) ?? Date()
    @State private var leadTimeMinutes: Int = 10
    @State private var sellUntilEndTime: Bool = true
    @State private var pickupInstructions: String = "Ring bell on arrival; pickup at side door."
    @State private var pickupLocation: String = "123 Market St, Side Entrance"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Create a new listing")
                                .font(.title2).bold()
                            Text("Make it easy for customers to find what's available today.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.tint)
                            .padding(10)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .padding(.horizontal, 2)

                    // Quick actions
                    quickActions

                    // Listing form essentials
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Listing Details")
                            .font(.headline)
                        TextField("Title (e.g., Surplus Sandwiches)", text: $title)
                            .textFieldStyle(.roundedBorder)
                        TextField("Short description", text: $description, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...4)

                        HStack {
                            TextField("Price", text: $price)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            Stepper("Qty: \(quantity)", value: $quantity, in: 1...500)
                        }

                        Picker("Category", selection: $category) {
                            Text("Prepared Food").tag("Prepared Food")
                            Text("Bakery").tag("Bakery")
                            Text("Produce").tag("Produce")
                            Text("Beverage").tag("Beverage")
                            Text("Other").tag("Other")
                        }
                        .pickerStyle(.menu)

                        Picker("Pickup Window", selection: $pickupWindow) {
                            Text("Today 5–8 PM").tag("Today 5–8 PM")
                            Text("Tonight 8–10 PM").tag("Tonight 8–10 PM")
                            Text("Tomorrow 11–2 PM").tag("Tomorrow 11–2 PM")
                        }
                        .pickerStyle(.menu)

                    // Pickup Availability (ResQ-like)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "bag.fill")
                                .foregroundStyle(.tint)
                            Text("Pickup Availability").font(.headline)
                            Spacer()
                            Toggle("Available Now", isOn: $pickupAvailableNow)
                                .labelsHidden()
                        }

                        if !pickupAvailableNow {
                            // Quick chips
                            HStack(spacing: 8) {
                                Button("Today") {
                                    let now = Date()
                                    pickupStart = now
                                    pickupEnd = Calendar.current.date(byAdding: .hour, value: 3, to: now) ?? now
                                }
                                .buttonStyle(.bordered)
                                Button("Tonight") {
                                    var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                                    comps.hour = 20; comps.minute = 0
                                    let start = Calendar.current.date(from: comps) ?? Date()
                                    pickupStart = start
                                    pickupEnd = Calendar.current.date(byAdding: .hour, value: 2, to: start) ?? start
                                }
                                .buttonStyle(.bordered)
                                Button("Tomorrow") {
                                    let start = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                                    pickupStart = start
                                    pickupEnd = Calendar.current.date(byAdding: .hour, value: 3, to: start) ?? start
                                }
                                .buttonStyle(.bordered)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Pickup window")
                                    .font(.subheadline).foregroundStyle(.secondary)
                                HStack {
                                    DatePicker("Start", selection: $pickupStart, displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(.compact)
                                    DatePicker("End", selection: $pickupEnd, displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(.compact)
                                }
                            }
                        }

                        HStack {
                            Stepper(value: $leadTimeMinutes, in: 0...120, step: 5) {
                                Text("Prep lead time: \(leadTimeMinutes) min")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Toggle(isOn: $sellUntilEndTime) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sell until end of pickup window")
                                Text("When off, listing may end early when stock runs out.")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }

                        TextField("Pickup instructions (shown after purchase)", text: $pickupInstructions, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(1...3)

                        TextField("Pickup location (optional)", text: $pickupLocation)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.primary.opacity(0.06)))
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.primary.opacity(0.06)))
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)

                    // Publish
                    Button {
                        // TODO: validate and publish listing
                    } label: {
                        Label("Publish Listing", systemImage: "paperplane.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
                    .padding(.top, 4)
                }
                .padding()
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Make a Listing")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
        }
    }

    private var quickActions: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    // TODO: super quick listing flow
                } label: {
                    Label("Quick Upload", systemImage: "bolt.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    // TODO: duplicate last listing
                } label: {
                    Label("Repeat Last", systemImage: "clock.arrow.circlepath")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            NavigationLink {
                ActiveListingsView()
            } label: {
                Label("Manage Active Listings", systemImage: "list.bullet.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(.top, 4)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.primary.opacity(0.06)))
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
    }
}

struct ActiveListingsView: View {
    var body: some View {
        List {
            Section("Active") {
                ForEach(0..<3) { idx in
                    NavigationLink("Listing #\(200 + idx)", destination: Text("Listing details (placeholder)"))
                }
            }
            Section("Drafts") {
                ForEach(0..<2) { idx in
                    NavigationLink("Draft #\(10 + idx)", destination: Text("Draft details (placeholder)"))
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Your Listings")
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
    }
}

// MARK: - Orders (unchanged core, prioritized tab position)

struct OrdersView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Incoming") {
                    ForEach(0..<5) { idx in
                        NavigationLink("Order #\(1000 + idx)", destination: Text("Order details for #\(1000 + idx) (placeholder)"))
                    }
                }
                Section("Actions") {
                    Button("New order") {}
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Orders")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
        }
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
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.primary.opacity(0.06)))
            .shadow(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 8)
            .padding()
            .navigationTitle("Profile")
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
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Color.primary.opacity(0.06)))
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
                }
            }
            Section("Actions") {
                Button("Manage set menu") {}
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }
}

struct GiveawaysList: View {
    var body: some View {
        List {
            Section("Available Now") {
                ForEach(0..<3) { idx in
                    NavigationLink("Giveaway #\(idx + 1)", destination: Text("Giveaway details (placeholder)"))
                }
            }
            Section("Actions") {
                Button("Upload giveaway") {}
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ContentView()
}
