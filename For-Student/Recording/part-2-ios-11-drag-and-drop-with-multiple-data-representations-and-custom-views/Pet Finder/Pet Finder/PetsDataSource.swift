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
import MobileCoreServices

class PetsDataSource: NSObject, UITableViewDataSource {

  var pets: [Pet]

  init(pets: [Pet]) {
    self.pets = pets
    super.init()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return pets.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "PetCell", for: indexPath)
    let pet = pets[indexPath.row]

    cell.imageView?.image = pet.image
    cell.imageView?.layer.masksToBounds = true
    cell.imageView?.layer.cornerRadius = 5
    cell.detailTextLabel?.text = pets[indexPath.row].type
    cell.textLabel?.text = pets[indexPath.row].name

    return cell
  }

  func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
    guard sourceIndex != destinationIndex else { return }

    let pet = pets[sourceIndex]
    pets.remove(at: sourceIndex)
    pets.insert(pet, at: destinationIndex)
  }

  func addPet(_ newPet: Pet, at index: Int) {
    pets.insert(newPet, at: index)
  }

  func dragItems(for indexPath: IndexPath) -> [UIDragItem] {

    let pet = pets[indexPath.row]

    let itemProvider = NSItemProvider(object: pet)

    let dragItem = UIDragItem(itemProvider: itemProvider)
    dragItem.localObject = pet
    return [dragItem]

  }

}
