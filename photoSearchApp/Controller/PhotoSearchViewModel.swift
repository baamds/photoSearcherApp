//
//  PhotoSearchViewModel.swift
//  photoSearchApp
//

import Combine
import Foundation

final class PhotoSearchViewModel {

    private enum Constants {
        static let initialQuery = "people"
        static let paginationThreshold = 12
    }

    private let service: PhotoSearching
    private let searchInput = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var query = Constants.initialQuery
    private var nextPage = 1
    private var isLoading = false
    private var canLoadMore = true
    private var requestIdentifier = UUID()

    private(set) var results: [JasonResult] = []
    var onResultsChanged: (() -> Void)?
    var onError: ((NetworkError) -> Void)?

    init(service: PhotoSearching = NetworkService.shared) {
        self.service = service
        bindSearchInput()
    }

    func loadInitialResults() {
        loadPage(resetResults: true)
    }

    func receiveSearchInput(_ input: String) {
        searchInput.send(input)
    }

    func loadNextPageIfNeeded(afterDisplaying index: Int) {
        guard index >= results.count - Constants.paginationThreshold else { return }
        loadPage(resetResults: false)
    }
}

private extension PhotoSearchViewModel {
    func bindSearchInput() {
        searchInput
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .debounce(for: .milliseconds(450), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard query != self?.query else { return }
                self?.query = query
                self?.loadPage(resetResults: true)
            }
            .store(in: &cancellables)
    }

    func loadPage(resetResults: Bool) {
        guard resetResults || (!isLoading && canLoadMore) else { return }

        if resetResults {
            requestIdentifier = UUID()
            nextPage = 1
            canLoadMore = true
            results.removeAll()
            onResultsChanged?()
        }

        isLoading = true
        let requestedPage = nextPage
        let requestedQuery = query
        let identifier = requestIdentifier

        service.searchPhotos(keyword: requestedQuery, page: requestedPage) { [weak self] result in
            DispatchQueue.main.async {
                guard let self, identifier == self.requestIdentifier else { return }
                self.isLoading = false

                switch result {
                case .success(let photos):
                    self.results.append(contentsOf: photos)
                    self.nextPage += 1
                    self.canLoadMore = !photos.isEmpty
                    self.onResultsChanged?()
                case .failure(let error):
                    self.onError?(error)
                }
            }
        }
    }
}
