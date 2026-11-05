#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import "SceneDelegate.h"

@implementation AppDelegate

- (instancetype)init
{
  if (self = [super init]) {
    // iOS 27 requires apps built with the iOS 27 SDK to adopt the UIScene
    // lifecycle. The React Native window is created by SceneDelegate inside
    // the window scene instead of here on the application delegate.
    self.automaticallyLoadReactNativeWindow = NO;
  }
  return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"example";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// Providing a UISceneConfiguration here is what counts as "adopting" the scene
// lifecycle on iOS 27; a UIApplicationSceneManifest in Info.plist alone is not enough.
- (UISceneConfiguration *)application:(UIApplication *)application
      configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
              options:(UISceneConnectionOptions *)options
{
  UISceneConfiguration *configuration =
      [UISceneConfiguration configurationWithName:@"Default" sessionRole:connectingSceneSession.role];
  configuration.delegateClass = [SceneDelegate class];
  return configuration;
}

// Required by the bridgeless (New Architecture) runtime in RN 0.76+.
- (NSURL *)bundleURL
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
  return [self getBundleURL];
}

- (NSURL *)getBundleURL
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
