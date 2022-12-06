//
//  File.swift
//  
//
//  Created by Rafaël Warnault on 04/12/2022.
//

import Fluent
import Vapor

extension Chat {
    struct Migration: AsyncMigration {
        var name: String { "CreateChat" }

        func prepare(on database: Database) async throws {
            try await database.schema("chats")
                .id()
                .field("name", .string, .required)
                .field("main", .bool, .required)
                .field("public", .bool, .required)
                .unique(on: "name")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("chats").delete()
        }
    }
    
    struct Seed: AsyncMigration {
        var name: String { "CreateDefaultChat" }

        func prepare(on database: Database) async throws {
            try await Chat(name: "General", isMain: true, isPublic: true).save(on: database)
        }

        func revert(on database: Database) async throws {
            //try await database.schema("chats").delete()
        }
    }
}
