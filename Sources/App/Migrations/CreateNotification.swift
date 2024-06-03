import Fluent

struct CreateNotification: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("notifications")
            .id()
            .field("team", .uuid, .required)
            .field("content", .string, .required)
            .field("type", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("notifications").delete()
    }
}

