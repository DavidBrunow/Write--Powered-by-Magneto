//
//  DHBPostEditViewController.m
//  Write
//
//  Created by David Brunow on 5/15/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBPostEditViewController.h"
#import "DHBMedia.h"
#import "DHBBlog.h"
#import "DHBAppDelegate.h"
#import "DHBTitleView.h"
#import "DHBNotificationView.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface DHBPostEditViewController ()

@property (nonatomic, retain) DHBTitleView *imageTitleView;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic) float keyboardHeight;
@property (nonatomic, retain) NSTimer *globalTimer;
@property (nonatomic, retain) DHBNotificationView *postNotification;
@property (nonatomic) CGSize kbSize;
@property (nonatomic, retain) DHBMedia *blogPostMedia;

@end

@implementation DHBPostEditViewController

- (id)init
{
    self.blogPost = [[DHBBlogPost alloc] init];
    [self registerForKeyboardNotifications];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(postDraft)];
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(savePost)];
    [self.saveButton setEnabled:YES];
    self.photoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(loadPhoto)];
    UIBarButtonItem *whiteSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.dismissKeyboardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
    
    if([self.blogPost isDraft]) {
        NSArray *navBarItems = [[NSArray alloc] initWithObjects:self.postButton, nil];
        [self.navigationItem setRightBarButtonItems:navBarItems animated:YES];
    } else {
        [self setIsEditingPost:YES];
    }
    
    self.editBlogPost = [[UITextView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].origin.x, [[UIScreen mainScreen] bounds].origin.y, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - self.navigationController.navigationBar.frame.size.height - 20)];
    [self.editBlogPost setDelegate:self];
    [self.editBlogPost setFont:[UIFont fontWithName:@"Courier" size:14.0]];
    [self.editBlogPost setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width - 20, [[UIScreen mainScreen] bounds].size.height)];
    
    UIToolbar* editToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    editToolbar.barStyle = UIBarStyleBlackTranslucent;
    editToolbar.items = [NSArray arrayWithObjects: self.photoButton, whiteSpaceButton, self.saveButton, whiteSpaceButton, self.dismissKeyboardButton, nil];
    [editToolbar sizeToFit];
    [self.editBlogPost setKeyboardAppearance:UIKeyboardAppearanceAlert];
    [self.editBlogPost setInputAccessoryView:editToolbar];
    
    if(self.blogPost.isFileDownloaded) {
        [self setText];
    } else {
        [self.blogPost addObserver:self forKeyPath:@"isFileDownloaded" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    
    [self setTitle:self.blogPost.title];
    
    [self.view addSubview:self.editBlogPost];
}

-(void)viewDidAppear:(BOOL)animated
{
}

-(void)viewWillDisappear:(BOOL)animated
{

    if(self.blogPost.isDraft && self.editBlogPost.text.length > 0) {
        [self savePost];
    }
    
    [super viewWillDisappear:animated];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"isFileDownloaded"]) {
        [self setText];
        [self.blogPost removeObserver:self forKeyPath:@"isFileDownloaded"];
    } else if([keyPath isEqualToString:@"rev"] && (self.blogPost.isDraft || self.isEditingPost)) {
        [self.saveButton setTitle:@"Saved!"];
        self.globalTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(restoreSaveButton) userInfo:nil repeats:NO];
        [self.blogPost removeObserver:self forKeyPath:@"rev"];
        
    } else if([keyPath isEqualToString:@"rev"] && !self.blogPost.isDraft && !self.isEditingPost) {
        [self.navigationController popViewControllerAnimated:YES];
        [self.blogPost removeObserver:self forKeyPath:@"rev"];
    }
}

- (void) setText
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    fileManager = [NSFileManager defaultManager];
    NSData *dataBuffer = [[NSData alloc] init];
    dataBuffer = [fileManager contentsAtPath:self.blogPost.localPath];
    NSString *dataString = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
    [self.editBlogPost setText:dataString];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    self.kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.kbSize.height + self.editBlogPost.inputAccessoryView.frame.size.height, 0.0);
    self.editBlogPost.contentInset = contentInsets;
    self.editBlogPost.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= self.kbSize.height;
    
    
    if ([self.editBlogPost caretRectForPosition:self.editBlogPost.selectedTextRange.start].origin.y > [self.editBlogPost caretRectForPosition:self.editBlogPost.endOfDocument].origin.y - self.kbSize.height &&  [self.editBlogPost caretRectForPosition:self.editBlogPost.endOfDocument].origin.y - self.kbSize.height > 0) {
        CGPoint scrollPoint = CGPointMake(0.0, [self.editBlogPost caretRectForPosition:self.editBlogPost.endOfDocument].origin.y + [self.editBlogPost caretRectForPosition:self.editBlogPost.endOfDocument].size.height + self.editBlogPost.inputAccessoryView.frame.size.height - self.kbSize.height);
        [UIView animateWithDuration:.25 animations:^{
            self.editBlogPost.contentOffset = scrollPoint;
        }];
        //[self.editBlogPost setContentOffset:scrollPoint animated:NO];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    [textView scrollRangeToVisible:[textView selectedRange]];
    if ([self.editBlogPost caretRectForPosition:self.editBlogPost.selectedTextRange.start].origin.y > [self.editBlogPost caretRectForPosition:self.editBlogPost.endOfDocument].origin.y - self.kbSize.height &&  [self.editBlogPost caretRectForPosition:self.editBlogPost.endOfDocument].origin.y - self.kbSize.height > 0) {
        CGPoint scrollPoint = CGPointMake(0.0, [self.editBlogPost caretRectForPosition:self.editBlogPost.endOfDocument].origin.y + [self.editBlogPost caretRectForPosition:self.editBlogPost.endOfDocument].size.height + self.editBlogPost.inputAccessoryView.frame.size.height - self.kbSize.height);
        [UIView animateWithDuration:.25 animations:^{
            self.editBlogPost.contentOffset = scrollPoint;
        }];
        //[self.editBlogPost setContentOffset:scrollPoint animated:NO];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.editBlogPost.contentInset = contentInsets;
    self.editBlogPost.scrollIndicatorInsets = contentInsets;
}

-(void)postDraft
{
    [self.blogPost postDraftWithContents:self.editBlogPost.text];
    [self.blogPost addObserver:self forKeyPath:@"rev" options:NSKeyValueObservingOptionNew context:nil];
    
    self.postNotification = [[DHBNotificationView alloc] initWithFrame:CGRectZero];
    [self.postNotification.notificationLabel setText:@"Posted!"];
    self.postNotification.screen = [UIScreen mainScreen];
    
    [self.postNotification displayNotification];
}

-(void)dismissKeyboard
{
    [self.editBlogPost endEditing:YES];
}

-(void)loadPhoto
{
    self.imagePickerController = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self.imagePickerController setAllowsEditing:YES];
        self.imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePickerController.sourceType];
        
        [self.imagePickerController setDelegate:self];
        
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.mediaInfo = info;
    NSString *mediaType = [self.mediaInfo objectForKey: UIImagePickerControllerMediaType];
    
    if(self.imageTitleView == nil) {
        self.imageTitleView = [[DHBTitleView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.imageTitleView.lblTitle setText:@"Alternate Text:"];
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
            [self.imageTitleView.btnFinish setTitle:@"Add Image" forState:UIControlStateNormal];
        } else {
            [self.imageTitleView.btnFinish setTitle:@"Add Video" forState:UIControlStateNormal];
        }
        [self.imageTitleView.btnFinish addTarget:self.imageTitleView action:@selector(createMedia) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.imageTitleView setParentViewController:self];
    
    [self.view addSubview:self.imageTitleView];
}

- (void)finishSavingMedia
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    DHBBlog *tempBlog = [appDelegate.settings.blogs objectAtIndex:appDelegate.settings.selectedBlog];
    
    NSString *mediaType = [self.mediaInfo objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [self.mediaInfo objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [self.mediaInfo objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        
        self.blogPostMedia = [[DHBMedia alloc] initWithTitle:self.imageTitleView.txtTitle.text andMedia:imageToUse andBlog:tempBlog];
        
        [self.editBlogPost insertText:self.blogPostMedia.codeTag];
        
    }
    
    // Handle a movie picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
        NSURL *movieURL = [self.mediaInfo objectForKey:UIImagePickerControllerMediaURL];
        
        self.blogPostMedia = [[DHBMedia alloc] initWithTitle:self.imageTitleView.txtTitle.text andMedia:movieURL andBlog:tempBlog];
        
        [self.editBlogPost insertText:self.blogPostMedia.codeTag];
    }
    
    [self.imageTitleView removeFromSuperview];

    //[self.navigationController popViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Canceling image picker");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)savePost
{
    [self.blogPost saveWithContents:self.editBlogPost.text];
    [self.blogPost addObserver:self forKeyPath:@"rev" options:NSKeyValueObservingOptionNew context:nil];

    [self.saveButton setTitle:@"Saving..."];
}

-(void) restoreSaveButton
{
    [self.saveButton setTitle:@"Save"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
