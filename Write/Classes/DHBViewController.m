//
//  DHBViewController.m
//  Write
//
//  Created by David Brunow on 4/21/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBViewController.h"
#import "DHBAppDelegate.h"
#import "DHBBlog.h"
#import "DHBBlogViewController.h"
#import "DHBSignatureView.h"

@implementation DHBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [self setTitle:@"Connect to Dropbox"];
	// Do any additional setup after loading the view.
    CGRect tableViewFrame = [[UIScreen mainScreen] bounds];
    //if ([self.navigationController isNavigationBarHidden]) {
    tableViewFrame.origin.y += 60;
    
    NSLog(@"Nav Bar Height: %f", self.navigationController.navigationBar.frame.size.height);
    
    //} else {
    //    tableViewFrame.size.height = [[UIScreen mainScreen] bounds].size.height - self.navigationController.navigationBar.bounds.size.height;
    //}
    
    [self.view setFrame:tableViewFrame];
    
    tableViewFrame.size.height = [[UIScreen mainScreen] bounds].size.height + self.navigationController.navigationBar.frame.size.height - 130;

    self.blogsTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
    
    [self.blogsTableView setBackgroundColor:[UIColor clearColor]];
    //[self.blogsTableView setSeparatorColor:self.darkTextColor];
    [self.blogsTableView setDelegate:self];
    [self.blogsTableView setDataSource:self];
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nextButton addTarget:self action:@selector(loadMainView) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton setTitle:@"Next" forState:(UIControlStateNormal)];
    [self.nextButton setTitle:@"Next" forState:UIControlStateDisabled];
    
    if(appDelegate.settings.blogs.count == 0) {
        [self.nextButton setEnabled:NO];
    }
    [self.nextButton setFrame:CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 100, 80, 40)];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitle:@"Cancel" forState:(UIControlStateNormal)];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateDisabled];
    
    [self.cancelButton setFrame:CGRectMake(self.view.frame.size.width - 300, self.view.frame.size.height - 100, 80, 40)];
    
    DHBSignatureView *signature = [[DHBSignatureView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 130, self.view.frame.size.width, 130)];
    
    [self.view addSubview:signature];
    
    [self.view addSubview:self.blogsTableView];
    [self.view addSubview:self.nextButton];
    [self.view addSubview:self.cancelButton];
    [self.view bringSubviewToFront:self.nextButton];

    [appDelegate.dropBox addObserver:self forKeyPath:@"hasFinishedLoading" options:NSKeyValueObservingOptionNew context:nil];
    [appDelegate.dropBox.restClient loadMetadata:@"/"];
}

-(void)loadMainView
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    [appDelegate.dropBox removeObserver:self forKeyPath:@"hasFinishedLoading"];
    [appDelegate.settings saveBlogs];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    if([appDelegate.dropBox.blogOptions count] > 0) {
        [self.blogsTableView reloadData];
        NSArray *navBarItems = [[NSArray alloc] initWithObjects:self.nextButton, nil];
        [self.navigationItem setRightBarButtonItems:navBarItems animated:YES];
    } else {
        //#TODO: Handle no sites being found
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//TableView Delegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSString *header = @"I found the following locations in your Dropbox that look like they could be websites powered by Magneto.\n\nWhich would you like to add?";
    
    if([appDelegate.dropBox.blogOptions count] == 0) {
        header = @"Looking for websites powered by Magneto...";
    }
    
    return header;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    return [appDelegate.dropBox.blogOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blogCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blogCell"];
    }
    
    NSString *cellLabel = @"";
    
    //cell.textLabel.textColor = self.lightTextColor;
    cellLabel = [[appDelegate.dropBox.blogOptions objectAtIndex:indexPath.row] valueForKey:@"path"];
    cell.textLabel.text = [cellLabel lowercaseString];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0]];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.textLabel setNumberOfLines:0];
    
    DHBBlog *tempBlog = [[DHBBlog alloc] initWithPath:[[appDelegate.dropBox.blogOptions objectAtIndex:indexPath.row] valueForKey:@"path"]];
    
    if([appDelegate.settings.blogs containsObject:tempBlog]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    //UIView *bgColorView = [[UIView alloc] init];
    //[bgColorView setBackgroundColor:self.darkTextColor];
    //[cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    DHBBlog *blog = [[DHBBlog alloc] initWithPath:[[appDelegate.dropBox.blogOptions objectAtIndex:indexPath.row] valueForKey:@"path"]];
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO];
    
    if([appDelegate.settings.blogs containsObject:blog]) {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
        [appDelegate.settings.blogs removeObject:blog];
    } else {
        [appDelegate.settings.blogs addObject:blog];
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    if (appDelegate.settings.blogs.count == 0) {
        [self.nextButton setEnabled:NO];
    } else {
        [self.nextButton setEnabled:YES];
    }
}



@end
