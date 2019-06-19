install! 'cocoapods', :generate_multiple_pod_projects => true, :incremental_installation => true

def commonPods
    pod 'Swifter'
end

target 'StubPlay iOS' do
  platform :ios, '11.0'
  use_frameworks!
  commonPods
 
  target 'StubPlayTests' do
    inherit! :search_paths
    commonPods
  end

end

target 'StubPlay tvOS' do
  platform :tvos, '11.0'
  use_frameworks!
  commonPods
 
  target 'StubPlay tvOSTests' do
    inherit! :search_paths
    commonPods
  end

end


# Sample Apps

target 'Example-iOS' do
    platform :ios, '11.0'
    use_frameworks!
    workspace 'StubPlay'
    project 'Examples/Example-iOS/Example-iOS'
    commonPods
    
    pod 'Alamofire'
    pod 'AlamofireImage'
end
