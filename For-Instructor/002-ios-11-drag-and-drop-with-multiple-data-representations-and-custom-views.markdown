## iOS 11 Drag and Drop with Multiple Data Representations and Custom Views

Hey what's up everybody, this is Ray. In this screencast, I'm going to show you how to export your app's data in many different representations, in order to drag and drop it into a large variety of apps.

I'll also show you how you can implement drag and drop into custom views in your app. If you're interested in learning how to implement drag and drop into table or collection views, check out my other screencast on that.

We'll start by making our app able to export its data into multiple data representations. To do this, your data model needs to implement two protocols: NSItemProviderWriting, and NSItemProviderReading.

It's pretty simple - so let's dive right in.

## Implementing NSItemProviderWriting

I have a simple iPad app here called Pet Finder that lists a batch of pets up for adoption. I've already implemented drag and drop into this app so that I can export each pet as a string. For example, I can drag a pet into my Reminders, and it adds an entry for the pet's name.

That's great, but I have this other app called Pet Editor that lets me edit pets. It woudl be great if I could drag a pet from Pet Finder to Pet Editor, and have everything be transferred across - not just the name.

In short, I want to be able to export the pet in two ways - as the high-fidelity Pet data model, for apps I control, and as a low-fidelity String, for apps that don't know about my proprietary Pet data model.

To do this, the first step to do this is to make my model class conform to NSItemProviderWriting.

```
public class Pet : NSObject, NSCoding, NSItemProviderWriting {
```

We then need to add a property writableTypeIdentifiersForItemProvider, which is an array of string UTI types that this model can export. The first UTI type we'll support will be a custom type for my data model - we'll call it "com.razeware.pet". The second UTI type we'll support will be a plaintext string, so we'll use the built-in kUTTypePlainText constant for that.

```
public static var writableTypeIdentifiersForItemProvider: [String] = ["com.razeware.pet", kUTTypePlainText as String]
```

Next, we need to implement one method: loadData(withTypeIdentifier:forItemProviderCompletionHandler:). iOS calls this method when you drop your data into another app, and the app requests the data in a particular format, by sending the appropriate type identifier.

So first, we'll check the type identifier the app requests, and if it's "com.razeware.pet", we will just convert the entire data model into a Data object. I've already made the class conform to NSCoding, so it's easy to convert to Data with NSKeyedArchiver. I'll then call the completion handler passing in the data.

On the other hand, if the app requests our data as plaintext, we'll convert the name of the pet to UTF8 formatted Data, and send that to the completion handler.

This method can optionally return a Progress class if your data takes a while to convert, but we don't need that so we'll return nil here.

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

That handles exporting our data in two formats, but we need to be able to handle importing our data in these two formats as well. To do that, we'll implement another protocol: NSItemProviderReading.

```
public class Pet : NSObject, NSCoding, NSItemProviderWriting, NSItemProviderReading {
```

As before, we need to add a property to return an array of UTIs that this model can read. We'll set it equal to the writableTypeIdentifiers.

```
public static var readableTypeIdentifiersForItemProvider: [String] = writableTypeIdentifiersForItemProvider
```

I also need to add one method to conform to this protocol: a convenience initializer that takes a buffer of data, and a type identifier that specifies what type of data it is.

Here, we check to see if it's "com.razeware.pet", and if so unarchive the object with NSCoding.

On the other hand, if it's a string, we simply initialize a new pet with that name, setting the type and image to placeholders.

If it's neither of these, we'll throw an error.

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

There's one last step. Back in PetsDataSource.swift, in drag items, we'll delete this block of code, and simiply create a new NSItemProvider, passing in my pet class. This works because the pet class now implements NSItemProviderWriting.

```
let itemProvider = NSItemProvider(object: pet)
```

Now let's try this out. Back in PetsViewController.swift, I'm going to comment out these optimizations that support shortcuts to drag and drop data within the same app, and add an if (false) instead. This way, when we drag and drop within the same app it still goes through the same import/export process that we'd do if we were transferring the data to another app. This is good for temporary testing purposes - after we verify it works we could switch it back.

```
if (false) { }
```

Next, we'll change the type of data we want to load from an NSString to our Pet class.

```
      let itemProvider = item.dragItem.itemProvider
        itemProvider.loadObject(ofClass: Pet.self) { pet, error in
          if let pet = pet as? Pet {
```            

That's it! Now I'll build and run. I can now export my data in two ways: if I drag over to reminders, it's exported as a string, and if I drag within the same app, it's exported as the full data model. 

## Interlude

The cool thing about what I showed you is I could continue to add alternative representations of my model - for example, if I added the ability to export the pet as an image, I could drag the pet over to Photos. 

OK, so that's exporting your data in multiple representations. There's one more thing I want to show you - how to implement drag and drop into custom views in your app.

### UIDragInteractionDelegate

As I mentioned earlier, I have an app here called Pet Editor. I want to be able to drag & drop pets from Pet Finder into Pet Editor, and the other way around too.

We'll start by adding drag support into Pet Editor. To do this, we'll make an extension on the view controller, to make it conform to the UIDragInteractionDelegate protocol.

We need to implement one method here: dragInteraction(:itemsForBeginning:). It's pretty simple - we create an Item Provider that will be responsible for exporting my pet, then we create a drag item wrapper around the item provider, and finally we return it as an array.

```
extension ViewController: UIDragInteractionDelegate {

  func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
    let itemProvider = NSItemProvider(object: pet)
    let dragItem = UIDragItem(itemProvider: itemProvider)
    return [ dragItem ]
  }

}
```

Back in viewDidLoad, all we need to do to add drag support for a view is call the addInteraction method, and create a new drag interaction specifying the delegate.

```
view.addInteraction(UIDragInteraction(delegate: self))
```

That's it! Now I can build and run, and I can drag the pet from Pet Editor into Pet Finder. Since they both support the Pet data model, it works!

I can't drag from Pet Finder to Pet Editor though, because I haven't added drop support yet. Let's add that next.

### UIDropInteractionDelegate

Back in ViewController, we need to make the class conform to another protocol: UIDropInteractionDelegagte.

The first method we need to implement is dropInteraction(:canHandle). This is our chance to say what kind of data our app supports. We'll say we can load objects of type pet.

The second method we need to implement is dropInteraction(:sessionDidUpdate). This is called as so we can specify what we plan on doing with the data. We plan on making a copy of it, so we'll specify that here.

The final method we need to implmenet is dropInteraction(:performDrop:). This is called after the user lifts up their finger to perform the drop. Here we use the session.loadobjects method to load all pet objects sent to us, and pull out the first one. Then we simply store the pet, adn call configureView to refresh the screen.

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

Finally, I need to remember to register a drop interaction on the view.

```
view.addInteraction(UIDropInteraction(delegate: self))
```

I'll build and run. Now I'll drag a pet from Pet Finder to Pet Editor, and nice! You can see the new pet in the editor. 

### Closing

Allright, that's everything I'd like to cover in this screencast.

At this point, you should know how to configure Drag & Drop in iOS 11 to export your app's data in multiple representations. You should also know how to add drag and drop into any view in your app.

That's it for this screencast - and be sure to "drop" in next time.