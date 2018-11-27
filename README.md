# SHMultiSlider

## A rotary knob with 2 sliders for macOS, good for display value and range selection.

<img width=200 src="https://raw.githubusercontent.com/Rexhits/SHMultiSlider/master/Demo.gif">

### Installation
SHMultiSlider is written in Swift 4.2, so your code has to be written in Swift 4.x due to current binary compatibility limitations.

### CocoaPods
To use [CocoaPods](https://cocoapods.org) add SHMIDIKit to your `Podfile`:

```ruby
pod 'SHMultiSlider'
```
Then run `pod install`.

#### Note: if you'd like to use it in storyboard, please add the following line to your `Podfile`:
```ruby
use_frameworks!
```

### Example
```swift
import SHMultiSlider

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let multislider = SHMultiSlider(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
        self.view.addSubview(slider)
    }
}
```
#### Note: Always make sure its width=height (it's a square), otherwise it may not display properly. 
### [Doucmentation](https://rexhits.github.io/SHMultiSlider/)
