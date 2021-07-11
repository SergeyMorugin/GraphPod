#
# Be sure to run `pod lib lint GraphPod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GraphPod'
  s.version          = '0.1.1'
  s.summary          = 'Swift implementation of an image procesing functionality.'



  s.description      = <<-DESC
   GraphPod is a pure Swift implementation of an image segmentation functionality based on weighted graph, 
   Kruskal algorithm and disjoint-set data structure. GraphPod allows you to upload any image or use camera's 
   one or choose any from saved in Photo library and get the segmented image as a result for further processing in machine learning.
                       DESC

  s.homepage         = 'https://github.com/SergeyMorugin/GraphPod'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cmorugin@gmail.com' => 'cmorugin@gmail.com' }
  s.source           = { :git => 'https://github.com/SergeyMorugin/GraphPod.git', :tag => s.version.to_s }


  s.ios.deployment_target = '9.0'

  s.source_files = 'GraphPod/Classes/**/*'
  s.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'Example/Tests/*.{swift}'
    end
end
