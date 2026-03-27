import Foundation

private let storageKey = "dayread-srs-items"

@Observable
final class SRSService {
    private(set) var items: [SRSItem] = []

    init() {
        load()
    }

    // MARK: - CRUD

    @discardableResult
    func addItem(type: SRSItemType, front: String, back: String, source: String) -> SRSItem {
        // Prevent duplicates by front text + source
        if let existing = items.first(where: { $0.front == front && $0.source == source }) {
            return existing
        }

        let item = SRSItem.initial(
            id: UUID().uuidString,
            type: type,
            front: front,
            back: back,
            source: source
        )
        items.append(item)
        save()
        return item
    }

    func removeItem(id: String) {
        items.removeAll { $0.id == id }
        save()
    }

    func reviewItem(id: String, quality: Int) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index] = SRSAlgorithm.review(items[index], quality: quality)
        save()
    }

    // MARK: - Queries

    func getDueItems() -> [SRSItem] {
        SRSAlgorithm.dueItems(from: items)
    }

    func getStats() -> ReviewStats {
        SRSAlgorithm.stats(from: items)
    }

    func getItemsBySource(sessionId: String) -> [SRSItem] {
        items.filter { $0.source == sessionId }
    }

    var dueCount: Int {
        getDueItems().count
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([SRSItem].self, from: data) else {
            return
        }
        items = decoded
    }
}
