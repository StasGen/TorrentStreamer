//
//  ViewController.swift
//  grabber
//
//  Created by Станислав Калиберов on 04.02.2018.
//  Copyright © 2018 Станислав Калиберов. All rights reserved.
//

import UIKit
import Kanna

class TorrentSearchListViewController: UIViewController {
    struct Props {
        struct Torrent {
            let name: String
            let kByte: Double
            let ref: String?
            let downloads: Int
            let seeds: Int
            let peers: Int
            let createdDate: Date?
        }
        var torrents: [Torrent]
        var sortBy = RutrackerSearchParameters.SortBy.Количество_сидов
        var creationDuration = RutrackerSearchParameters.CreationDuration.последний_месяц
        var torrentType = RutrackerSearchParameters.TorrentType.Новинки_и_сериалы_в_стадии_показа
    }
    
    var props: Props = .init(torrents: [])
    var api: RutrackerApiManager = RutrackerApiManager()
    
    private let textCellIdentifier = "ShowCell"
    private let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yy"
        formatter.locale = .init(identifier: "ru_RU")
        return formatter
    }()
    
    @IBOutlet var metalShowTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet weak var sortTypeButton: UIButton!
    @IBOutlet weak var durationButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        metalShowTableView.delegate = self
        metalShowTableView.dataSource = self
        metalShowTableView.keyboardDismissMode = .interactive
        searchBar.delegate = self
        
        sortTypeButton.setTitle("Sort By", for: .normal)
        durationButton.setTitle("Creation Duration", for: .normal)
        categoryButton.setTitle("Torrent Type", for: .normal)
        
        api.login(login: "", password: "") {
            print("login finished")
            self.fetchContent(searchText: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowConcertInfoSegue", let controller = segue.destination as? TorrentDetailViewController {
            controller.id = sender as? String
        }
    }
    
    @IBAction func searchFilterButtonDidTap(_ sender: UIButton) {
        let updateSearch: (()->()) -> () = { setter in
            setter()
            self.searchBarSearchButtonClicked(self.searchBar)
        }
        
        if sender == sortTypeButton {
            presentAlert(
                title: "Sort By",
                items: RutrackerSearchParameters.SortBy.allCases.map { item in
                    (String(describing: item), props.sortBy == item, { _ in updateSearch({ self.props.sortBy = item }) })
                }
            )
        } else if sender == durationButton {
            presentAlert(
                title: "Creation Duration",
                items: RutrackerSearchParameters.CreationDuration.allCases.map { item in
                    (String(describing: item), props.creationDuration == item, { _ in updateSearch({ self.props.creationDuration = item }) })
                }
            )
        } else if sender == categoryButton {
            presentAlert(
                title: "Torrent Type",
                items: RutrackerSearchParameters.TorrentType.allCases.map { item in
                    (String(describing: item), props.torrentType == item, { _ in updateSearch({ self.props.torrentType = item }) })
                }
            )
        }
    }
    
    func presentAlert(title: String, items: [(String, Bool, (UIAlertAction)->())]) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        items.map {
            UIAlertAction(title: $0.0, style: $0.1 ? .destructive : .default, handler: $0.2)
        }.forEach(alert.addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func fetchContent(searchText: String?) {
        props.torrents.removeAll()
        api.getTrackers(
            searchText: searchText ?? "",
            parameters: RutrackerSearchParameters(
                sortBy: props.sortBy,
                sort: .по_возрастанию,
                creationDuration: props.creationDuration,
                author: "",
                torrentType: [props.torrentType]
            )
        ) { [weak self] result in
            do {
                self?.props.torrents = try result.get().map {
                    Props.Torrent(name: $0.name, kByte: $0.kByte, ref: $0.id, downloads: $0.liveParams.downloads, seeds: $0.liveParams.seeds, peers: $0.liveParams.peers, createdDate: $0.createdDate) }
                
                DispatchQueue.main.async {
                    self?.metalShowTableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
    }
}

extension TorrentSearchListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return props.torrents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        guard let torrent = props.torrents[safe: indexPath.row] else { return UITableViewCell() }
        let createdDate = torrent.createdDate.map(dateFormatter.string) ?? "No date"
        cell.textLabel?.text = "\(torrent.name) \n\((torrent.kByte/1000000).description)GB D:\(torrent.downloads) S:\(torrent.seeds) P:\(torrent.peers) \(createdDate)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let id = props.torrents[indexPath.row].ref {
            performSegue(withIdentifier: "ShowConcertInfoSegue", sender: id)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TorrentSearchListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchContent(searchText: searchBar.text)
    }
}
