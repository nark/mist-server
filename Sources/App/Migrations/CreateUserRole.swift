//
//  File.swift
//  
//
//  Created by Rafaël Warnault on 04/12/2022.
//

import Fluent

extension UserRole {
    struct Migration: AsyncMigration {
        var name: String { "CreateUserRole" }

        func prepare(on database: Database) async throws {
            try await database.schema("user_roles")
                .id()
                .field("user_id", .uuid, .required, .references("users", "id"))
                .field("role_id", .uuid, .required, .references("roles", "id"))
                .unique(on: "user_id", "role_id")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("user_roles").delete()
        }
    }
}
