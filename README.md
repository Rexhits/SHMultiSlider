# SHMultiSlider

## A rotary knob with 2 sliders for macOS, good for display value and range selection.

<img width=200 src="https://raw.githubusercontent.com/Rexhits/SHMultiSlider/master/Demo.gif">
As shwon, when moving the 2 sliders, the output value will be remaped to new range.

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

class ViewController: NSViewController, SHMultiSliderDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let multislider = SHMultiSlider(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
        self.view.addSubview(slider)
        // IMPORTANT! Set delegate to self, otherwise you won't get any callback
        multislider.delegate = self
        // Set slider value
        multislider.setValue(100)
        // Change the text for the label on top
        multislider.sourceName = "LFO"
        // Change the text for the label on bottom
        multislider.targetName = "Pan"
        
        // Set lowerbound of output value, output will be remapped to new range
        multislider.slider.setLowerBoundValue(0)
        // Set upperbound of output value, output will be remapped to new range
        multislider.setUpperBoundValue(100)
        
        // Set input value range
        multislider.min = 0
        multislider.max = 100
        
        
        /// Implement delegate methods
        
        // value change callback
        func valueChanged(_ newValue: Int) {
            print(newValue)
        }
        // boundsChangeCallback
        func boundsUpdated(lower: Int, upper: Int) {
            print((lower, upper))
        }
    }
}
```
#### Note: Always make sure the multislider's length is >= 100, being too small may cause improper display. 
### [Doucmentation](https://rexhits.github.io/SHMultiSlider/)
