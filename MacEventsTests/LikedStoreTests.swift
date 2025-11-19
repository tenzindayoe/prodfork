import Testing
import Foundation
@testable import MacEvents

struct LikedStoreTests {

    @Test
    /// Verifies that liked ids are stored when toggled and removed when toggled again.
    func toggleAndContains() {
        let store = LikedStore()
        store.toggle("abc")
        #expect(store.contains("abc"))
        store.toggle("abc")
        #expect(!store.contains("abc"))
    }

    @Test
    /// Verifies that selected ids are removed in LikedStore's remove method. 
    func removeOnlyTargetsSpecifiedID() {
        let store = LikedStore()
        store.ids = ["abc", "def"]
        store.remove("abc")
        #expect(!store.contains("abc"))
        #expect(store.contains("def"))
    }
    
    

   
}
