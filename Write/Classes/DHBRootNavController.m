//
//  DHBRootNavController.m
//  Write
//
//  Created by David Brunow on 4/21/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBRootNavController.h"
#import "DHBAppDelegate.h"

@implementation DHBRootNavController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
    self.blogsViewController = [[DHBBlogViewController alloc] init];
    
    [self pushViewController:self.blogsViewController animated:YES];
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.dropBox connectToDropBox];

    if(appDelegate.settings.blogs.count == 0) {
        self.blogListViewController = [[DHBViewController alloc] init];
        
        [self presentViewController:self.blogListViewController animated:YES completion:nil];
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
