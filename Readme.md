# PhotoSearcherApp

A simple iOS image-search app built with Swift. Search for a topic and browse a scrolling feed of photographs powered by the [Unsplash API](https://unsplash.com/developers).

## Preview

<img src="assets/app-screenshot.png" alt="PhotoSearcherApp showing a search bar and photo results" width="320" />

## Features

- Search for photos by keyword
- Loads image results from Unsplash
- Shows photographer information, likes, and available location details
- Pagination support for loading more image results

## Requirements

- macOS with Xcode installed
- iOS Simulator or a connected iPhone
- An Unsplash developer account and access key

## Getting started

1. Clone or download this project.
2. Open the `.xcodeproj` file in Xcode.
3. Add your Unsplash access key wherever the project stores its API configuration.
4. Choose an iPhone simulator at the top of Xcode.
5. Press **Run** (`⌘R`).

## Unsplash API key

Create an application in the [Unsplash Developers dashboard](https://unsplash.com/developers) and use its **Access Key** for API requests.

Keep the key out of GitHub. A good approach is to store it in a local configuration file that is listed in `.gitignore`, rather than writing it directly in source code.

## Credits

Images and photographer data are provided by [Unsplash](https://unsplash.com/).

