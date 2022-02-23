//
//  CoursesTableViewController.swift
//  Networking
//
//  Created by Adel Gainutdinov on 27.10.2021.
//

import UIKit

class CoursesTableViewController: UITableViewController {

    private let urlString = "https://swiftbook.ru/wp-content/uploads/api/api_courses"
    private let postRequestUrl = "https://jsonplaceholder.typicode.com/posts"
    private var courses = [Course]()
    private var selectedCourse: Course?
    
    func fetchCourses() {
        NetworkManager.fetchCourses(from: urlString) { [weak self] courses in
            self?.courses = courses
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func fetchCoursesWithAlamofire() {
        AlamofireNetworkRequest.fetchCourseArray(urlString: urlString) { [weak self] courses in
            self?.courses = courses
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func postAlamofire() {
        AlamofireNetworkRequest.postRequest(urlString: postRequestUrl) { [weak self] courses in
            self?.courses = courses
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: - TableView data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
        configureCell(cell: cell, for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCourse = self.courses[indexPath.row]
        performSegue(withIdentifier: "webSegue", sender: self)
    }
    
    private func configureCell(cell: TableViewCell, for indexPath: IndexPath) {
        let course = self.courses[indexPath.row]
        cell.courseNameLabel.text = course.name
        cell.numberOfLessionsLabel.text = "Number of lessions \(course.numberOfLessions)"
        cell.numberOfTestsLabel.text = "Number of tests \(course.numberOfTests)"
        
        NetworkManager.downloadImage(from: course.imageUrl) { [weak cell] image in
            DispatchQueue.main.async {
                cell?.courseImage.image = image
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webSegue", let course = self.selectedCourse {
            let webViewController = segue.destination as! WebViewController
            webViewController.courseTitle = course.name
            webViewController.courseURL = course.link
        }
    }

}
