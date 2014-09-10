Pod::Spec.new do |s|
  s.name         = "LAbstractASIDataSourcePromiseKit"
  s.version      = "1.0"
  s.platform     = :ios, '6.0'
  s.source       = { :git => 'https://github.com/lukagabric/LAbstractASIDataSource'}
  s.source_files = "LAbstractASIDataSource/Classes/LASIDataSource.m", "LAbstractASIDataSource/Classes/LASIDataSource.h", "LAbstractASIDataSource/Classes/LAbstractParser.m", "LAbstractASIDataSource/Classes/LAbstractParser.h", "LAbstractASIDataSource/Classes/LAbstractJSONParser.m", "LAbstractASIDataSource/Classes/LAbstractJSONParser.h", "LAbstractASIDataSource/Classes/LParserInterface.h", "LAbstractASIDataSource/Classes/LASIDataSource+PromiseKit.m", "LAbstractASIDataSource/Classes/LASIDataSource+PromiseKit.h"
  s.dependency 'PromiseKit'
  s.dependency 'ASIHTTPRequest'
  s.dependency 'MBProgressHUD'
  s.requires_arc = true
end
