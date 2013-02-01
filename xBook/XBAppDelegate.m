//
//  XBAppDelegate.m
//  xBook
//
//  Created by Alexey Goncharov on 29.01.13.
//  Copyright (c) 2013 xomox. All rights reserved.
//

#import "XBAppDelegate.h"
#import "XBRootViewController.h"

@implementation XBAppDelegate

- (void)copyToDocumentsFile:(NSString *)filename ofType:(NSString *)type {
  NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *txtPath = [documentsDirectory stringByAppendingPathComponent:filename];
  txtPath = [txtPath stringByAppendingString:@"."];
  txtPath = [txtPath stringByAppendingString:type];
	
	if ([fileManager fileExistsAtPath:txtPath] == NO) {
		NSString *resourcePath = [[NSBundle mainBundle] pathForResource:filename ofType:type];
		[fileManager copyItemAtPath:resourcePath toPath:txtPath error:&error];
    NSLog(@"copied");
	}
  if (error) {
    NSLog(@"error :: %@", error);
  }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self copyToDocumentsFile:@"book" ofType:@"epub"];
  UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[XBRootViewController alloc]init]];
  nav.navigationBarHidden = YES;
  self.window.rootViewController = nav;
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
