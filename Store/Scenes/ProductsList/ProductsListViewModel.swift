//
// ProductsListViewModel.swift
// Store
// Created by Baramidze on 25.11.23.

// ProductsListViewModel.swift
// Store
// Created by Baramidze on 25.11.23.

import Foundation

protocol ProductsListViewModelDelegate: AnyObject {
    func handleErrorAlert(_ error: Error)
    func productsFetched()
    func productsAmountChanged()
}

final class ProductsListViewModel {
    
    weak var delegate: ProductsListViewModelDelegate?
    
    var products: [ProductModel]?
    
    var totalPrice: Double? {
        products?.reduce(0) { $0 + $1.price * Double(($1.selectedAmount ?? 0)) }
    }
    
    func viewDidLoad() {
        fetchProducts()
    }
    
    private func fetchProducts() {
        NetworkManager.shared.fetchProducts { [weak self] response in
            switch response {
            case .success(let products):
                self?.products = products
                self?.delegate?.productsFetched()
            case .failure(let error):
                self?.products = []
                self?.delegate?.handleErrorAlert(error)
            }
        }
    }
    
    func addProduct(at index: Int) {
        guard var product = products?[index] else {
            print("❌ Error: No product at that index")
            return
        }
        
        if product.stock <= 0 {
            print("❌ Error: Product is out of stock")
        } else {
            product.selectedAmount = (products?[index].selectedAmount ?? 0) + 1
            products?[index].selectedAmount = product.selectedAmount
            delegate?.productsAmountChanged()
        }
    }
    
    func removeProduct(at index: Int) {
        guard var product = products?[index] else {
            print("❌ Error: No product at that index")
            return
        }
        
        if product.selectedAmount ?? 0 > 0 {
            product.selectedAmount = (products?[index].selectedAmount ?? 0) - 1
            products?[index].selectedAmount = product.selectedAmount
            delegate?.productsAmountChanged()
        } else {
            print("❌ Error: Quantity is already 0")
        }
    }
}
