//
//  DHBViewController.h
//  Write
//
//  Created by David Brunow on 4/21/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface DHBViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *blogsTableView;
@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) UIButton *cancelButton;

@end
