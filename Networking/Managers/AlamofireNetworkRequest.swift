//
//  AlamofireNetworkRequest.swift
//  Networking
//
//  Created by Adel Gainutdinov on 03.11.2021.
//

import Foundation
import Alamofire

class AlamofireNetworkRequest {
    
    static var onProgress: ((Double) -> ())?
    static var completed: ((String) -> ())?
    
    static func fetchCourseArray(urlString: String, completion: @escaping ([Course]) -> ()) {
        guard let url = URL(string: urlString) else { return }
        AF.request(url).validate().responseJSON { response in
            guard let data = response.data else { return }
            do {
                let courses = try JSONDecoder().decode([Course].self, from: data)
                completion(courses)
            } catch {
                print(error.localizedDescription)
            }
//            switch response.result {
//            case .success(let value):
//                guard let arrayOfItems = value as? Array<[String: Any]> else { return }
//                var courses = [Course]()
//                for item in arrayOfItems {
//                    let course = Course(id: item["id"] as? Int,
//                                        name: item["name"] as? String,
//                                        link: item["link"] as? String,
//                                        imageUrl: item["imageUrl"] as? String,
//                                        numberOfLessions: item["imageUrl"] as? Int,
//                                        numberOfTests: item["imageUrl"] as? Int)
//                    courses.append(course)
//                }
//                print(arrayOfItems)
//            case .failure(let error):
//                print(error)
//            }
        }
    }
    
    static func fetchData(urlString: String, completion: @escaping (UIImage) -> ()) {
        AF.request(urlString).validate().responseData { response in
            switch response.result {
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    completion(image)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func fetchDataWithProgress(urlString: String, completion: @escaping (UIImage) -> ()) {
        AF.request(urlString).validate().downloadProgress { progress in
            self.onProgress?(progress.fractionCompleted)
            self.completed?(progress.localizedDescription)
        }.response { response in
            guard let data = response.data,
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    static func postRequest(urlString: String, completion: @escaping ([Course]) -> ()) {
        
        let userData: [String: Any] = [
            "name": "Network Requests with Alamofire",
            "link": "https://swiftbook.ru/contents/our-first-applications/",
            "imageUrl": "https://swiftbook.ru/wp-content/uploads/sites/2/2018/08/notifications-course-with-background.png",
            "number_of_lessons": 18,
            "number_of_tests": 10
        ]
        AF.request(urlString, method: .post, parameters: userData).validate().responseJSON { responseJSON in
            switch responseJSON.result {
            case .success(let value):
                guard let jsonObject = value as? [String: Any] else { return }
                guard let course = Course(json: jsonObject) else { return }
                completion([course])
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func uploadImage(to urlString: String) {
        let image = UIImage(named: "image")!
        let data = image.pngData()!
        let httpHeaders = ["Authorization": "Client-ID 1bd22b9ce396a4c"]
        
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: "image")
            },
            to: urlString,
            headers: HTTPHeaders(httpHeaders)
        ).uploadProgress(closure: { progress in
            print(progress.localizedDescription!)
        }
        ).responseJSON { responseJSON in
            switch responseJSON.result {
            case .success(let value):
                print(value)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
