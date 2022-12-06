//
//  File.swift
//  
//
//  Created by Rafaël Warnault on 04/12/2022.
//

import Fluent
import Vapor


final class UserRole: Model {
    static let schema = "user_roles"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "role_id")
    var role: Role

    init() { }

    init(id: UUID? = nil, user: User, role: Role) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.$role.id = try role.requireID()
    }
}
