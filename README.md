# GraphPod

[![CI Status](https://img.shields.io/travis/d.s.vandyshev@gmail.com/GraphPod.svg?style=flat)](https://travis-ci.org/d.s.vandyshev@gmail.com/GraphPod)
[![Version](https://img.shields.io/cocoapods/v/GraphPod.svg?style=flat)](https://cocoapods.org/pods/GraphPod)
[![License](https://img.shields.io/cocoapods/l/GraphPod.svg?style=flat)](https://cocoapods.org/pods/GraphPod)
[![Platform](https://img.shields.io/cocoapods/p/GraphPod.svg?style=flat)](https://cocoapods.org/pods/GraphPod)

GraphPod is a pure Swift implemented library for image processing. GraphPod can:
 - Segment the image based on weighted graph, Kruskal algorithm and disjoint-set data structure.
 - GraphPod can detect image objects edges - it is done with Sobel operator applying. 
 - Graphod can blur the image using direct gauss blurring. You don't need to import UIKit.
 - GraphPod allows you to upload any image or use camera's one or choose any from saved in Photo library and get the processed image as a result for further processing in machine learning.

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

## How to use GraphPod in your project
After you add GraphPod in project it's very simple to use it
- If you need image segmenting just call SegmentingImageAlgorithm.execute and pass the image you'd like to process, threshold and minimal segment size, just like that:

```swift
let processedImage = SegmentingImageAlgorithm.execute(for: imageToProcess, with: threshold, with: minPixelsInSector)
```
and then set processedImage to UIImageView or save it to library or whatever you prefer.
Read more about threshold and minPixelsInSector below.



- If you need to detect edges call EdgeDetectionAlgorithm.execute and pass the image to process:

```swift
let processedImage = EdgeDetectionAlgorithm.execute(for: imageToProcess)
```



- To blur the image call BlurAlgorithm.execute:

```swift
let processedImage = BlurAlgorithm.execute(for: imageToProcess)
```

## Example App

To run the simple example project clone the repo and run `pod install` from the Example directory first.

You can run the demo App in the Example folder, research how it works and test algorithms with different coefficients and save final results.

![GraphPod](https://github.com/SergeyMorugin/GraphPod/blob/feature/ms-opt-4/docs/imgs/app3.jpg?raw=true)
![GraphPod](https://github.com/SergeyMorugin/GraphPod/blob/feature/ms-opt-4/docs/imgs/app4.jpg?raw=true)
![GraphPod](https://github.com/SergeyMorugin/GraphPod/blob/feature/ms-opt-4/docs/imgs/app5.jpg?raw=true)


## How Segmenting algorithm works

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


## How Edge detection algorithm works

### Convert input image to grayscale and smooth it

We need it to reduce colors intensity and diversity to have only black and white brightness value to make next calculation faster.

```swift
guard let grayScaledImage = image.convertToGrayScale() else { return defaultImage}

let smoothedImage = grayScaledImage.smoothing(sigma: 0.6)
```

### Next we convert grayscaled smoothed image to pixels color intensity array

```swift
 guard let pixelValuesFromGrayScaleImage = ImageProcessing.pixelValuesFromGrayScaleImage(imageRef: smoothedImage?.cgImage) else { return defaultImage }
```
### Then we apply Sobel operator to each element in this array

It gives us brightness gradient value for each pixel. It shows us how intense the brightness fluctuation in each pixel. If brightness change of a neighbor pixel  is bigger than chosen one it means we got an edge.

### Convert gradient matrix into image

As a result of Sobel operator work we receive 2D gradient map for every pixel. This map we can convert to an image:
```swift
 let edgesImage = ImageProcessing.createImageFromEdgesDetected(pixelValues: featureMatrix, width: processedImageWidth, height: processedImageHeight)
```


## Gauss blurring algorithm

The library implements a fast Gaussian blur algorithm with O (n) complexity
```swift
 let blurredImage = bitmapImage.fastGaussBlur(radius: 3)
```


## Author

d.s.vandyshev@gmail.com, cmorugin@gmail.com, doroshkevichilya@gmail.com

## License

GraphPod is available under the MIT license. See the LICENSE file for more info.

