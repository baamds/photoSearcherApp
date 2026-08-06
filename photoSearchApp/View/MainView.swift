//
//  MainView.swift
//  photoSearchApp
//

import UIKit

final class MainView: UIView {

    let searchBar = UISearchBar()
    let collectionView: UICollectionView

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let searchBarHeight: CGFloat = 50
        searchBar.frame = CGRect(
            x: 10,
            y: safeAreaInsets.top,
            width: bounds.width - 20,
            height: searchBarHeight
        )
        collectionView.frame = CGRect(
            x: 0,
            y: searchBar.frame.maxY + 5,
            width: bounds.width,
            height: bounds.height - searchBar.frame.maxY - 5
        )

        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let itemSize = CGSize(width: bounds.width - 20, height: bounds.width / 2)
        if layout.itemSize != itemSize {
            layout.itemSize = itemSize
            layout.invalidateLayout()
        }
    }
}

private extension MainView {
    func configureSubviews() {
        backgroundColor = .systemBackground
        searchBar.placeholder = "Search photos"
        collectionView.register(
            UINib(nibName: PhotoCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: PhotoCell.identifier
        )

        addSubview(searchBar)
        addSubview(collectionView)
    }
}
