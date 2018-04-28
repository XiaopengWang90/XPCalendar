@version = "1.0.0"
Pod::Spec.new do |s| 
s.name = "XPCalendar" 
s.version = @version 
s.summary = "一个简洁的日历选择" 
s.description = "一个简洁的日历选择,可以修改选择的颜色" 
s.homepage = "https://github.com/XiaopengWang90/XPCalendar" 
s.license = { :type => 'MIT', :file => 'LICENSE' } 
s.author = { "wangxiaopeng" => "461607156@qq.com" } 
s.ios.deployment_target = '8.0' 
s.source = { :git => "https://github.com/XiaopengWang90/XPCalendar.git", :tag => "v#{s.version}" } 
s.source_files = "XPCalendar/*.{h,m}" 
s.requires_arc = true 
#s.framework = “UIKit” 
end