//
//  File.swift
//  
//
//  Created by Rafaël Warnault on 03/12/2022.
//

import Fluent
import Vapor

extension Role {
    struct Migration: AsyncMigration {
        var name: String { "CreateRole" }

        func prepare(on database: Database) async throws {
            try await database.schema("roles")
                .id()
                .field("name", .string, .required)
                .field("admin", .bool, .required)
                .unique(on: "name")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("roles").delete()
        }
    }
}

