//
//  File.swift
//  
//
//  Created by Rafaël Warnault on 03/12/2022.
//

import Fluent
import Vapor


protocol Administrable {
    func isAdmin() -> Bool
}



final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "password_hash")
    var passwordHash: String
    
    @Siblings(through: UserRole.self, from: \.$user, to: \.$role)
    public var roles: [Role]

    init() { }

    init(id: UUID? = nil, username: String, passwordHash: String) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
    }
}


extension User {
    struct Create: Content {
        var username: String
        var password: String
        var confirmPassword: String
    }
}


extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(8...))
    }
}


extension User: ModelAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}


extension User {
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}



extension User: SessionAuthenticatable {
    var sessionID: String {
        self.username
    }
}


extension User: Administrable {
    func isAdmin() -> Bool {
        return roles.contains { role in
            role.admin
        }
    }
}

