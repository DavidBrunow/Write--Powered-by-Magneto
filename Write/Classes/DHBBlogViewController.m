//
//  DHBBlogsViewController.m
//  Write
//
//  Created by David Brunow on 5/13/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBBlogViewController.h"
#import "DHBBlogPostsViewController.h"
#import "DHBBlog.h"
#import "DHBBlogPost.h"
#import "DHBAppDelegate.h"
#import "DHBPostEditViewController.h"
#import "DHBTitleView.h"

@interface DHBBlogViewController ()

@property (nonatomic, strong) NSMutableArray *allBlogs;
@property (nonatomic, strong) DHBBlogPostsViewController *blogPostsViewController;
@property (nonatomic, strong) DHBViewController *blogListViewController;

@end

@implementation DHBBlogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.allBlogs = appDelegate.settings.blogs;
    
    [self.navigationItem setHidesBackButton:YES];
    
    self.title = @"Sites";
    
    CGRect tableViewFrame = [[UIScreen mainScreen] bounds];
    //if ([self.navigationController isNavigationBarHidden]) {
    tableViewFrame.size.height = [[UIScreen mainScreen] bounds].size.height;
    //} else {
    //tableViewFrame.size.height = [[UIScreen mainScreen] bounds].size.height - self.navigationController.navigationBar.bounds.size.height - 20;
    //}
    
    [self.view setFrame:tableViewFrame];
    self.blogsTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    
    [self.blogsTableView setBackgroundColor:[UIColor clearColor]];

    [self.blogsTableView setDelegate:self];
    [self.blogsTableView setDataSource:self];
    self.rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Site" style:UIBarButtonItemStyleDone target:self action:@selector(addBlog)];
    [self.rightButton setEnabled:YES];
    NSArray *navBarItems = [[NSArray alloc] initWithObjects:self.rightButton, nil];
    [self.navigationItem setRightBarButtonItems:navBarItems animated:YES];
    
    [self.view addSubview:self.blogsTableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [self.blogsTableView reloadData];
    
    [self.rightButton setTitle:@"Add Site"];
    [self.rightButton setAction:@selector(addBlog)];
    
    for(DHBBlog *blog in self.allBlogs) {
        [blog downloadDropboxFiles];
    }

    if(appDelegate.settings.isInitialLaunch && appDelegate.settings.selectedBlog != -1) {
        NSIndexPath *selectedPath = [NSIndexPath indexPathForRow:appDelegate.settings.selectedBlog inSection:0];
        
        [self tableView:self.blogsTableView didSelectRowAtIndexPath:selectedPath];
        [appDelegate.settings setIsInitialLaunch:NO];
    }
}

-(void) addBlog
{
    [self.rightButton setTitle:@"Cancel"];
    [self.rightButton setAction:@selector(cancelAddBlog)];
    
    self.blogListViewController = [[DHBViewController alloc] init];
    
    [self.navigationController presentViewController:self.blogListViewController animated:YES completion:nil];
}

-(void) cancelAddBlog
{
    [self.rightButton setTitle:@"Add Site"];
    [self.rightButton setAction:@selector(addBlog)];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
}

//TableView Delegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header = @"";
    
    return header;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rowsInSection = 0;
    
    rowsInSection = self.allBlogs.count;

    return rowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blogCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blogCell"];
    }
    
    NSString *cellLabel = @"";
    
    DHBBlog *thisBlog = [self.allBlogs objectAtIndex:indexPath.row];
    cellLabel = thisBlog.path;
    
    cell.textLabel.text = [cellLabel lowercaseString];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22.0]];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.textLabel setNumberOfLines:0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.settings setSelectedBlog:indexPath.row];
    [appDelegate.settings setIsInitialLaunch:NO];
    
    self.blogPostsViewController = [[DHBBlogPostsViewController alloc] init];
    
    [self.navigationController pushViewController:self.blogPostsViewController animated:YES];
}



@end
