//
//  SearchOrderPositionsTableViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 19.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SearchOrderPositionsTableViewController: UITableViewController, Configurable {
    var configStore: ConfigStore?

    private static let reuseIdentifier = "SearchOrderPositionsTableViewControllerCell"

    private let searchController = UISearchController(searchResultsController: nil)

    private var numberOfSearches = 0
    private var results = [OrderPosition]()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.SearchOrderPositionsTableViewController.Title

        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.placeholder = Localization.SearchOrderPositionsTableViewController.Placeholder
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        present(searchController, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.searchBar.becomeFirstResponder()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchOrderPositionsTableViewController.reuseIdentifier, for: indexPath)
        let result = results[indexPath.row]
        cell.textLabel?.text = result.attendeeName
        return cell
    }
}

extension SearchOrderPositionsTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        guard searchText.count > 2 else { return }

        let nextSearchNumber = numberOfSearches + 1

        configStore?.apiClient?.getSearchResults(query: searchText) { (orders, error) in
            DispatchQueue.main.async {
                // Protect against old slow searches overwriting new fast searches
                guard nextSearchNumber > self.numberOfSearches else { return }

                // Update Results
                self.presentErrorAlert(ifError: error)
                self.results = orders ?? [OrderPosition]()
                self.tableView.reloadData()
            }
        }
    }
}
