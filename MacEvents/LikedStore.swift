// LikedStore.swift
import SwiftUI

/// Minimal store that keeps track of liked event identifiers and persists them in `UserDefaults`.
final class LikedStore: ObservableObject {
    @Published var ids: Set<String> {
        didSet {
            guard oldValue != ids else { return }
            defaults.set(Array(ids), forKey: key)
        }
    }

    private let key = "liked_event_ids_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if ProcessInfo.processInfo.environment["UITestResetLikedStore"] == "1" {
            defaults.removeObject(forKey: key)
        }

        if let stored = defaults.array(forKey: key) as? [String] {
            self.ids = Set(stored)
        } else {
            self.ids = []
        }

        if let seed = ProcessInfo.processInfo.environment["UITestLikedIDs"], !seed.isEmpty {
            let ids = seed
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            if !ids.isEmpty {
                self.ids = Set(ids)
                defaults.set(Array(self.ids), forKey: key)
            }
        }
    }

    func contains(_ id: String) -> Bool { ids.contains(id) }

    func toggle(_ id: String) {
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
    }

    func remove(_ id: String) {
        ids.remove(id)
    }

    /// Removes all liked IDs from memory and UserDefaults. Useful for UI-tests.
    func clear() {
        ids.removeAll()
        defaults.removeObject(forKey: key)
    }
}
