## iOS 11 Drag and Drop with Table and Collection Views (2546 words, 11 min)

Hey what's up everybody, this is Ray. In today's screencast, I'm going to introduce you to a brand new feature in iOS 10: the ability to add drag and drop support into your apps.

The iPad comes with nice multitasking support - you can run two apps side by side with split view, or with the slide over mode. New this year, iOS has added the abiity to drag and drop items between apps - a feature that is sure to be a huge timesaver, and higly desired by users. The good news is - it's easy to add.

In this screencast, I'll show you how to add Drag and Drop support into your iPad apps. I'll be showing you how to do this with a table view in this screencast, but if you watch this screencast you'll also know how to do this with collection views, since it's pretty much the exact same process, just slightly renamed APIs. 

## Getting Started

I have a simple iPad app here called Pet Finder that lists a batch of pets up for adoption. I'd like to add drag and drop support into this app, so I can drag the pets from the top table view into the bottom table view. I'd also like to be able to drag and drop to completely different apps - for example, maybe I want to add a reminder for a pet I'd like to adopt.

## Interlude

The first step to adding Drag and Drop support is to write create a Drag Item object. This represents the item that you want to drag - which in our example of Pet Finder, would be our pet.

A drag item is a small wrapper around an item provider. An item provider is the brains behind the operation - it knows how to convert your item into different data formats.

For now, we're going to start simple, and we'll create an Item Provider that can export our pet as a simple string, with the name of the pet.

### Code

I'll start by opening PetsDataStore.swift, and import MobileCoreServices. This is required to use a UTI type enumeration that I'll need in a second.

```
import MobileCoreServices
```

Next, I'll make a helper method to create the drag items for a given index path.

1. First, I'll look up the pet for the given index path.
2. Then, I'll create an empty NSItemProvider. Remember that a UIDragItem is just a simple wrapper around an NSItemProvider, which is the brains behind the data conversion task.
3. I'll then call registerDataRepresentation, passing in the plain text UTI. This is basically saying "hey, this Item provider supports formatting this data as plain text, and here's a closure to call whenever you want to format it this way." Note that this closure isn't alled right away - it only happens if you drag this data somewhere, and whever you drop it wants to receive the data in this format.
4. Once the drop target requests the data in plain text format, I'll convert the pet's name to a data buffer, in UTF8 format.
5. Once I'm done, I'll call the completion handler. 
6. Now that I've created the NSItemProvider, I create a UIDragItem wrapper.
7. Finally, I return this as an array.

```
func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
  let pet = pets[indexPath.row] // 1
  
  let itemProvider = NSItemProvider() // 2
  itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in // 3
      let data = pet.name.data(using: .utf8) // 4
      completion(data, nil) // 5
      return nil
  }

  let dragItem = UIDragItem(itemProvider: itemProvider) // 6
  return [ dragItem ] // 7
}
```

Now that we have this method, it's easy to conform to the protocol required to add drag and drop support. 

I'll open PetsViewController, and add an extension to conform to the protocol: UITableViewDragDelegate. It has just a single method to implement: tableView(:itemsForBeginning:session:at:). 

Inside this method, I find the appropriate data source using a helper method, then call the dragItems method we just wrote on that data source.

```
extension PetsViewController: UITableViewDragDelegate {
  func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    let dataSource = dataSourceForTableView(tableView)
    return dataSource.dragItems(for: indexPath)
  }
}
```

Finally, inside viewDidLoad(), right before tableView.reloadData(), I'll set the drag delegate to self.

```
tableView.dragDelegate = self
```

That's it! I'll build and run, and note if I tap and hold on an item, it starts dragging. Of course, I can't drop it in this app yet since I haven't added drop support - however I can drop it elsewhere.

I'll slide up from the bottom of the screen, and drag Reminders over to the right and dock it. Then I'll drag Tiger over to Reminders - and nice, it accepts the drag and automatically adds a reminder to the list.

### Interlude

At this point, we've implemented the delegate to provide dragging support, which had 1 required method - to get the list of drag items. Remember, that just was a wrapper around item provier, which provided a closure to return the pet in string format.

Let's now implement the delegate to provide dropping support, which has 3 required methods. 

  1. iOS calls your first method to find out what types of data you are able to accept. In our case, we'll accept strings.
  2. iOS calls our second method to find out what you intend to do with the given data - you can choose to move, copy, or cancel it. In our case, we'll make different choice here based on the situation.
  3. Your third method is called when user commits the drop - at this point, you go back to your friend the item provider and request the data. In our case, we'll ask for the data in string format so the conversion can occur, then we'll create a new pet with that name.

Let's see what this looks like.

### Demo

First, I'll open Pet.swift and add a helper method to retrieve the types of objects that we can accept. 

The passed in session object has a method called canLoadObjects, which you can use to see if the data being dropped can be converted into a target object type. We're going to only accept strings, so we'll pass in NSString.self here.

Note that although we're only accepting strings at the moment, you can accept multiple types of data if you'd like. That's what I'll be showing you in the next screencast, which covers accepting multiple data representations.

```
public static func canHandle(_ session: UIDropSession) -> Bool {
  return session.canLoadObjects(ofClass: NSString.self)
}
```

Next I'll open PetsViewController.swift and add an extension for the protocol required to accept dropping data - UITableViewDropDelegate. We'll start with the firrst required method, tableView(:canHandle:). This will simply call the helper method we just wrote.

```
extension PetsViewController: UITableViewDropDelegate {

  func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
    return Pet.canHandle(session)
  }
}
```

Next, I'll implement the second required method: tableView(:dropSessionDidUpdate:withDestinationIndexPath:).

Basically, this method lets you specify what you intend to do with the dropped data - move it, copy it, or reject it.

1. First we'll see if the user is dragging within the source table.
2. If it is, and they're dragging more than one thing, we'll reject it, by returning a drop proposal of type cancel. For this app, you can only move one item at a time around the table view.
3. At this point, we know that the user is dragging just one thing within our table view. So we'll return that we intend to move the item to the new spot, rather than copy it.
4. If we reach the else statement, than we know we're receiving an item that came from some other table view. So in this case, we'll make a copy of the data.

```
  func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
    if tableView.hasActiveDrag { // 1
      if session.items.count > 1 { // 2
        return UITableViewDropProposal(operation: .cancel)
      } else { // 3
        return UITableViewDropProposal(dropOperation: .move, intent: .insertAtDestinationIndexPath)
      }
    } else { // 4
      return UITableViewDropProposal(dropOperation: .copy, intent: .insertAtDestinationIndexPath)
    }
  }
```

There's one required method left: tableView(:performDropWith:). This is the workhorse that does the drop operation.

1. First, we'll get the data source for the table view.
2. Then, we'll figure out where we should put the new item. If the coordinator gives us a destination, great we'll use that. But if it doesn't, we'll just create an index path to put it at the end of the table.
3. Finally, we'll loop through all of the items that are dropped, and process each one. There are three cases we need to handle - the item originated from the same app and the same table view, the item originated in the same app, but a different table view, and the item originated from a different app.

```
  func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {

    let dataSource = dataSourceForTableView(tableView) // 1

    // 2
    let destinationIndexPath: IndexPath
    if let indexPath = coordinator.destinationIndexPath {
      destinationIndexPath = indexPath
    } else {
      let section = tableView.numberOfSections - 1
      let row = tableView.numberOfRows(inSection: section)
      destinationIndexPath = IndexPath(row: row, section: section)
    }

    // 3
    for item in coordinator.items {

      // TODO: Item originated from same app, and same table view
      // TODO: Item originated from same app, but different table view
      // TODO: Item originated from different app

    }
  }
```

Let's start with the final case, as the other two are optimizatoins. I'll put an if(false) temporarily so we can focus on the final case for now.

1. First, I'll print a message so we know what case we're in while we're debugging. Although Eventually this will only be called when we receive data dropped from a different app, but remembrer I put if(false) for the other cases so for now this will always be called.

2. Next, I get a reference to the item provider. Remember, that is that brainy object that can convert the data you're dragging into different formats.

3. Then, I use a helper method on the item provider to load the data in the format I want to accept - NSString in this case. NSString is one of the objects that implements the required protocols for conversion - along with NSAttributedString, NSURL, UIColor, UIImage, and MKMapItem. You can also make your own objects conform to this protocol, like you'll learn in the next screencast.

4. I then convert the string from an NSString to a String.

5. I then create a pet object, given the name, "Unknown" for the type, and no image.

6. I then add the new pet to our list of pets in the data source.

7. Finally, I update the table view with tableView.insertRows, making sure to execute this on the main thread.

```      
      if (false) { }
      
      // Item originated from different app
      else {
        print("Different app") // 1

        let itemProvider = item.dragItem.itemProvider // 2
        itemProvider.loadObject(ofClass: NSString.self) { string, error in // 3
          if let string = string as? String { // 4
            let pet = Pet(name: string, type: "Unknown", image: nil) // 5
            dataSource.addPet(pet, at: destinationIndexPath.row) // 6
            DispatchQueue.main.async { // 7
              tableView.insertRows(at: [destinationIndexPath], with: .automatic) // 8
            }
          }
        }
      }
```

There's one last thing - back in viewDidLoad, I'll set the drop delegate to self.

```
tableView.dropDelegate = self
```

Oops - I have a typo here - I typed IndexPath but meant in.

At this point, I can build and run, and check it out - I can drag and drop items from the reminders app into my app. I can also drag items between the table views, and the table view itself, but if I do this I lose data since currently I'm only saving the name of the pet out. Luckily, there is an optimization here that will fix that, and we'll do that next!

### Interlude

If you think about it, if you drag and drop within your own app, what we're doing is really silly.

We already have the pet object in memory, so there's no need to encode it out to a limited UTF8 string buffer and back. 

Instead, if it's in the same table view, we should simply swap the rows. And if it's within the same app, the drag item provides a handy localObject property you can use to "squirrel" away the pet for use later - what, squirrels make great pets! Anyway, let's take a look.

## Optimizations

Let's fill in that first TODO. If the item has the sourceIndexPath property set, that means it's from the same app and the same table view. So I'll call moveItem on the data source to swap the positions, then on the main thread I'll perform a batch update to delete the row at the source, and insert a row at the destination.

```
      // Item originated from same app, and same table view
      if let sourceIndexPath = item.sourceIndexPath {
        print("Same app - Same table view")
        dataSource.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
        DispatchQueue.main.async {
          tableView.beginUpdates()
          tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
          tableView.insertRows(at: [destinationIndexPath], with: .automatic)
          tableView.endUpdates()
        }
      }
```

But what about if the item comes from the same app, but a different table view? Well, I'll open PetsDataSource.swift, and in dragItems(for:), right before return [ dragItem ], I'll et the drag item's local object to the pet I'd like to transfer.

```
dragItem.localObject = pet
```

Now back in PetsViewController.swift I can implement the final TODO. If the local object is set, then I'll add it to the data source directly, and update the table view.

```          
      // Item originated from same app, but different table view
      else if let pet = item.dragItem.localObject as? Pet {
        print("Same app - Different table view")
        dataSource.addPet(pet, at: destinationIndexPath.row)
        DispatchQueue.main.async {
          tableView.insertRows(at: [destinationIndexPath], with: .automatic)
        }
      }
```

Now I'll build and run, and check it out -  I can move items within the table view, which works by swapping the rows, as we can see in the console with the "Same app - Same table view" case. I can also move items to the completely different adopted pets table view and it also works - and wee see this works by copying the pet we stored in the localObject property, as we can see in the console with the "Same app - Different table view" case.

### Interlude

There's one last thing I want to show you. Although the String conversion we're doing here happens very fast, sometimes it might take an item provider some time to convert its data to the format you request. So when dropping an item into a table view, it's better to insert a placeholder cell as you wait for the conversion to complete. This is a quick fix.

## Demo

Still in PetsViewController.swift, inside tableView(:performDropWith:), in the "different app" case, I'll call a helper method to add the placeholder cell. I need to pass in the drag item, the destination path, the identifier of the cell to use and hheight, and a handler to update the cell. I'll just set the text to "loading."

Then, once itemProvider.loadObject closure complets, I'll call context.commitInsertion() and pass in a closure to update the data source appropriately. iOS will handle the table view animations automatically.

```
let context = coordinator.drop(item.dragItem, toPlaceholderInsertedAt: destinationIndexPath, withReuseIdentifier: "PetCell", rowHeight: 110, cellUpdateHandler: { cell in
          cell.textLabel?.text = "Loading..."
        })
```

```
DispatchQueue.main.async {
              context.commitInsertion(dataSourceUpdates: { indexPath in
                dataSource.addPet(pet, at: destinationIndexPath.row)
              })
            }
```  

I'll build and run, and if I drag a string in from another app I see a brief loading placeholder. It's pretty quick for this, but this is a good practice for when your data gets more involved.

### Closing

Allright, that's everything I'd like to cover in this screencast.

At this point, you should understand how to implement the new iOS 11 drag and drop functionality into a table view. And even though this screencast showed table views, you should know how to do this with collection views now too, because it's the exact same idea, jsut slightly different names.

You might be curious to learn how to save data in different formats, or how to implement drag and drop with custom views - and that's the topic of my next screencast. I promise you - it won't be a drag.

That's it for this screencast - I'm out!