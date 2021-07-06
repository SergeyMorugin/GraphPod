# GraphPod

[![CI Status](https://img.shields.io/travis/d.s.vandyshev@gmail.com/GraphPod.svg?style=flat)](https://travis-ci.org/d.s.vandyshev@gmail.com/GraphPod)
[![Version](https://img.shields.io/cocoapods/v/GraphPod.svg?style=flat)](https://cocoapods.org/pods/GraphPod)
[![License](https://img.shields.io/cocoapods/l/GraphPod.svg?style=flat)](https://cocoapods.org/pods/GraphPod)
[![Platform](https://img.shields.io/cocoapods/p/GraphPod.svg?style=flat)](https://cocoapods.org/pods/GraphPod)

GraphPod is a pure Swift implementation of an image segmentation functionality based on weighted graph, Kruskal algorithm and disjoint-set data structure. GraphPod allows you to upload any image or use camera's one or choose any from saved in Photo library and get the segmented image as a result for further processing in machine learning.

It includes copious in-source documentation, unit tests.

## Requirements

iOS 9 and more.

## Installation

GraphPod is available through [CocoaPods](https://cocoapods.org). To install
it simply add the following line to your Podfile:

```swift
pod 'GraphPod'
```
and then `pod install`.

### How to use GraphPod in your project

After you add GraphPod in project it's very simple to use it - just call SegmentingImageAlgorithm.execute and pass the image you'd like to process, threshold and minimal segment size, just like that:

```swift
let processedImage = SegmentingImageAlgorithm.execute(for: imageToProcess, with: threshold, with: minPixelsInSector)

```
and then set processedImage to UIImageView or save it to library or whatever you prefer.

Read more about threshold and minPixelsInSector below.

## Example

To run the example project clone the repo and run `pod install` from the Example directory first.

### Example App

You can run the demo App in the Example folder, research how it works and test algorithm with different coefficients and save results.

![GraphPod](https://github.com/SergeyMorugin/GraphPod/blob/feature/ms-optimizing-1/docs/imgs/app2.jpg?raw=true)

## How it all works

### Convert input image to bitmap

The library works with BitmapImage data format. First we need to convert UIImage to Bitmap format as below as Bitmap gives best efficiency in loop iterating through image pixels color data.

```swift
let bitmapImage = UIImage(named:"testImage").toBitmapImage()
```

### Use Gaussian smoothing

Smoothing is necessary to smooth the neighbor pixels intensity and make it easier to join them into one segment. 

### Create weighted graph

Graph is a data structure with every image pixel as a vertex and edges between four neighbor pixels. We need weighted graph here as an image segment will be created according to each edge weight. As a weight we take neighbored pixels rgb intensity difference.

```swift
var wGraph = bitmapImage.createWGraph()
```

### Create segments using disjoint-set data structure, threshold and minPixelsInSector coefficients

Segment is a pixels group combined together by edges weight between them. If edge weight is below threshold it will be grouped into one segment that means one and only parent pixel (other words "tree root") will be set for this pair. Segment size defined by minPixelsInSector value. The more minPixelsInSector the more segment size.

```swift
let pixelsCombinedInSegments = wGrath.createSegmentSets(threshold: threshold, minSize: minSize)
```

### Post-process segments

Post-process is needed to combine smallest segments into large ones to avoid visible noise on a result picture. Here we use minimum_size_segment coefficient we can define manually to get more or less segmented result image.

### Create rgb colors array for segments

We take every segment parent pixel number and match the random color number to it to get colors array according to segments position.

### Convert colors array to bitmap

Bitmap allows us to create result image with the best performance.

### Convert bitmap to UIImage

Finally get the result image.

## Author

d.s.vandyshev@gmail.com, cmorugin@gmail.com, doroshkevichilya@gmail.com

## License

GraphPod is available under the MIT license. See the LICENSE file for more info.

