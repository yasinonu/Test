import Fluent

struct CreateMatch: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("matches")
            .id()
            .field("home", .uuid, .required)
            .field("away", .uuid, .required)
            .field("date", .date, .required)
            .field("actions", .array(of: .dictionary))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("matches").delete()
    }
}
