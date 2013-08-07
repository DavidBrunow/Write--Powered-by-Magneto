//
//  DHBAppDelegate.m
//  Write
//
//  Created by David Brunow on 4/16/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBAppDelegate.h"
#import "DHBRootNavController.h"
#import "SimpleKeychain.h"
#import "DHBCredentials.h"

@implementation DHBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.settings = [[DHBSettings alloc] init];
    
    self.dropBox = [[DHBDropBox alloc] init];
    
    self.rootNavController = [[DHBRootNavController alloc] init];
    
    [self.window setRootViewController:self.rootNavController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            NSArray *queryParameters = [url.query componentsSeparatedByString:@"&"];
            NSString *oauthToken = @"";
            NSString *oauthTokenSecret = @"";
            NSString *userID = @"";
            
            for(NSString *queryParameter in queryParameters) {
                if([[[queryParameter componentsSeparatedByString:@"="] objectAtIndex:0] isEqualToString:@"oauth_token"]) {
                    oauthToken = [[queryParameter componentsSeparatedByString:@"="] objectAtIndex:1];
                } else if([[[queryParameter componentsSeparatedByString:@"="] objectAtIndex:0] isEqualToString:@"oauth_token_secret"]) {
                    oauthTokenSecret = [[queryParameter componentsSeparatedByString:@"="] objectAtIndex:1];
                } else if([[[queryParameter componentsSeparatedByString:@"="] objectAtIndex:0] isEqualToString:@"uid"]) {
                    userID = [[queryParameter componentsSeparatedByString:@"="] objectAtIndex:1];
                }
            }
            
            //NSLog(@"Token: %@. Secret: %@. UserID: %@", oauthToken, oauthTokenSecret, userID);
            bool success = [SFHFKeychainUtils storeUsername:USER_NAME_TOKEN andPassword:oauthToken forServiceName:SERVICE_NAME updateExisting:TRUE error:nil];
            success = [SFHFKeychainUtils storeUsername:USER_NAME_TOKEN_SECRET andPassword:oauthTokenSecret forServiceName:SERVICE_NAME updateExisting:TRUE error:nil];
            success = [SFHFKeychainUtils storeUsername:USER_NAME_USER_NAME andPassword:userID forServiceName:SERVICE_NAME updateExisting:TRUE error:nil];

            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

@end
