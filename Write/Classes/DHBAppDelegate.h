//
//  DHBAppDelegate.h
//  Write
//
//  Created by David Brunow on 4/16/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "DHBDropBox.h"
#import "DHBRootNavController.h"
#import "DHBSettings.h"

@interface DHBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DHBDropBox *dropBox;
@property (strong, nonatomic) DHBRootNavController *rootNavController;
@property (strong, nonatomic) DHBSettings *settings;

@end
