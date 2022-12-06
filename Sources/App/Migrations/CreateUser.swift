//
//  File.swift
//  
//
//  Created by Rafaël Warnault on 03/12/2022.
//

import Fluent
import Vapor

extension User {
    struct Migration: AsyncMigration {
        var name: String { "CreateUser" }

        func prepare(on database: Database) async throws {
            try await database.schema("users")
                .id()
                .field("username", .string, .required)
                .field("password_hash", .string, .required)
                .field("comment", .string)
                .unique(on: "username")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("users").delete()
        }
    }
    
    
    struct Seed: AsyncMigration {
        var name: String { "CreateDefaultAdmin" }

        func prepare(on database: Database) async throws {
            let user = try User(username: "admin", passwordHash: Bcrypt.hash("changeme"))
            try await user.save(on: database)
            
            let adminRole = Role(name: "admin", admin: true)
            try await adminRole.save(on: database)
            
            try await user.$roles.attach([adminRole], on: database)
        }

        func revert(on database: Database) async throws {
            //try await database.schema("chats").delete()
        }
    }
}
