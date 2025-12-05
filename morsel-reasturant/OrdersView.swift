import SwiftUI

private enum OrdersTheme {
    static let blue = Color(hue: 0.57, saturation: 0.38, brightness: 0.68)
}

struct OrdersView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Incoming") {
                    ForEach(0..<3) { idx in
                        NavigationLink(destination: Text("Order #\(1000 + idx) details (placeholder)")) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Order #\(1000 + idx)")
                                        .font(.headline)
                                    Text("Pickup today • 5:3\(idx) PM")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }

                Section("Completed") {
                    ForEach(0..<2) { idx in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Order #\(900 + idx)")
                                    .font(.headline)
                                Text("Yesterday • Completed")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Orders")
            .tint(OrdersTheme.blue)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .headerProminence(.increased)
        }
    }
}

#Preview {
    OrdersView()
}
