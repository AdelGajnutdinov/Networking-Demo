//
//  UserProfile.swift
//  Networking
//
//  Created by Adel Gainutdinov on 07.11.2021.
//

import Foundation

struct UserProfile {
    let id: Int?
    let name: String?
    let email: String?
    
    init(profileData: [String: Any]) {
        self.id = profileData["id"] as? Int
        self.name = profileData["name"] as? String
        self.email = profileData["email"] as? String
    }
}
