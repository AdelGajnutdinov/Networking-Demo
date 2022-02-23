//
//  NetworkManager.swift
//  Networking
//
//  Created by Adel Gainutdinov on 30.10.2021.
//

import UIKit

class NetworkManager {
    static func getRequest(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }

    static func postRequest(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let userData = ["Course": "Networking", "Lesson": "GET and POST requests"]
        
        let httpBody = try? JSONSerialization.data(withJSONObject: userData, options: [])
        guard let httpBody = httpBody else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    static func downloadImage(from urlString: String, completion: @escaping (_ image: UIImage) -> ()) {
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }.resume()
    }
    
    static func fetchCourses(from urlString: String, completion: @escaping (_ courses: [Course])->()) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let courses = try JSONDecoder().decode([Course].self, from: data)
                completion(courses)
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    static func uploadImage(to urlString: String) {
        let image = UIImage(named: "image")!
        guard let imageProperties = ImageProperties(withImage: image, forKey: "image"),
              let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Authorization": "Client-ID 1bd22b9ce396a4c"]
        request.httpBody = imageProperties.data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response {
                print(response)
            }
            if let error = error {
                print(error.localizedDescription)
            }
        }.resume()
    }
}
