import Fluent

extension StreamModel {
    struct Migration: AsyncMigration {
        func prepare(on database: Database) async throws {
            try await database.schema(StreamModel.schema)
                .id()
                .field("fileName", .string, .required)
                .create()
        }
        
        func revert(on database: FluentKit.Database) async throws {
            try await database.schema(StreamModel.schema).delete()
        }
    }
}
