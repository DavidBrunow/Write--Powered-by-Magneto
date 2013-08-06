//
//  DHBBlogPostsViewController.h
//  Write
//
//  Created by David Brunow on 5/13/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHBBlogPost.h"

@interface DHBBlogPostsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, retain) UITableView *blogPostsTableView;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) UIBarButtonItem *rightButton;

- (void) editBlogPost:(DHBBlogPost *) post;

@end
