platform :ios, '11.0'

install! 'cocoapods', :generate_multiple_pod_projects => true, :incremental_installation => true

def commonPods
    pod 'Swifter', :git => 'https://github.com/httpswift/swifter.git', :branch => 'stable'
end

target 'StubPlay iOS' do
  use_frameworks!
  commonPods
 
  target 'StubPlayTests' do
    inherit! :search_paths
    commonPods
  end

end

target 'StubPlay tvOS' do
  use_frameworks!
  commonPods
 
  target 'StubPlay tvOSTests' do
    inherit! :search_paths
    commonPods
  end

end


# Sample Apps

target 'Example-iOS' do
    use_frameworks!
    workspace 'StubPlay'
    project 'Examples/Example-iOS/Example-iOS'
    commonPods
    
    pod 'Alamofire'
    pod 'AlamofireImage'
end
