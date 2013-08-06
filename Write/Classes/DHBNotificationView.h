//
//  DHBNotificationView.h
//  Write
//
//  Created by David Brunow on 7/16/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHBNotificationView : UIWindow

@property (nonatomic, retain) UIView *notificationView;
@property (nonatomic, retain) UILabel *notificationLabel;

- (void) displayNotification;

@end
