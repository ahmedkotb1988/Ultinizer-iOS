import Foundation

protocol CategoryRepositoryProtocol: Sendable {
    func getCategories() async throws -> [TaskCategory]
    func createCategory(name: String, color: String?, icon: String?) async throws -> TaskCategory
    func updateCategory(id: String, name: String?, color: String?, icon: String?) async throws -> TaskCategory
    func deleteCategory(id: String) async throws
}
