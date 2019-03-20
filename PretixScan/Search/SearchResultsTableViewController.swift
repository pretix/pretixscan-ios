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
    var configStoreProvider: ConfigStoreProvider?

    // MARK: - Private Properties
    @IBOutlet private var searchFooterView: SearchFooterView!
    private var numberOfSearches = 0
    private var results = [OrderPosition]()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.SearchOrderPositionsTableViewController.Title
        tableView.tableFooterView = searchFooterView
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

        let result = results[indexPath.row]
        cell.orderPosition = result
        return cell
    }
}

extension SearchResultsTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        guard searchText.count > 2 else {
            searchFooterView.status = .notEnoughCharacters
            return
        }

        let nextSearchNumber = numberOfSearches + 1

        searchFooterView.status = .loading
        configStoreProvider?.getConfigStore().apiClient?.getSearchResults(query: searchText) { (orders, error) in
            DispatchQueue.main.async {
                // Protect against old slow searches overwriting new fast searches
                guard nextSearchNumber > self.numberOfSearches else { return }

                // Update Results
                self.presentErrorAlert(ifError: error)
                self.results = orders ?? [OrderPosition]()
                self.tableView.reloadData()
                self.searchFooterView.status = .searchCompleted(results: self.results.count)
            }
        }
    }
}
