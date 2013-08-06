//
//  DHBBlogPostsViewController.m
//  Write
//
//  Created by David Brunow on 5/13/13.
//  Copyright (c) 2013 David Brunow. All rights reserved.
//

#import "DHBBlogPostsViewController.h"
#import "DHBBlog.h"
#import "DHBBlogPost.h"
#import "DHBAppDelegate.h"
#import "DHBPostEditViewController.h"
#import "DHBTitleView.h"

@interface DHBBlogPostsViewController ()

@property (nonatomic, retain) DHBTitleView *postTitleView;
@property (nonatomic, strong) DHBPostEditViewController *editViewController;
@property (nonatomic, strong) DHBBlog *currentBlog;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation DHBBlogPostsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [self.navigationItem setHidesBackButton:NO];
    NSArray *segments = [[NSArray alloc] initWithObjects:@"Drafts", @"Posts", nil];

    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segments];
    [self.segmentedControl setFrame:CGRectMake((self.view.frame.size.width / 2) - 70, 30.0, 140, 25.0)];
    [self.segmentedControl setSelectedSegmentIndex:0];
    [self.segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.navigationItem setTitleView:[[UIView alloc] initWithFrame:CGRectZero]];
    self.title = [self.segmentedControl titleForSegmentAtIndex:self.segmentedControl.selectedSegmentIndex];
    
	// Do any additional setup after loading the view.
    CGRect tableViewFrame = [[UIScreen mainScreen] bounds];
    //if ([self.navigationController isNavigationBarHidden]) {
        tableViewFrame.size.height = [[UIScreen mainScreen] bounds].size.height;
    //} else {
        //tableViewFrame.size.height = [[UIScreen mainScreen] bounds].size.height - self.navigationController.navigationBar.bounds.size.height - 20;
    //}
    
    [self.view setFrame:tableViewFrame];
    self.blogPostsTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    
    [self.blogPostsTableView setBackgroundColor:[UIColor clearColor]];
    //[self.blogPostsTableView setSeparatorColor:self.darkTextColor];
    [self.blogPostsTableView setDelegate:self];
    [self.blogPostsTableView setDataSource:self];
    self.rightButton = [[UIBarButtonItem alloc] initWithTitle:@"New Draft" style:UIBarButtonItemStyleDone target:self action:@selector(newDraft)];
    [self.rightButton setEnabled:YES];
    NSArray *navBarItems = [[NSArray alloc] initWithObjects:self.rightButton, nil];
    [self.navigationItem setRightBarButtonItems:navBarItems animated:YES];
    
    [self.view addSubview:self.blogPostsTableView];
    
    self.currentBlog = [appDelegate.settings.blogs objectAtIndex:appDelegate.settings.selectedBlog];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.blogPostsTableView setFrame:[[UIScreen mainScreen] bounds]];
    [self.segmentedControl setFrame:CGRectMake((self.view.frame.size.width / 2) - 70, 30.0, 140, 25.0)];
    NSLog(@"Handling rotation");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate.dropBox addObserver:self forKeyPath:@"hasFinishedDownloading" options:NSKeyValueObservingOptionNew context:nil];
    [self.blogPostsTableView reloadData];

    [self.navigationController.view addSubview:self.segmentedControl];
    [self.rightButton setTitle:@"New Draft"];
    [self.rightButton setAction:@selector(newDraft)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    DHBAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate.dropBox removeObserver:self forKeyPath:@"hasFinishedDownloading"];
    
    [self.segmentedControl removeFromSuperview];
}

-(void) newDraft
{
    if(self.postTitleView == nil) {
        self.postTitleView = [[DHBTitleView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.postTitleView.lblTitle setText:@"Title:"];
        [self.postTitleView.btnFinish setTitle:@"Create Draft" forState:UIControlStateNormal];
        [self.postTitleView.btnFinish addTarget:self.postTitleView action:@selector(createPost) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.postTitleView setParentViewController:self];
    
    [self.rightButton setTitle:@"Cancel"];
    [self.rightButton setAction:@selector(cancelDraft)];
    
    [self.view addSubview:self.postTitleView];
}

-(void) cancelDraft
{
    [self.rightButton setTitle:@"New Draft"];
    [self.rightButton setAction:@selector(newDraft)];
    
    [self.postTitleView removeFromSuperview];
}

-(void) segmentedControlChanged: (UISegmentedControl *)segmentedControl
{
    self.title = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
    [self.blogPostsTableView reloadData];
    
    //Search cut from the initial release, will be considered later
    /*
    if(segmentedControl.selectedSegmentIndex == 1) {
        if(self.searchBar == nil) {
            self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        }
        
        self.searchBar.delegate = self;
        
        self.blogPostsTableView.tableHeaderView = self.searchBar;
    } else {
        self.blogPostsTableView.tableHeaderView = nil;
    }
     */
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"hasFinishedDownloading"]) {
        [self.blogPostsTableView reloadData];
    }
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
    
    for(DHBBlogPost *post in self.currentBlog.posts) {
        if(self.segmentedControl.selectedSegmentIndex == 0) {
            if([post isDraft]) {
                rowsInSection++;
            }
        } else if(self.segmentedControl.selectedSegmentIndex == 1) {
            if(![post isDraft]) {
                rowsInSection++;
            }
        }
    }
    
    return rowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blogCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blogCell"];
    }
    
    NSString *cellLabel = @"";
    
    //cell.textLabel.textColor = self.lightTextColor;
    NSMutableArray *localPosts = [[NSMutableArray alloc] init];
    for(DHBBlogPost *post in self.currentBlog.posts) {
        if(self.segmentedControl.selectedSegmentIndex == 0) {
            if([post isDraft]) {
                [localPosts addObject:post];
            }
        } else if(self.segmentedControl.selectedSegmentIndex == 1) {
            if(![post isDraft]) {
                [localPosts addObject:post];
            }
        }
    }
    
    cellLabel = [[localPosts objectAtIndex:indexPath.row] title];
    cell.textLabel.text = [cellLabel lowercaseString];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22.0]];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.textLabel setNumberOfLines:0];
    
    //UIView *bgColorView = [[UIView alloc] init];
    //[bgColorView setBackgroundColor:self.darkTextColor];
    //[cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *localPosts = [[NSMutableArray alloc] init];
    
    for(DHBBlogPost *post in self.currentBlog.posts) {
        if(self.segmentedControl.selectedSegmentIndex == 0) {
            if([post isDraft]) {
                [localPosts addObject:post];
            }
        } else if(self.segmentedControl.selectedSegmentIndex == 1) {
            if(![post isDraft]) {
                [localPosts addObject:post];
            }
        }
    }
    
    DHBBlogPost *post = [localPosts objectAtIndex:indexPath.row];
    
    if(!post.isFileDownloaded) {
        [post downloadDropboxFile];
    }
    
    [self editBlogPost:[localPosts objectAtIndex:indexPath.row]];
}

- (void) editBlogPost:(DHBBlogPost *) post
{
    self.editViewController = [[DHBPostEditViewController alloc] init];
    
    [self.editViewController setBlogPost:post];
    
    [self.segmentedControl removeFromSuperview];
    [self.navigationController pushViewController:self.editViewController animated:YES];
}


@end
