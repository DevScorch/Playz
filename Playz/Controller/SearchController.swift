//
//  SearchController.swift
//  Playz
//
//  Created by Johan on 20-05-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SearchController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    enum SearchType: Int {
        case users, categories, hashtags
    }
    
    // DEVSCORCH: Variables
    var selectedScopeButtonIndex: Int {
        return searchController.searchBar.selectedScopeButtonIndex
    }
    
    var searchType: SearchType {
        return SearchType.init(rawValue: selectedScopeButtonIndex) ?? .users
    }
    
    var searchBar: UISearchBar {
          return searchController.searchBar
    }
    
    var users: [UserModel] = []
    var categories: [CategoryModel] = []
    var hashtags: [HashtagModel] = []
    let searchController = UISearchController(searchResultsController: nil)
    var filteredList = [UserModel]()

    // DEVSCORCH: IBOutlets
    
    @IBOutlet var userTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTableView.delegate = self
        userTableView.dataSource = self
        configureSearchBar()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        doSearch()
    }
    
    // DEVSCORCH: Functions

    func configureSearchBar() {
        
        let greyColor = UIColor(red: 251/255, green: 255/255, blue: 245/255, alpha: 1)
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = greyColor
        
        searchBar.delegate = self
        searchBar.showsScopeBar = true
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.showsCancelButton = false
        searchBar.sizeToFit()
        searchBar.scopeButtonTitles = ["People", "Categories", "Hashtags"]
        searchBar.tintColor = greyColor
        
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.tabBarItem.badgeColor = .yellow
        let color = UIColor(red: 29/255, green: 29/255, blue: 29/255, alpha: 1.1)
        searchBar.barTintColor = color
        searchBar.backgroundColor = color
        searchController.tabBarItem.badgeColor = color
        userTableView.tableHeaderView = searchController.searchBar
    }
    
    func doSearch() {
        users.removeAll()
        categories.removeAll()
        hashtags.removeAll()

        if let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty {
            let spinnerVC = UIViewController.displaySpinner(onView: self.view)
            switch searchType {
            case .users:
                UserObserver().queryUsers(withText: searchText, completion: { [weak self] (user) in
                    guard let newSelf = self else {
                        UIViewController.removeSpinner(spinner: spinnerVC)
                        return
                    }
                    if let user = user {
                        newSelf.isFollowing(userId: user.id!, completed: { (value) in
                            if !newSelf.users.alreadyExists(model: user) {
                                if user.id != Auth.auth().currentUser?.uid {
                                    user.isFollowing = value
                                    newSelf.users.append(user)
                                    newSelf.userTableView.reloadData()
                                }
                            }
                        })
                    }
                    UIViewController.removeSpinner(spinner: spinnerVC)
                })
            case .categories:
                CategoryObserver().fetchCategories(with: searchText, completion: { [weak self]  (category)  in
                    if let category = category {
                        if let newSelf = self, !newSelf.categories.alreadyExists(model: category) {
                            newSelf.categories.append(category)
                            newSelf.userTableView.reloadData()
                        }
                    }
                    UIViewController.removeSpinner(spinner: spinnerVC)
                })
            case .hashtags:
                HashTagObserver().fetchHashTags(withTag: searchText) { [weak self] (hashtag) in
                    if let hashtag = hashtag {
                        if let newSelf = self, !newSelf.hashtags.alreadyExists(model: hashtag) {
                            newSelf.hashtags.append(hashtag)
                            newSelf.userTableView.reloadData()
                        }
                    }
                    UIViewController.removeSpinner(spinner: spinnerVC)
                }
            }
        }
        userTableView.reloadData()
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        FollowObserver().isFollowing(userId: userId, completed: completed)
    }
    
    // DEVSCORCH: PrepareForSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileViewControllerSegue" {
            guard let profileVC = segue.destination as? ProfileViewController else {
                return
            }
            guard let userId = sender as? String else {
                return
            }
            
            profileVC.user = users.filter({ $0.id == userId }).first
//            profileVC.delegate = self as? UserProfileHeaderEditProfileDelegate
        } else if segue.identifier == "visitHashTagSegue", let hashtagVC = segue.destination as? OnClickHashtagViewController, let tag = sender as? String {
            hashtagVC.tag = tag
        } else if segue.identifier == "visitCategorySegue", let categoryVC = segue.destination as? OnClickCategoryViewController, let category = sender as? String {
            categoryVC.category = category
            
        }
    }
    
    // DEVSCORCH: TableView Setup
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchType {
        case .users:
            return users.count
        case .categories:
            return categories.count
        case .hashtags:
            return hashtags.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        switch searchType {
        case .users:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverUserCell", for: indexPath) as? VisitUserCell else {
                break
            }
            
            let user = users[index]
            cell.user = user
            cell.delegate = self as VisitUserTableViewCellDelegate
            return cell
        case .categories:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell, !categories.isEmpty else {
                break
            }
            
            let category = categories[index]
            cell.category = category
            cell.delegate = self
            return cell
        case .hashtags:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HashTagCell", for: indexPath) as? HashTagCell else {
                break
            }
            
            let hashtag = hashtags[index]
            cell.hashtag = hashtag
            cell.delegate = self
            return cell
        }
        
        return UITableViewCell()
    }
    
    //DEVSCORCH: UISearchbar setup
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        doSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doSearch()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        print(scope)
        userTableView.reloadData()
    }
    
    // DEVSCORCH: ErrorHandling:
    
    func showAlertMessage(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
    
    }
}

// DEVSCORCH: Extensions

extension SearchController: VisitUserTableViewCellDelegate, VisitCategoryTableViewDelegate, VisitHashTagTableViewDelegate {
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "profileViewControllerSegue", sender: userId)
    }
    
    func goToCategoryViewController(category: String) {
        performSegue(withIdentifier: "visitCategorySegue", sender: category)
    }
    
    func goToHashTagViewController(hashtag: String) {
        performSegue(withIdentifier: "visitHashTagSegue", sender: hashtag)
    }
}

extension SearchController: UserProfileHeaderDelegate {
    func updateFollowButton(forUser user: UserModel) {
        for u in self.users where u.id == user.id {
            u.isFollowing = user.isFollowing
            self.userTableView.reloadData()
        }
    }
}
