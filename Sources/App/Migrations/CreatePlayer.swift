import Fluent

struct CreatePlayer: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("players")
            .id()
            .field("name", .string, .required)
            .field("age", .int, .required)
            .field("country", .string, .required)
            .field("image", .string)
            .field("position", .string, .required)
            .field("score", .int, .required)
            .field("injury", .date)
            .field("team", .uuid)
            .field("price", .int)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("players").delete()
    }
}
