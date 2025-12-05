import SwiftUI
import Auth
#if canImport(UIKit)
import UIKit
#endif

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
                NavigationStack {
                    VStack(spacing: 16) {
                        // Empty state card for Orders
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "cart")
                                .font(.title2)
                                .foregroundStyle(Theme.blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("No orders yet")
                                    .font(.headline)
                                Text("When customers place orders, they’ll show up here.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.primary.opacity(0.06))
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
                        .padding(.horizontal)

                        Spacer()
                    }
                    .navigationTitle("Orders")
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
                }
                .tabItem { Label("Orders", systemImage: "cart") }

                ListingView()
                    .tabItem { Label("Listing", systemImage: "square.and.pencil") }

                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person") }
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
    @State private var isPublishing: Bool = false
    @State private var showPublishAlert: Bool = false
    @State private var publishAlertMessage: String = ""
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
                            Task { await publishCurrentListing() }
                        } label: {
                            HStack(spacing: 8) {
                                if isPublishing {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                }
                                Text(isPublishing ? "Publishing…" : "Publish")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: 180)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.blue)
                        .disabled(isPublishing)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.primary.opacity(0.06)))
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .alert("Publish", isPresented: $showPublishAlert, actions: { Button("OK", role: .cancel) {} }, message: { Text(publishAlertMessage) })
            }
        }
    }

    @MainActor
    private func publishCurrentListing() async {
        isPublishing = true
        publishAlertMessage = ""
        guard
            let restaurantUUID = UUID(uuidString: UserDefaults.standard.string(forKey: "restaurantId") ?? ""),
            let locationUUID = UUID(uuidString: UserDefaults.standard.string(forKey: "locationId") ?? "")
        else {
            publishAlertMessage = "Please create a restaurant and location in Profile before publishing."
            showPublishAlert = true
            isPublishing = false
            return
        }
        let restaurantId = restaurantUUID
        let locationId = locationUUID

        do {
            let basePrice = Double(price) ?? 0
            let item = try await createItem(
                restaurantId: restaurantId,
                title: title.isEmpty ? "Untitled Item" : title,
                description: nil,
                basePrice: basePrice
            )

            if let itemId = item.id {
                try await attachTags(to: itemId, names: dietaryTags)

                let _ = try await createListing(
                    itemId: itemId,
                    locationId: locationId,
                    titleOverride: nil,
                    price: Double(price) ?? 0,
                    quantity: quantity,
                    availableNow: pickupAvailableNow,
                    startAt: pickupAvailableNow ? nil : pickupStart,
                    endAt: pickupAvailableNow ? nil : pickupEnd,
                    leadTimeMinutes: leadTimeMinutes,
                    sellUntilEnd: sellUntilEndTime,
                    pickupInstructions: pickupInstructions
                )

                print("Listing published successfully")
                publishAlertMessage = "Your listing was published successfully."
                #if canImport(UIKit)
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                #endif
                showPublishAlert = true
            } else {
                print("Failed to obtain created item ID")
                publishAlertMessage = "We couldn't obtain the created item ID. Please try again."
                #if canImport(UIKit)
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                #endif
                showPublishAlert = true
            }
        } catch {
            print("Publish failed: \(error.localizedDescription)")
            publishAlertMessage = "Publish failed: \(error.localizedDescription)"
            #if canImport(UIKit)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            #endif
            showPublishAlert = true
        }
        isPublishing = false
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

// MARK: - Temporary backend stubs (replace with real implementations)
struct CreatedRestaurantResult { let id: UUID }
struct CreatedLocationResult { let id: UUID }

@discardableResult
func createRestaurant(name: String, address: String?) async throws -> CreatedRestaurantResult {
    // TODO: Replace with real network/database call
    try await Task.sleep(nanoseconds: 200_000_000) // simulate latency
    return CreatedRestaurantResult(id: UUID())
}

@discardableResult
func createLocation(restaurantId: UUID, address: String?) async throws -> CreatedLocationResult {
    // TODO: Replace with real network/database call
    try await Task.sleep(nanoseconds: 200_000_000) // simulate latency
    return CreatedLocationResult(id: UUID())
}

func linkRestaurantToCurrentUser(restaurantId: UUID) async throws {
    // TODO: Replace with real link logic (e.g., update profiles with restaurant_id)
    try await Task.sleep(nanoseconds: 150_000_000)
}

// MARK: - Profile (unchanged)

struct ProfileView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var status: String = ""
    @State private var isSignedIn: Bool = false
    @State private var userEmail: String = ""
    @State private var restaurantName: String = ""
    @State private var restaurantAddress: String = ""
    @State private var isCreatingRestaurant: Bool = false
    @State private var showRestaurantAlert: Bool = false
    @State private var restaurantAlertMessage: String = ""
    @AppStorage("restaurantId") private var storedRestaurantId: String = ""
    @AppStorage("locationId") private var storedLocationId: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if isSignedIn {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 72))
                    Text("Signed in as")
                        .font(.headline)
                    Text(userEmail)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Restaurant")
                            .font(.headline)
                        TextField("Restaurant name", text: $restaurantName)
                            .padding()
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                        TextField("Restaurant address / location", text: $restaurantAddress)
                            .textContentType(.fullStreetAddress)
                            .padding()
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                        Button {
                            Task { await createRestaurantForProfile() }
                        } label: {
                            HStack(spacing: 8) {
                                if isCreatingRestaurant { ProgressView() }
                                Text(isCreatingRestaurant ? "Saving…" : "Create Restaurant")
                                    .fontWeight(.semibold)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isCreatingRestaurant || restaurantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Location")
                            .font(.headline)
                        TextField("Location address (e.g., 123 Market St)", text: $restaurantAddress)
                            .textContentType(.fullStreetAddress)
                            .padding()
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                        Button {
                            Task {
                                await createOrUpdateLocation()
                            }
                        } label: {
                            Text("Save Location")
                                .fontWeight(.semibold)
                        }
                        .buttonStyle(.bordered)
                        .disabled(storedRestaurantId.isEmpty)
                        if storedRestaurantId.isEmpty {
                            Text("Create your restaurant first to add a location.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button("Sign Out") {
                        Task {
                            do {
                                try await signOut()
                                await MainActor.run {
                                    isSignedIn = false
                                    userEmail = ""
                                    status = "Signed out"
                                }
                            } catch {
                                await MainActor.run { status = "Sign out failed: \(error.localizedDescription)" }
                            }
                        }
                    }
                    .buttonStyle(.bordered)

                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 72))
                    Text("Restaurant Admin")
                        .font(.title2).bold()
                    Text("Sign in to sync menu, orders, and reservations across devices.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                    HStack {
                        Button("Sign Up") {
                            Task {
                                do {
                                    try await signUp(email: email, password: password)
                                    try await postAuthSetup(email: email)
                                    await refreshAuthState()
                                    await MainActor.run { status = "Sign up success" }
                                } catch {
                                    await MainActor.run { status = "Sign up failed: \(error.localizedDescription)" }
                                }
                            }
                        }
                        .buttonStyle(.bordered)

                        Button("Sign In") {
                            Task {
                                do {
                                    try await signIn(email: email, password: password)
                                    try await postAuthSetup(email: email)
                                    await refreshAuthState()
                                    await MainActor.run { status = "Sign in success" }
                                } catch {
                                    await MainActor.run { status = "Sign in failed: \(error.localizedDescription)" }
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                if !status.isEmpty {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .navigationTitle("Profile")
            .tint(Theme.blue)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .task {
                await refreshAuthState()
            }
            .alert("Restaurant", isPresented: $showRestaurantAlert, actions: { Button("OK", role: .cancel) {} }, message: { Text(restaurantAlertMessage) })
        }
    }

    private func postAuthSetup(email: String) async throws {
        do {
            _ = try await upsertProfileIfNeeded(email: email, displayName: nil)
        } catch {
            throw error
        }
    }

    @MainActor
    private func refreshAuthState() async {
        do {
            let maybeUser = try await currentUser()
            if let user = maybeUser as? (any AnyObject) { _ = user } // no-op to silence unused
            if let user = try await currentUser() { // treat as optional per helper
                isSignedIn = true
                userEmail = user.email ?? ""
            } else {
                isSignedIn = false
                userEmail = ""
            }
        } catch {
            isSignedIn = false
            userEmail = ""
            status = "Auth check failed: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func createRestaurantForProfile() async {
        guard !restaurantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isCreatingRestaurant = true
        restaurantAlertMessage = ""
        do {
            let result = try await createRestaurant(name: restaurantName, address: restaurantAddress.isEmpty ? nil : restaurantAddress)
            let id = result.id
            try await linkRestaurantToCurrentUser(restaurantId: id)
            storedRestaurantId = id.uuidString
            restaurantAlertMessage = "Restaurant created and linked to your profile."
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            showRestaurantAlert = true
            // Optionally clear inputs
            // Keep address so user can reuse it for location
            restaurantName = ""
        } catch {
            restaurantAlertMessage = "Failed to create restaurant: \(error.localizedDescription)"
            #if canImport(UIKit)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            #endif
            showRestaurantAlert = true
        }
        isCreatingRestaurant = false
    }

    @MainActor
    private func createOrUpdateLocation() async {
        guard let restaurantUUID = UUID(uuidString: storedRestaurantId) else { return }
        do {
            let location = try await createLocation(restaurantId: restaurantUUID, address: restaurantAddress.isEmpty ? nil : restaurantAddress)
            storedLocationId = location.id.uuidString
            restaurantAlertMessage = "Location saved for your restaurant."
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            showRestaurantAlert = true
        } catch {
            restaurantAlertMessage = "Failed to save location: \(error.localizedDescription)"
            #if canImport(UIKit)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            #endif
            showRestaurantAlert = true
        }
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

