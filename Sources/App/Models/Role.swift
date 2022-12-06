//
//  File.swift
//  
//
//  Created by Rafaël Warnault on 03/12/2022.
//

import Fluent
import Vapor

final class Role: Model, Content {
    static let schema = "roles"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "admin")
    var admin: Bool

    init() { }

    init(id: UUID? = nil, name: String, admin: Bool) {
        self.id = id
        self.name = name
        self.admin = admin
    }
}
