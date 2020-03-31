## Todo

* Fix ThumbnailNaivgator performance (implement as NSTableView instead of NSScrollView). Problem is that the .dataRepresentation method requires a lot of resources. It gets called on every page in the PDF. Better to only call it on the visible thumbnails, meaning that only visible thumbnails should be created. This can be resolved with a NSTableView 
* Fix ThumbnailView borders, they are off
* Implement ThumbnailNavigator resize (drag-to-resize: https://stackoverflow.com/questions/19360805/drag-to-resize-nsview-or-other-object)
* ThumbnailView: Make PageLabel right aligned and add small distance via constraint to the page view
