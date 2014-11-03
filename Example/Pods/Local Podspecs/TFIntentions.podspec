#
# Be sure to run `pod lib lint TFIntentions.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "TFIntentions"
  s.version          = "0.0.1"
  s.summary          = "Useful iOS Intention objects to use with IB."
  s.description      = <<-DESC
                        Set of generic single responsibility intention objects which, together with IB, are able to lift coding to absolutely new level of simplicity.
                       DESC
  s.homepage         = "https://github.com/TriforkKRK/TFIntentions"
  
  s.license          = 'Apache v2'
  s.author           = { "Krzysztof Profic" => "kprofic@gmail.com" }
  s.source           = { :git => "https://github.com/TriforkKRK/TFIntentions.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/triforkkrk'

  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.source_files     = 'Pod/*.{h,m}'
  
  s.subspec 'UITableView' do |sub|
    sub.source_files = 'Pod/UITableView/*.{m,h}'
  end
  s.subspec 'UITextField' do |sub|
    sub.source_files = 'Pod/UITextField/*.{m,h}'
  end
  s.subspec 'NibExternalObjects' do |sub|
    sub.source_files = 'Pod/NibExternalObjects/*.{m,h}'
  end
end
