//
//  File.swift
//  
//
//  Created by Rafaël Warnault on 04/12/2022.
//

import Fluent
import Vapor

final class Chat: Model, Content {
    static let schema = "chats"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "main")
    var isMain: Bool
    
    @Field(key: "public")
    var isPublic: Bool

    init() { }

    init(id: UUID? = nil, name: String, isMain: Bool, isPublic: Bool) {
        self.id = id
        self.name = name
        self.isMain = isMain
        self.isPublic = isPublic
    }
}

