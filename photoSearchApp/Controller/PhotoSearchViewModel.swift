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
    
    // It lets you manually send values to any subscribers
    // it sends search text entered by the user.
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
    
    // PassthroughSubject is a great fit for:
    // • Accepting imperative input from the UI (receiveSearchInput(_:) calls searchInput.send(...)).
    // • Feeding that input into a Combine pipeline (bindSearchInput()) to handle debouncing and querying.
    func receiveSearchInput(_ input: String) {
        searchInput.send(input)
    }
    
    func loadNextPageIfNeeded(afterDisplaying index: Int) {
        guard index >= results.count - Constants.paginationThreshold else { return }
        loadPage(resetResults: false)
    }
}

private extension PhotoSearchViewModel {
    // takes raw search text events from searchInput and turns them into
    // controlled, meaningful search requests.
    // The goal is to avoid spamming the network while keeping the UI responsive.
    func bindSearchInput() {
        searchInput
        // removes leading/trailing spaces and newlines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        // prevents empty strings from triggering a search. If the user deletes everything, no request is made.
            .filter { !$0.isEmpty }
        // waits for 450 ms of inactivity before passing along the latest value.
        // This means as the user types “mountains”, you’ll only act after they pause,
        // rather than firing on every character.
            .debounce(for: .milliseconds(450), scheduler: RunLoop.main)
            .removeDuplicates()
        // receives the debounced, deduplicated, non-empty, trimmed query:
            .sink { [weak self] query in
                guard query != self?.query else { return }
                self?.query = query
                // kicks off a new search from page 1 and clears prior results.
                self?.loadPage(resetResults: true)
            }
        // retains the subscription so it stays active for the lifetime of the view model.
            .store(in: &cancellables)
    }
    
    // fetching first batch of photos starts here
    // this function gets called in 2 situations
    // resetResults True or False
    
    func loadPage(resetResults: Bool) {
        guard resetResults || (!isLoading && canLoadMore) else { return }
        
        
        // if its the first time loadPage() gets called
        // this block is the reset state for a new search.
        // this means if resetResults is false we dont need to remove results array,
        // we go ahead and load next batch of data
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
        
        // Task = "run this async work in the background"
        Task {
            do {
                let photos = try await service.searchPhotos(keyword: requestedQuery, page: requestedPage)
                // replaces DispatchQueue.main.async
                // Back on main thread for UI-related state
                await MainActor.run {
                    guard identifier == self.requestIdentifier else { return }
                    self.isLoading = false
                    self.results.append(contentsOf: photos)
                    self.nextPage += 1
                    // “If the last page returned something, assume there might be more.
                    // If it returned nothing, stop paginating.”
                    self.canLoadMore = !photos.isEmpty
                    self.onResultsChanged?()
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    self.isLoading = false
                    self.onError?(error)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.onError?(.unknown(string: error.localizedDescription))
                }
            }
        }
    }
}

//Small example to visualize
//
//If the user types “c”, “ca”, “cat”, pauses:
//• The pipeline receives 3 quick values, but due to debounce, only “cat” makes it through after 450ms.
//• If they then add a space and delete it (returning to “cat”), removeDuplicates() prevents another search.
//• If they change “cat” to “cats”, the new value flows through and triggers a fresh search with resetResults: true.
