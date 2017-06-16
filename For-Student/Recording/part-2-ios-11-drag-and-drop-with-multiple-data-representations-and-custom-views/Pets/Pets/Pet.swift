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

public class Pet : NSObject, NSCoding, NSItemProviderWriting, NSItemProviderReading {

  public var name: String
  public var type: String
  public var image: UIImage?

  public static var writableTypeIdentifiersForItemProvider: [String] = ["com.razeware.pet", kUTTypePlainText as String]
  public static var readableTypeIdentifiersForItemProvider: [String] = writableTypeIdentifiersForItemProvider

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

  public static func canHandle(_ session: UIDropSession) -> Bool {
    return session.canLoadObjects(ofClass: NSString.self)
  }

  public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
    if typeIdentifier == "com.razeware.pet" {
      let data = NSKeyedArchiver.archivedData(withRootObject: self)
      completionHandler(data, nil)
    } else if typeIdentifier == (kUTTypePlainText as String) {
      let nameData = name.data(using: .utf8)
      completionHandler(nameData, nil)
    }
    return nil
  }

  required public convenience init(itemProviderData data: Data, typeIdentifier: String) throws {
    if typeIdentifier == "com.razeware.pet" {
      guard let pet = NSKeyedUnarchiver.unarchiveObject(with: data) as? Pet else {
        throw EncodingError.invalidData
      }
      self.init(name: pet.name, type: pet.type, image: pet.image)
    } else if typeIdentifier == (kUTTypePlainText as String) {
      guard let name = String(data: data, encoding: .utf8) else {
        throw EncodingError.invalidData
      }
      self.init(name: name as String, type: "Unknown", image: nil)
    } else {
      throw EncodingError.invalidData
    }
  }






}




