//
//  ConversationViewController.swift
//  Chat
//
//  Created by VB on 02.03.2021.
//

import UIKit

class ConversationViewController: UITableViewController {

    private let messages: Array<UserProfile.Message>?
    private let cellIdentifierIncoming = "MessageCellIncoming"
    private let cellIdentifierOutgoing = "MessageCellOutgoing"

    init(title: String, messages: [UserProfile.Message]) {
        self.messages = messages

        super.init(style: .plain)

        self.title = title
        tableView.register(UINib(nibName: cellIdentifierIncoming, bundle: nil), forCellReuseIdentifier: cellIdentifierIncoming)
        tableView.register(UINib(nibName: cellIdentifierOutgoing, bundle: nil), forCellReuseIdentifier: cellIdentifierOutgoing)
        tableView.dataSource = self
        tableView.delegate = self

        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages?.count ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = messages?[indexPath.row] else { return UITableViewCell() }
        var cellIdentifier = cellIdentifierOutgoing
        if message.kind == .incoming {
            cellIdentifier = cellIdentifierIncoming
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MessageCell else { return UITableViewCell() }

        cell.configure(with: .init(text: message.text))
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
