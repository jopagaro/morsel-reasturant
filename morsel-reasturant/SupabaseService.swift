import Foundation
#if canImport(Supabase)
import Supabase
#endif

enum SupabaseAvailabilityError: Error {
    case moduleUnavailable
}

#if canImport(Supabase)
enum SupabaseProvider {
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://knwnegyfzwzxqxbdgnqh.supabase.co")!,
        supabaseKey: "sb_publishable_ROj-HB7eCx7j46UrCPvKyA_P-R_4WTx"
    )
}

struct Profile: Codable {
    var id: UUID?
    var auth_user_id: UUID
    var email: String
    var display_name: String?
    var role: String?
}

struct Restaurant: Codable {
    var id: UUID?
    var owner_profile_id: UUID
    var name: String
    var description: String?
    var phone: String?
    var email: String?
    var website: String?
    var active: Bool?
}

struct Location: Codable {
    var id: UUID?
    var restaurant_id: UUID
    var label: String
    var address_line1: String?
    var address_line2: String?
    var city: String?
    var region: String?
    var postal_code: String?
    var country: String?
    var instructions: String?
    var is_primary: Bool?
}

struct Item: Codable {
    var id: UUID?
    var restaurant_id: UUID
    var title: String
    var description: String?
    var base_price: Double
    var active: Bool
}

struct Listing: Codable {
    var id: UUID?
    var item_id: UUID
    var location_id: UUID
    var title_override: String?
    var price: Double
    var quantity_available: Int
    var available_now: Bool
    var start_at: String?
    var end_at: String?
    var lead_time_minutes: Int
    var sell_until_end: Bool
    var pickup_instructions: String?
    var active: Bool
}

struct Tag: Codable {
    var id: UUID
    var name: String
}

struct ItemTag: Codable {
    var item_id: UUID
    var tag_id: UUID
}

@discardableResult
func upsertProfileIfNeeded(email: String, displayName: String?) async throws -> Profile {
    let client = SupabaseProvider.client
    // In this SDK version, `auth.session` returns a session (or throws) and `session.user` is non-optional.
    // So we get the session first and then read its user directly.
    let session = try await client.auth.session
    let user = session.user

    let profile = Profile(
        id: nil,
        auth_user_id: user.id,
        email: email,
        display_name: displayName,
        role: nil
    )

    let inserted: Profile = try await client
        .from("profiles")
        .upsert(profile, onConflict: "auth_user_id")
        .select()
        .single()
        .execute()
        .value

    return inserted
}

func createItem(restaurantId: UUID, title: String, description: String?, basePrice: Double) async throws -> Item {
    let client = SupabaseProvider.client
    let item = Item(id: nil, restaurant_id: restaurantId, title: title, description: description, base_price: basePrice, active: true)

    let created: Item = try await client
        .from("items")
        .insert(item)
        .select()
        .single()
        .execute()
        .value

    return created
}

func createListing(
    itemId: UUID,
    locationId: UUID,
    titleOverride: String?,
    price: Double,
    quantity: Int,
    availableNow: Bool,
    startAt: Date?,
    endAt: Date?,
    leadTimeMinutes: Int,
    sellUntilEnd: Bool,
    pickupInstructions: String?
) async throws -> Listing {
    let client = SupabaseProvider.client
    let iso = ISO8601DateFormatter()
    iso.formatOptions = [.withInternetDateTime]

    let listing = Listing(
        id: nil,
        item_id: itemId,
        location_id: locationId,
        title_override: titleOverride,
        price: price,
        quantity_available: quantity,
        available_now: availableNow,
        start_at: availableNow ? nil : (startAt.map { iso.string(from: $0) }),
        end_at: availableNow ? nil : (endAt.map { iso.string(from: $0) }),
        lead_time_minutes: leadTimeMinutes,
        sell_until_end: sellUntilEnd,
        pickup_instructions: pickupInstructions,
        active: true
    )

    let created: Listing = try await client
        .from("listings")
        .insert(listing)
        .select()
        .single()
        .execute()
        .value

    return created
}

func attachTags(to itemId: UUID, names: Set<String>) async throws {
    let client = SupabaseProvider.client

    let allTags: [Tag] = try await client
        .from("tags")
        .select()
        .execute()
        .value

    let selectedIds = allTags
        .filter { names.contains($0.name) }
        .map(\.id)

    guard !selectedIds.isEmpty else { return }

    let itemTags = selectedIds.map { ItemTag(item_id: itemId, tag_id: $0) }

    try await client
        .from("item_tags")
        .insert(itemTags)
        .execute()
}

// MARK: - Auth Helpers (SDK-compatible)

func signUp(email: String, password: String) async throws {
    // Older SDKs support this signature
    _ = try await SupabaseProvider.client.auth.signUp(email: email, password: password)
}

func signIn(email: String, password: String) async throws {
    // Use the older API name present in your SDK
    _ = try await SupabaseProvider.client.auth.signIn(email: email, password: password)
}

func signOut() async throws {
    try await SupabaseProvider.client.auth.signOut()
}

func currentUser() async throws -> User? {
    // Convert SDK behavior (throw when no session) into an optional for the UI
    do {
        let session = try await SupabaseProvider.client.auth.session
        return session.user
    } catch {
        return nil
    }
}

#else
// Fallback stubs when Supabase is unavailable

struct Profile: Codable { var id: UUID?; var auth_user_id: UUID; var email: String; var display_name: String?; var role: String? }
struct Restaurant: Codable { var id: UUID?; var owner_profile_id: UUID; var name: String; var description: String?; var phone: String?; var email: String?; var website: String?; var active: Bool? }
struct Location: Codable { var id: UUID?; var restaurant_id: UUID; var label: String; var address_line1: String?; var address_line2: String?; var city: String?; var region: String?; var postal_code: String?; var country: String?; var instructions: String?; var is_primary: Bool? }
struct Item: Codable { var id: UUID?; var restaurant_id: UUID; var title: String; var description: String?; var base_price: Double; var active: Bool }
struct Listing: Codable { var id: UUID?; var item_id: UUID; var location_id: UUID; var title_override: String?; var price: Double; var quantity_available: Int; var available_now: Bool; var start_at: String?; var end_at: String?; var lead_time_minutes: Int; var sell_until_end: Bool; var pickup_instructions: String?; var active: Bool }
struct Tag: Codable { var id: UUID; var name: String }
struct ItemTag: Codable { var item_id: UUID; var tag_id: UUID }

@discardableResult func upsertProfileIfNeeded(email: String, displayName: String?) async throws -> Profile { throw SupabaseAvailabilityError.moduleUnavailable }
func createItem(restaurantId: UUID, title: String, description: String?, basePrice: Double) async throws -> Item { throw SupabaseAvailabilityError.moduleUnavailable }
func createListing(itemId: UUID, locationId: UUID, titleOverride: String?, price: Double, quantity: Int, availableNow: Bool, startAt: Date?, endAt: Date?, leadTimeMinutes: Int, sellUntilEnd: Bool, pickupInstructions: String?) async throws -> Listing { throw SupabaseAvailabilityError.moduleUnavailable }
func attachTags(to itemId: UUID, names: Set<String>) async throws { throw SupabaseAvailabilityError.moduleUnavailable }

func signUp(email: String, password: String) async throws { throw SupabaseAvailabilityError.moduleUnavailable }
func signIn(email: String, password: String) async throws { throw SupabaseAvailabilityError.moduleUnavailable }
func signOut() async throws { throw SupabaseAvailabilityError.moduleUnavailable }
func currentUser() async throws -> Any? { throw SupabaseAvailabilityError.moduleUnavailable }

#endif // canImport(Supabase)

