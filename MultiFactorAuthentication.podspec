
Pod::Spec.new do |spec|


  spec.name         = "MultiFactorAuthentication"
  spec.version      = "1.0.0"
  spec.summary      = "This framework is used for Authentication."


  spec.description  = "This is the best Framework is used for Notification and Authentication purpose."

  spec.homepage     = "https://Sridharan0@github.com/Sridharan0/MultiFactorAuthentication"
 

  spec.license      = "MIT"

  spec.author             = { "sridharan" => "sridharan@softsuave.com" }
  
  spec.platform     = :ios, "13.0"


  spec.source       = { :git => "https://Sridharan0@github.com/Sridharan0/MultiFactorAuthentication.git", :tag => spec.version.to_s }


 
  spec.swift_versions  = "5.0"
  spec.source_files = 'MultiFactorAuthentication/**/*.{h,m,swift}'
spec.resource_bundles = {
  'MyPodBundle' => 'MultiFactorAuthentication/**/*.png'
}
spec.preserve_paths = 'MultiFactorAuthentication/**/*.png'

spec.pod_target_xcconfig = {
  'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/MultiFactorAuthentication/Classes',
  'OTHER_SWIFT_FLAGS' => '-DINCLUDE_ MultiFactorAuthentication_CLASS_IN_MAIN_BUNDLE'
}

end
