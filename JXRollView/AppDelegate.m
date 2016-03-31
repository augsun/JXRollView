//
//  AppDelegate.m
//  JXRollView
//
//  Created by shiba_iosJX on 3/31/16.
//  Copyright © 2016 shiba_iosJX. All rights reserved.
//

#import "AppDelegate.h"
#import "JXRollView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}





- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
#warning JXRollView: best to do so.
    [[NSNotificationCenter defaultCenter] postNotificationName:JXROLLVIEW_PAUSE object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
#warning JXRollView: best to do so.
    [[NSNotificationCenter defaultCenter] postNotificationName:JXROLLVIEW_PLAY object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end
