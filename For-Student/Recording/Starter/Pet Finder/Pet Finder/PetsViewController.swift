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


