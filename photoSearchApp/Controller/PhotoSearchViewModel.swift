//
//  PhotoSearchViewModel.swift
//  photoSearchApp
//

import Combine
import Foundation

final class PhotoSearchViewModel {

    // Using static let is the common Swift pattern for
    // grouping constants in a namespace-like type.
    private enum Constants {
        static let initialQuery: String = "people"
        static let paginationThreshold: Int = 12
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
    
    // optional callback closures
    // creating a wire to viewcontroller
    // when bind, viewcontroller listens to changes,
    // when new data is available (eg after a search completes), it will invoke onResultsChanged?()
    var onResultsChanged: (() -> Void)?
    var onError: ((NetworkError) -> Void)?

    // custom initializer for PhotoSearchViewModel
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
    
    // fetching first batch of photos starts here
    // this function gets called in 2 situations
    // resetResults True or False
    
    func loadPage(resetResults: Bool) {
        guard resetResults || (!isLoading && canLoadMore) else { return }
        
        
        // if its the first time loadPage() gets called
        // this block is the reset state for a new search.
        if resetResults {
            requestIdentifier = UUID()
            // Resets pagination back to the first page. Since you’re starting
            // a new search, you want to fetch from page 1 again.
            nextPage = 1
            // Re-enables pagination.
            canLoadMore = true
            results.removeAll()
            //  The () invokes the closure, which takes no parameters and returns Void. (reloading the uicollectionview)
            onResultsChanged?()
        }

        isLoading = true
        let requestedPage = nextPage
        let requestedQuery = query
        let identifier = requestIdentifier

        service.searchPhotos(keyword: requestedQuery, page: requestedPage) { [weak self] result in
            // All UI updates must happen on the main thread.
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
