//
//  AppDelegate.m
//  eOpening
//
//  Created by 枫叶砂 on 2018/4/9.
//  Copyright © 2018年 枫叶砂. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "FTDKeyChain.h"
#import <AVFoundation/AVFoundation.h>
@interface AppDelegate ()
@property(nonatomic, strong)ViewController *viewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    

    ViewController *viewController = [[ViewController alloc]init];
    self.viewController = viewController;
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:viewController];
    
    //web声音
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL ok;
    NSError *setCategoryError = nil;
    ok = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!ok) {
        NSLog(@"%s setCategoryError=%@", __PRETTY_FUNCTION__, setCategoryError);
    }
    
    //YES不自动锁屏 NO自动锁屏
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    //[self.viewController cancelAllAlert];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self.viewController cancelAllAlert];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self deleyToRefreshHome];
    });
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}



- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)deleyToRefreshHome{
     [[NSNotificationCenter defaultCenter] postNotificationName:kDidBecomeActiveNotification object:nil];
}
 
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    NSDictionary * uudic = [BDTools urlTurnToDataDictionary:url];
    NSLog(@"token == %@",uudic[@"token"]);
    NSString * token = uudic[@"token"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:token forKey:@"access_token"];
    [userDefaults synchronize];
//    kPOP(uudic[@"token"]);
    [self.viewController cancelAllAlert];
    [self deleyToRefreshHome];

    return YES;

}

@end
