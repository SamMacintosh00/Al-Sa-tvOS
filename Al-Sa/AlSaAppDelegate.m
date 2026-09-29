#import "AlSaAppDelegate.h"
#import "AlSaViewController.h"

@implementation AlSaAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[AlSaViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
