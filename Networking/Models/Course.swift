//
//  Course.swift
//  Networking
//
//  Created by Adel Gainutdinov on 27.10.2021.
//

import Foundation

struct Course: Codable {
    var id: Int
    var name: String
    var link: String
    var imageUrl: String
    var numberOfLessions: Int
    var numberOfTests: Int
    
    init?(json: [String: Any]) {
        
        guard let id = json["id"] as? Int ?? Int(json["id"] as? String ?? ""),
              let name = json["name"] as? String,
              let link = json["link"] as? String,
              let imageUrl = json["imageUrl"] as? String,
              let numberOfLessons = json["number_of_lessons"] as? Int ?? Int(json["number_of_lessons"] as? String ?? ""),
              let numberOfTests = json["number_of_tests"] as? Int ?? Int(json["number_of_tests"] as? String ?? "")
        else { return nil }
        
        self.id = id
        self.name = name
        self.link = link
        self.imageUrl = imageUrl
        self.numberOfLessions = numberOfLessons
        self.numberOfTests = numberOfTests
    }
    
    private enum CodingKeys : String, CodingKey {
        case id, name, link, imageUrl, numberOfLessions = "number_of_lessons", numberOfTests = "number_of_tests"
    }
}
