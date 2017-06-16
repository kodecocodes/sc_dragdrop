/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Pets

class PetsViewController: UIViewController {
  
  @IBOutlet weak var petsTableView: UITableView!
  @IBOutlet weak var adoptedTableView: UITableView!

  let petsDataSource = PetsDataSource(pets:
    [Pet(name: "Rusty", type: "Golden Retriever", image: UIImage(named: "pet0")),
     Pet(name: "Max", type: "Mixed Terrier", image: UIImage(named: "pet1")),
     Pet(name: "Lucifer", type: "Freaked Out", image: UIImage(named: "pet2")),
     Pet(name: "Tiger", type: "Sensitive Whiskers", image: UIImage(named: "pet3")),
     Pet(name: "Widget", type: "Mouse Catcher", image: UIImage(named: "pet4")),
     Pet(name: "Wiggles", type: "Border Collie", image: UIImage(named: "pet5")),
     Pet(name: "Clover", type: "Mixed Breed", image: UIImage(named: "pet6"))])
  let adoptedDataSource = PetsDataSource(pets: [])

  override func viewDidLoad() {
    super.viewDidLoad()

    for tableView in [petsTableView, adoptedTableView] {
      if let tableView = tableView {
        tableView.dataSource = dataSourceForTableView(tableView)
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.reloadData()
      }
    }

  }

  func dataSourceForTableView(_ tableView: UITableView) -> PetsDataSource {
    if (tableView == petsTableView) {
      return petsDataSource
    } else {
      return adoptedDataSource
    }
  }

}

extension PetsViewController: UITableViewDragDelegate {

  func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    let dataSource = dataSourceForTableView(tableView)
    return dataSource.dragItems(for: indexPath)
  }

}

extension PetsViewController: UITableViewDropDelegate {

  func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
    return Pet.canHandle(session)
  }

  func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
    if tableView.hasActiveDrag {
      if session.items.count > 1 {
        return UITableViewDropProposal(operation: .cancel)
      } else {
        return UITableViewDropProposal(dropOperation: .move, intent: .insertAtDestinationIndexPath)
      }
    } else {
      return UITableViewDropProposal(dropOperation: .copy, intent: .insertAtDestinationIndexPath)
    }
  }

  func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {

    let dataSource = dataSourceForTableView(tableView)

    let destinationIndexPath: IndexPath
    if let indexPath = coordinator.destinationIndexPath {
      destinationIndexPath = indexPath
    } else {
      let section = tableView.numberOfSections - 1
      let row = tableView.numberOfRows(inSection: section)
      destinationIndexPath = IndexPath(row: row, section: section)
    }

    for item in coordinator.items {

      if (false) { }

//      // Item originated from same app, and same table view
//      if let sourceIndexPath = item.sourceIndexPath {
//        print("Same app - Same table view")
//        dataSource.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
//        DispatchQueue.main.async {
//          tableView.beginUpdates()
//          tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
//          tableView.insertRows(at: [destinationIndexPath], with: .automatic)
//          tableView.endUpdates()
//        }
//      }
//
//      // Item originated from same app, but different table view
//      else if let pet = item.dragItem.localObject as? Pet {
//        print("Same app - Different table view")
//        dataSource.addPet(pet, at: destinationIndexPath.row)
//        DispatchQueue.main.async {
//          tableView.insertRows(at: [destinationIndexPath], with: .automatic)
//        }
//      }

      // Item originated from different app
      else {
        print("Different app")

        let context = coordinator.drop(item.dragItem, toPlaceholderInsertedAt: destinationIndexPath, withReuseIdentifier: "PetCell", rowHeight: 110, cellUpdateHandler: { cell in
          cell.textLabel?.text = "Loading..."
        })

        let itemProvider = item.dragItem.itemProvider
        itemProvider.loadObject(ofClass: Pet.self) { pet, error in
          if let pet = pet as? Pet {
            DispatchQueue.main.async {
              context.commitInsertion(dataSourceUpdates: { indexPath in
                dataSource.addPet(pet, at: destinationIndexPath.row)
              })
            }
          }
        }
      }

    }

  }

}








