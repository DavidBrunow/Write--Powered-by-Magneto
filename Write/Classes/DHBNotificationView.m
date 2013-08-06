//
//  DHBNotificationView.m
//  Write
//
//  Created by David Brunow on 7/16/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBNotificationView.h"
#import "DHBAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation DHBNotificationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setFrame:CGRectMake(0, -20, [[UIScreen mainScreen] bounds].size.width, 40)];
        //[self setBackgroundColor:[UIColor colorWithRed:241.0/255 green:147.0/255 blue:20.0/255 alpha:1.0]];
        //[self setBackgroundColor:[UIColor whiteColor]];
        
        self.notificationView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, [[UIScreen mainScreen] bounds].size.width, 20)];
        [self.notificationView setBackgroundColor:[UIColor orangeColor]];

        self.notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, 20)];
        [self.notificationLabel setTextAlignment:NSTextAlignmentCenter];
        [self.notificationLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
        [self.notificationLabel setText:@"Change this text"];
    }
    return self;
}

- (void)layoutSubviews
{
    [self addSubview:self.notificationView];
    [self.notificationView addSubview:self.notificationLabel];
}

- (void) displayNotification
{
    self.windowLevel = UIWindowLevelStatusBar+1.f;

    [self setHidden:NO];
    CGRect newFrame = self.frame;
    
    CGRect oldFrame = self.frame;
    
    newFrame.origin.y = oldFrame.origin.y + 20;
    
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.notificationView setFrame:newFrame];
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.25 delay:0.75 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [self.notificationView setFrame:oldFrame];
        } completion:^(BOOL finished) {
            [self setHidden:YES];
        }];
    } ];
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
