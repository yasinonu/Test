import Fluent

struct CreateTeam: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("teams")
            .id()
            .field("title", .string, .required)
            .field("abbreviation", .string, .required)
            .field("image", .string)
            .field("formation", .int, .required)
            .field("budget", .int, .required)
            .field("players", .array(of: .uuid))
            .field("owned", .bool, .required)
            .field("order", .array(of: .uuid))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("teams").delete()
    }
}
