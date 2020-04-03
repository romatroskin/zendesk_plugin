#import "ZendeskPlugin.h"
#if __has_include(<zendesk_plugin/zendesk_plugin-Swift.h>)
#import <zendesk_plugin/zendesk_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "zendesk_plugin-Swift.h"
#endif

@implementation ZendeskPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftZendeskPlugin registerWithRegistrar:registrar];
}
@end
