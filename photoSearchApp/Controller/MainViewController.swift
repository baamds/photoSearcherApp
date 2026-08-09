//
//  MainViewController.swift
//  photoSearchApp
//

import UIKit

final class MainViewController: UIViewController {

    private let viewModel = PhotoSearchViewModel()

    private var contentView: MainView {
        guard let contentView = view as? MainView else {
            fatalError("MainViewController must be backed by MainView.")
        }
        return contentView
    }

    override func loadView() {
        view = MainView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureSearch()
        bindViewModel()
        // first batch of data loads here
        viewModel.loadInitialResults()
    }
}

private extension MainViewController {
    func configureCollectionView() {
        contentView.collectionView.dataSource = self
        contentView.collectionView.delegate = self
    }

    func configureSearch() {
        contentView.searchBar.delegate = self
    }

    func bindViewModel() {
        viewModel.onResultsChanged = { [weak self] in
            self?.contentView.collectionView.reloadData()
        }

        viewModel.onError = { error in
            print(error)
        }
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.results.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCell.identifier,
            for: indexPath
        ) as? PhotoCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: viewModel.results[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.loadNextPageIfNeeded(afterDisplaying: indexPath.item)
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.receiveSearchInput(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
