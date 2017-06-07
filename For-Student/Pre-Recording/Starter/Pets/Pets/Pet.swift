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

import MobileCoreServices
import UIKit

private enum Key {
  static let name = "name"
  static let type = "type"
  static let image = "image"
}

enum EncodingError: Error {
  case invalidData
}

public class Pet : NSObject, NSCoding {

  public var name: String
  public var type: String
  public var image: UIImage?

  public init(name: String, type: String, image: UIImage?) {
    self.name = name
    self.type = type
    self.image = image
    super.init()
  }

  required public convenience init?(coder: NSCoder) {
    guard let name = coder.decodeObject(forKey: Key.name) as? String,
      let type = coder.decodeObject(forKey: Key.type) as? String,
      let image = (coder.decodeObject(forKey: Key.image) as? Data).flatMap(UIImage.init)
    else {
      return nil
    }
    self.init(name: name, type: type, image: image)
  }

  public func encode(with coder: NSCoder) {
    coder.encode(name, forKey: Key.name)
    coder.encode(type, forKey: Key.type)
    if let image = image {
      coder.encode(UIImagePNGRepresentation(image), forKey: Key.image)
    }
  }

}




