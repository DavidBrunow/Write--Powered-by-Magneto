//
//  DHBBlogViewController.h
//  Write
//
//  Created by David Brunow on 7/13/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHBBlogViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *blogsTableView;
@property (nonatomic, retain) UIBarButtonItem *rightButton;

@end
