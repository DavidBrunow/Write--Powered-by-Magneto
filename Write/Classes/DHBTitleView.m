//
//  DHBPostTitleView.m
//  Write
//
//  Created by David Brunow on 6/18/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBTitleView.h"
#import "DHBAppDelegate.h"
#import "DHBBlog.h"

@implementation DHBTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, self.frame.size.width - 40, 50)];
        self.txtTitle = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, self.frame.size.width - 40, 50)];
        self.btnFinish = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [self setBackgroundColor:[UIColor whiteColor]];
    
    //[lblPostTitle setText:@"Title:"];
    
    [self.txtTitle setBorderStyle:UITextBorderStyleLine];
    [self.txtTitle setText:@""];
    
    [self.btnFinish setFrame:CGRectMake(self.frame.size.width - 150, 170, 150, 30)];
    
    //[self.btnFinish setTitle:@"Create Draft" forState:UIControlStateNormal];

    [self addSubview:self.btnFinish];
    [self addSubview:self.lblTitle];
    [self addSubview:self.txtTitle];
}

- (void)createPost
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    DHBBlog *tempBlog = [appDelegate.settings.blogs objectAtIndex:appDelegate.settings.selectedBlog];
    
    [self.parentViewController editBlogPost:[tempBlog createDraftWithTitle:self.txtTitle.text]];
    
    [self removeFromSuperview];
}

- (void)createMedia
{
    [self.parentViewController finishSavingMedia];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
