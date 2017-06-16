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

class ViewController: UIViewController {

  var pet = Pet(name: "Snow White", type: "Black Cat", image: UIImage(named: "pet7"))

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var typeTextField: UITextField!

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addInteraction(UIDragInteraction(delegate: self))
    view.addInteraction(UIDropInteraction(delegate: self))
    configureView()
  }

  func configureView() {
    imageView.image = pet.image
    nameTextField.text = pet.name
    typeTextField.text = pet.type
  }

  @IBAction func nameTextFieldChanged(_ sender: Any) {
    if let name = nameTextField.text {
      pet.name = name
    }
  }

  @IBAction func typeTextFieldChanged(_ sender: Any) {
    if let type = typeTextField.text {
      pet.type = type
    }
  }

}

extension ViewController: UIDragInteractionDelegate {

  func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
    let itemProvider = NSItemProvider(object: pet)
    let dragItem = UIDragItem(itemProvider: itemProvider)
    return [ dragItem ]
  }

}

extension ViewController : UIDropInteractionDelegate {

  func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
    return session.canLoadObjects(ofClass: Pet.self)
  }

  func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
    return UIDropProposal(operation: .copy)
  }

  func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
    session.loadObjects(ofClass: Pet.self) { petItems in
      if let pets = petItems as? [Pet],
        let pet = pets.first {
        self.pet = pet
        self.configureView()
      }
    }
  }

}





















