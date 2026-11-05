#import "SceneDelegate.h"

#import "AppDelegate.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene
    willConnectToSession:(UISceneSession *)session
             options:(UISceneConnectionOptions *)connectionOptions
{
  if (![scene isKindOfClass:[UIWindowScene class]]) {
    return;
  }

  AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

  UIView *rootView = [appDelegate.rootViewFactory viewWithModuleName:appDelegate.moduleName
                                                     initialProperties:appDelegate.initialProps
                                                         launchOptions:nil];

  self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
  UIViewController *rootViewController = [appDelegate createRootViewController];
  [appDelegate setRootView:rootView toRootViewController:rootViewController];
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];

  // Keep the app delegate's window in sync so React Native internals that
  // reference UIApplication.delegate.window keep working under the scene lifecycle.
  appDelegate.window = self.window;
}

@end
