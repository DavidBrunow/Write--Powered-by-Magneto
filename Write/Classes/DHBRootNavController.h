//
//  DHBRootNavController.h
//  Write
//
//  Created by David Brunow on 4/21/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHBViewController.h"
#import "DHBBlogViewController.h"


@interface DHBRootNavController : UINavigationController

@property (nonatomic, retain) DHBViewController *blogListViewController;
@property (nonatomic, strong) DHBBlogViewController *blogsViewController;

@end
