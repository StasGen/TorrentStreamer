//
//  ViewController.swift
//  grabber
//
//  Created by Станислав Калиберов on 04.02.2018.
//  Copyright © 2018 Станислав Калиберов. All rights reserved.
//

import UIKit
import Kanna
import Alamofire

class ViewController: UIViewController {
    struct Props {
        struct Torrent {
            let name: String
            let kByte: Double
            let ref: String?
        }
        var torrents: [Torrent]
        var sortBy = RutrackerSearchParameters.SortBy.Количество_сидов
        var creationDuration = RutrackerSearchParameters.CreationDuration.последний_месяц
        var torrentType = RutrackerSearchParameters.TorrentType.Новинки_и_сериалы_в_стадии_показа
    }
    
    var props: Props = .init(torrents: [])
    var api: RutrackerApiManager = RutrackerApiManager()
    
    private let textCellIdentifier = "ShowCell"
    
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
                self?.props.torrents = try result.get().map { Props.Torrent(name: $0.name, kByte: $0.kByte, ref: $0.id) }
                
                DispatchQueue.main.async {
                    self?.metalShowTableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return props.torrents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = props.torrents[row].name + "\n" + (props.torrents[row].kByte/1000000).description + " GB"
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let id = props.torrents[indexPath.row].ref {
            performSegue(withIdentifier: "ShowConcertInfoSegue", sender: id)
        }
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchContent(searchText: searchBar.text)
    }
}