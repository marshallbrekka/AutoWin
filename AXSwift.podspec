Pod::Spec.new do |s|
  s.name                    = "AXSwift"
  s.version                 = "0.0.1"
  s.summary                 = "Vendored Framework in a spec test pod."
  s.description             = "This spec specifies a vendored framework."

  s.osx.deployment_target   = '10.9'
  s.homepage                = "https://cocoapods.org"
  s.license                 = { :type => "MIT", :file => "../../../../LICENSE" }
  s.author                  = "Mark Spanbroek"
  s.source                  = {:git => 'https://github.com/tmandry/AXSwift.git',
                               :commit => '4b18316'}
  s.source_files =  "AXSwift/*.swift"
end
