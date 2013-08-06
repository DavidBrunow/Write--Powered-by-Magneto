//
//  DHBPostTitleView.h
//  Write
//
//  Created by David Brunow on 6/18/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHBBlogPostsViewController.h"
#import "DHBPostEditViewController.h"

@interface DHBTitleView : UIView

@property (nonatomic, retain) UILabel *lblTitle;
@property (nonatomic, retain) UITextField *txtTitle;
@property (nonatomic, retain) UIButton *btnFinish;
@property (nonatomic, retain) id parentViewController;

@end
