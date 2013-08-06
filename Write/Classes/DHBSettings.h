//
//  DHBSettings.h
//  Write
//
//  Created by David Brunow on 4/21/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHBSettings : NSObject

@property (nonatomic, retain) NSMutableArray *blogs;
@property (nonatomic) int selectedBlog;
@property (nonatomic) NSDictionary *settings;
@property (nonatomic) NSString *settingsPath;
@property (nonatomic) bool isInitialLaunch;

-(void)saveBlogs;

@end
