//
//  SearchOrderPositionsTableViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 19.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {
    private static let reuseIdentifier = "SearchOrderPositionsTableViewControllerCell"
    var appCoordinator: AppCoordinator?
    
    // MARK: - Private Properties
    @IBOutlet private var searchHeaderView: SearchHeaderView!
    private var numberOfSearches = 0
    private var results = [SearchResult]()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.SearchOrderPositionsTableViewController.Title
        tableView.tableHeaderView = searchHeaderView
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTableViewController.reuseIdentifier, for: indexPath)
        guard let cell = defaultCell as? SearchResultTableViewCell else { return defaultCell }
        
        if indexPath.row >= results.endIndex {
            return UITableViewCell()
        }
        let result = results[indexPath.row]
        cell.searchResult = result
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= results.endIndex {
            return
        }
        let result = results[indexPath.row]
        dismiss(animated: true, completion: nil)
        if let secret = result.secret  {
            appCoordinator?.redeem(secret: secret, force: false, ignoreUnpaid: false)
        }
    }
}

extension SearchResultsTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        guard searchText.count > 2 else {
            searchHeaderView.status = .notEnoughCharacters
            results = []
            tableView.reloadData()
            return
        }
        
        let nextSearchNumber = numberOfSearches + 1
        
        searchHeaderView.status = .loading
        deferredSearch(query: searchText) { (results, error) in
            // Protect against old slow searches overwriting new fast searches
            guard nextSearchNumber > self.numberOfSearches else { return }
            
            // Update Results
            self.presentErrorAlert(ifError: error)
            self.results = results ?? []
            self.tableView.reloadData()
            self.searchHeaderView.status = .searchCompleted(results: self.results.count)
        }
    }
    
    func deferredSearch(query: String, completionHandler: @MainActor @escaping ([SearchResult]?, Error?) -> Void) {
        let locale = Locale.current
        Task {
            do {
                let results = try await appCoordinator?.getConfigStore().ticketValidator?.search(query: query, locale)
                completionHandler(results, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
}

public enum SearchResultStatus: Hashable, Equatable, Codable {
    case paid
    case cancelled
    case pending
}

public struct SearchResult: Hashable, Equatable, Codable {
    public var secret: String? = nil
    public var ticket: String? = nil
    public var variation: String? = nil
    public var attendeeName: String? = nil
    public var seat: String? = nil
    public var orderCode: String? = nil
    public var positionId: Identifier? = nil
    public var addonText: String? = nil
    public var status: SearchResultStatus? = nil
    public var isRedeemed = false
    public var isRequireAttention = false
}
