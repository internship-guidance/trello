//
//  ViewController.swift
//  trello
//
//  Created by e.vanags on 13/04/2019.
//  Copyright © 2019 esesmuedgars. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!

    private weak var safariController: SFSafariViewController?

    private var boards = Boards() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
    }

    private func bind() {
        APIService.shared.didAuthorize = { [weak self] in
            self?.shouldAuthorize = false

            DispatchQueue.main.async {
                self?.safariController?.dismiss(animated: true, completion: {
                    self?.safariController = nil
                })
            }
        }
    }

    private var shouldAuthorize = true

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard shouldAuthorize else {
            APIService.shared.fetchBoards { [weak self] result in
                switch result {
                case .success(let boards):
                    DispatchQueue.main.async {
                        self?.boards = boards
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }

            return
        }

        APIService.shared.authorize { [weak self] (url) in
            guard let url = url else { return }

            DispatchQueue.main.async {
                let controller = SFSafariViewController(url: url)
                self?.safariController = controller

                self?.present(controller, animated: true)
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boards.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withType: BoardCell.self, for: indexPath) {
            let title = boards[indexPath.row].name
            cell.configure(with: title)

            return cell
        }

        return UITableViewCell()
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO:
        // Make request to get board data by board identifier
        // Present `BoardViewController`

        print(boards[indexPath.row].id)
    }
}
