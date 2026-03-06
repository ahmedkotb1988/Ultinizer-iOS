import Foundation

final class CategoryRepository: CategoryRepositoryProtocol, @unchecked Sendable {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func getCategories() async throws -> [TaskCategory] {
        let dtos: [TaskCategoryDTO] = try await apiClient.request(endpoint: .getCategories)
        return dtos.map(CategoryMapper.map)
    }

    func createCategory(name: String, color: String?, icon: String?) async throws -> TaskCategory {
        let request = CreateCategoryRequestDTO(name: name, color: color, icon: icon)
        let dto: TaskCategoryDTO = try await apiClient.request(endpoint: .createCategory, body: request)
        return CategoryMapper.map(dto)
    }

    func updateCategory(id: String, name: String?, color: String?, icon: String?) async throws -> TaskCategory {
        let request = UpdateCategoryRequestDTO(name: name, color: color, icon: icon)
        let dto: TaskCategoryDTO = try await apiClient.request(endpoint: .category(id: id), body: request)
        return CategoryMapper.map(dto)
    }

    func deleteCategory(id: String) async throws {
        try await apiClient.request(endpoint: .category(id: id))
    }
}
