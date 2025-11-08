//
//  ViewController.swift
//  LootLogger
//
//  Created by Jordan White on 10/21/25.
//

import UIKit

class ItemsViewController: UITableViewController {
    
    var itemStore: ItemStore!
    
    var expensiveItems: [Item] {
        return itemStore.allItems.filter { $0.valueInDollars > 50 }
    }
    
    var cheapItems: [Item] {
        return itemStore.allItems.filter { $0.valueInDollars <= 50 }
    }
    
    func item(for indexPath: IndexPath) -> Item {
        return indexPath.section == 0 ? expensiveItems[indexPath.row] : cheapItems[indexPath.row]
    }
    
    func globalIndex(for indexPath: IndexPath) -> Int? {
        let item = self.item(for: indexPath)
        return itemStore.allItems.firstIndex(of: item)
    }
    
    @IBAction func addNewItem(_ sender: UIButton) {
        let newItem = itemStore.createItem()
        
        let section = newItem.valueInDollars > 50 ? 0 : 1
        
        if section == 0 {
            if let row = expensiveItems.firstIndex(of: newItem) {
                let indexPath = IndexPath(row: row, section: section)
                tableView.insertRows(at: [indexPath], with: .automatic)
            } else {
                tableView.reloadData()
            }
        } else {
            if let row = cheapItems.firstIndex(of: newItem) {
                let indexPath = IndexPath(row: row, section: section)
                tableView.insertRows(at: [indexPath], with: .automatic)
            } else {
                tableView.reloadData()
            }
        }
    }
    
    @IBAction func toggleEditingMode(_ sender: UIButton) {
        if isEditing {
            sender.setTitle("Edit", for: .normal)
            setEditing(false, animated: true)
        } else {
            sender.setTitle("Done", for: .normal)
            setEditing(true, animated: true)
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? expensiveItems.count : cheapItems.count
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Items Over $50" : "Items $50 or Less"
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell",
                                                 for: indexPath) as! ItemCell

        // Get the correct item for this indexPath (using your section logic)
        let item = self.item(for: indexPath)

        // Configure the cell labels
        cell.nameLabel.text = item.name
        cell.serialNumberLabel.text = item.serialNumber
        cell.valueLabel.text = "$\(item.valueInDollars)"
        
        // Set value color: green if <50, red if >=50
        if item.valueInDollars < 50 {
            cell.valueLabel.textColor = UIColor.green
        } else {
            cell.valueLabel.textColor = UIColor.red
        }

        return cell
    }

    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = self.item(for: indexPath)
            
            itemStore.removeItem(itemToDelete)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        guard sourceIndexPath.section == destinationIndexPath.section else {
            tableView.reloadData()
            return
        }
        
        let itemsInSection = sourceIndexPath.section == 0 ? expensiveItems : cheapItems
        
        let sourceItem = itemsInSection[sourceIndexPath.row]
        
        let destinationItem: Item? = {
            if destinationIndexPath.row < itemsInSection.count {
                return itemsInSection[destinationIndexPath.row]
            } else {
                return nil
            }
        }()
        
        guard let sourceGlobalIndex = itemStore.allItems.firstIndex(of: sourceItem) else {
            tableView.reloadData()
            return
        }
        
        let destGlobalIndex: Int
        if let destItem = destinationItem, let destIndex = itemStore.allItems.firstIndex(of: destItem) {
            destGlobalIndex = destIndex
        } else {
            destGlobalIndex = itemStore.allItems.count - 1
        }
        
        itemStore.moveItem(from: sourceGlobalIndex, to: destGlobalIndex)
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65
    }
}
