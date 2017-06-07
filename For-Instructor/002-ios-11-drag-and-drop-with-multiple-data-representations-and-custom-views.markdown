## iOS 11 - Drag and Drop with Multiple Data Representations and Custom Views

## Implementing NSItemProviderWriting

Pet.swift

```
public class Pet : NSObject, NSCoding, NSItemProviderWriting {
```

```
public static var writableTypeIdentifiersForItemProvider: [String] = ["com.razeware.pet", kUTTypePlainText as String]
```

```
public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Swift.Void) -> Progress?
{
  if typeIdentifier == "com.razeware.pet" {
    let data = NSKeyedArchiver.archivedData(withRootObject: self)
    completionHandler(data, nil)
  } else if typeIdentifier == (kUTTypePlainText as String) {
    let nameData = name.data(using: .utf8)
    completionHandler(nameData, nil)
  }
  return nil
}
```  

## Implementing NSItemProviderReading

```
public class Pet : NSObject, NSCoding, NSItemProviderWriting, NSItemProviderReading {
```

```
public static var readableTypeIdentifiersForItemProvider: [String] = writableTypeIdentifiersForItemProvider
```

```
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
```

## Creating an item provider

PetsDataSource.swift, in drag items, replace let data = block with:

```
let itemProvider = NSItemProvider(object: pet)
```

PetsViewController.swift

Comment out optimizations, add this instead:

```

```

Change NSString to Pet:

```
itemProvider.loadObject(ofClass: Pet.self) { string, error in
```

```
      let itemProvider = item.dragItem.itemProvider
        itemProvider.loadObject(ofClass: Pet.self) { pet, error in
          if let pet = pet as? Pet {
```            

Demonstrate dragging pet to reminders and back, but also pet within table views - saving in different representations works.
      
### UIDragInteractionDelegate

ViewController.swift

```
extension ViewController: UIDragInteractionDelegate {

  func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
    let itemProvider = NSItemProvider(object: pet)
    let dragItem = UIDragItem(itemProvider: itemProvider)
    return [ dragItem ]
  }

}
```

viewDidLoad, before configureView()

```
view.addInteraction(UIDragInteraction(delegate: self))
```

Build and run, drag into other app.

### UIDropInteractionDelegate

```
extension ViewController: UIDropInteractionDelegate {

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
```
