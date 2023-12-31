//
//  PlacesViewController.swift
//  GoogleSDK
//
//  Created by Dmitriy Mkrtumyan on 30.11.23.
//

import UIKit
import GooglePlaces

class PlacesViewController: UIViewController {
    
    //MARK: - Data
    private let alertsFactory: AlertsFactoryInterface = AlertsFactory()
    private var likelyPlaces: [GMSPlace] = [] {
        didSet {
            self.placesTable.reloadData()
        }
    }
    private let cellReuseID = "placesCell"
    private let placesTable = UITableView()
    var dataPassingDelegate: PassLikelyPlaceDelegate?
    var presenter: PlacesViewOutput!
    
    private func setupPlacesTableView() {
        placesTable.delegate = self
        placesTable.dataSource = self
        
        placesTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseID)
        placesTable.estimatedRowHeight = 20
        placesTable.rowHeight = 50
        placesTable.allowsSelection = true
        placesTable.allowsMultipleSelection = false
        placesTable.translatesAutoresizingMaskIntoConstraints = false
        placesTable.isScrollEnabled = false
        
        view.addSubview(placesTable)
        
        NSLayoutConstraint.activate([
            placesTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            placesTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            placesTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placesTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.fetchPlaces()
        title = "Most Liked Places"
        view.backgroundColor = .white
        placesTable.backgroundColor = .white
        setupPlacesTableView()
    }
}

extension PlacesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likelyPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        let item = likelyPlaces[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.backgroundColor = .white
        
        return cell
    }
}

extension PlacesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = likelyPlaces[indexPath.row]
        
        dataPassingDelegate?.passingSelectedPlace(item)
        navigationController?.popViewController(animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        placesTable.frame.size.height / 5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == tableView.numberOfSections - 1) {
            return 1
        }
        return 0
    }
}

extension PlacesViewController: PlacesViewInput {
    func passTableView(datasource: [GMSPlace]) {
        
        likelyPlaces = datasource
        
        if likelyPlaces.isEmpty {
            let alertVC = alertsFactory.showAlert(with: .placesFailure)
            present(alertVC, animated: true)
        }
    }
}
