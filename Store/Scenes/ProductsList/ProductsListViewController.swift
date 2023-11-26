//
//  ProductsListViewController.swift
//  Store
//
//  Created by Baramidze on 25.11.23.
//

import UIKit

final class ProductsListViewController: UIViewController {
    
    private let productsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .purple
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.style = .large
        indicator.color = .white
        return indicator
    }()
    
    private let totalPriceLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Total: $0"
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    private let productsViewModel = ProductsListViewModel()
    
    private var errorHandler: UIAlertController = {
        let alert = UIAlertController(title: "Warning!⚠️", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
        return alert
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupProductsViewModel()
        productsViewModel.viewDidLoad()
        activityIndicator.startAnimating()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .orange
        setupTableView()
        setupIndicator()
        setupTotalPriceLbl()
    }
    
    private func setupTableView() {
        view.addSubview(productsTableView)
        
        productsTableView.dataSource = self
        productsTableView.delegate = self
        
        NSLayoutConstraint.activate([
            productsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            productsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            productsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        productsTableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
    }
    
    private func setupIndicator() {
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTotalPriceLbl() {
        view.addSubview(totalPriceLbl)
        
        NSLayoutConstraint.activate([
            totalPriceLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalPriceLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalPriceLbl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Setup Delegates
    
    private func setupProductsViewModel() {
        productsViewModel.delegate = self
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ProductsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsViewModel.products?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let currentProduct = productsViewModel.products?[indexPath.row],
              let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell
        else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        cell.reload(with: currentProduct)
        return cell
    }
}

// MARK: - ProductsListViewModelDelegate

extension ProductsListViewController: ProductsListViewModelDelegate {
    
    func handleErrorAlert(_ error: Error) {
        DispatchQueue.main.async {
            self.errorHandler.message = error.localizedDescription
            self.present(self.errorHandler, animated: true, completion: nil)
        }
    }
    
    func productsAmountChanged() {
        totalPriceLbl.text = "Total price: \(productsViewModel.totalPrice ?? 0)"
    }
    
    func productsFetched() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.productsTableView.reloadData()
        }
    }
}

// MARK: - ProductCellDelegate

extension ProductsListViewController: ProductCellDelegate {
    
    func addProduct(for cell: ProductCell) {
        if let indexPath = productsTableView.indexPath(for: cell) {
            productsViewModel.addProduct(at: indexPath.row)
            productsTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func removeProduct(for cell: ProductCell) {
        if let indexPath = productsTableView.indexPath(for: cell) {
            productsViewModel.removeProduct(at: indexPath.row)
            productsTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
