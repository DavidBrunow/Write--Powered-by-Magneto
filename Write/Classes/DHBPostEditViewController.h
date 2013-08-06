//
//  DHBPostEditViewController.h
//  Write
//
//  Created by David Brunow on 5/15/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHBBlogPost.h"

@interface DHBPostEditViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

@property (nonatomic, retain) DHBBlogPost *blogPost;
@property (nonatomic, retain) UITextView *editBlogPost;
@property (nonatomic, retain) UIBarButtonItem *saveButton;
@property (nonatomic, retain) UIBarButtonItem *postButton;
@property (nonatomic, retain) UIBarButtonItem *photoButton;
@property (nonatomic, retain) UIBarButtonItem *dismissKeyboardButton;
@property (nonatomic, retain) NSDictionary *mediaInfo;
@property (nonatomic) bool isEditingPost;

- (void)finishSavingMedia;

@end
