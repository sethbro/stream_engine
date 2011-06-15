**This code is not maintained!**. It was written for a particular project that never came to fruition, and I no longer develop Actionscript. Nonetheless, it's a decent foundation upon which to build a simple webcam streaming solution, so I hope someone might find it helpful.

## Overview

Start by taking a look at StreamEngine.as, which is an example application class. It subclasses StreamView, as should you. This subclass should be used as the root class of an FLA.

With your engine subclass, initialize a StreamController instance and call `addConnection( connection_name, source, destination )`

Four flavors of streaming connections are supported:

* Webcam -> Media server (network location)
* Webcam -> Local playback
* Media server -> Local playback
* Local file -> Local playback

It is not possible to save a webcam stream to a local file.

* `StreamConnection` handles the logic to connect the various interfaces.
* `StreamDisplay` is a Video instance for local playback.
* `InfoPanel` allows monitoring of video attributes during playback.
* `StreamView` is the application base class and can instantiate numerous displays and panels for local playback.

### Caveats

* No audio support (it's stubbed out but incomplete).
* Probably some hardcoded values in the code. I'll review and try to remove.
* I used successfully with an Amazon S3 Wowza Media Server instance. Your mileage may vary.
* No tests.
