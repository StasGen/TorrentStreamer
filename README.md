# TorrentStreamer

A native iOS application for streaming torrents directly on your device. This app allows users to search, browse, and stream torrent content using integrated torrent streaming capabilities.

## Features

- **Torrent Search**: Search for torrents through integrated APIs
- **Direct Streaming**: Stream torrent content without waiting for complete downloads
- **RuTracker Integration**: Built-in support for RuTracker.org torrent tracker
- **VLC Player Integration**: Uses MobileVLCKit for robust media playback
- **Core Data Storage**: Persistent storage for torrent metadata and user preferences

## Requirements

- iOS 8.0+
- Xcode 10.0+
- Swift 5.0+
- CocoaPods

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/StasGen/TorrentStreamer.git
   cd TorrentStreamer
   ```

2. Install dependencies using CocoaPods:
   ```bash
   pod install
   ```

3. Open the workspace file:
   ```bash
   open grabber.xcworkspace
   ```

4. Build and run the project in Xcode.

## Dependencies

The project uses the following key dependencies managed through CocoaPods:

- **PopcornTorrent**: Core torrent streaming functionality
- **MobileVLCKit**: Video playback capabilities
- **Kanna**: HTML parsing for web scraping

For a complete list of dependencies, see the [`Podfile`](Podfile).

## Project Structure

```
grabber/
├── AppDelegate.swift          # Main application delegate
├── Models/                    # Data models
│   ├── TorrentPreviewModel.swift
│   └── TorrentDetailModel.swift
├── Networking/                # Network layer
│   ├── Core/                  # Core networking components
│   └── RutrackerApi/          # RuTracker API integration
├── Presentation/              # View controllers and UI
├── Helpers/                   # Utility classes and extensions
├── Extensions/                # Swift extensions
└── Resources/                 # Assets and resources
```

## Usage

1. Launch the app on your iOS device or simulator
2. Use the search functionality to find torrents
3. Select a torrent from the search results
4. The app will begin streaming the content using the integrated torrent client
5. Enjoy streaming content directly without waiting for full downloads

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is available under the MIT License. See the LICENSE file for more details.

## Disclaimer

This application is for educational purposes only. Users are responsible for ensuring they comply with all applicable laws and regulations regarding torrent usage in their jurisdiction. The developers do not endorse or encourage piracy or copyright infringement.

## Author

Created by Станислав Калиберов (Stanislav Kaliberov)

---

**Note**: This application requires proper configuration and may need additional setup for full functionality. Please ensure you have the necessary permissions and legal rights to use torrent streaming services in your region.