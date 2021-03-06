//
//  BBMediaTableViewController.m
//  BoxeeBrowser
//
//  Created by John Doe on 5/24/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBMediaTableViewController.h"
#import "BBMovieTableViewCell.h"
#import "BBShowTableViewCell.h"
#import "BBMediaItem.h"
#import "BBMovieDetailsViewController.h"
#import "BBSortViewController.h"
#import "BBBarTextField.h"

@interface BBMediaTableViewController ()


@property (nonatomic)CGFloat cellHeight;

@property (nonatomic)BBFilter filter;
@property (strong, nonatomic) UIBarButtonItem* filterButton;
@property (nonatomic)BOOL isInitialFilter;
@property (strong, nonatomic) BBBarTextField *searchTextField;

@property (strong, nonatomic) UIPopoverController *sortPopover;

@property (nonatomic)CGPoint selectedScrollPosition;

@end

@implementation BBMediaTableViewController

#pragma mark - abstract implementations

-(BBFilter)defaultFilter
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

-(BBFilter)readFilterAttribute
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

-(BBOrder)readOrderAttribute
{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

-(void)storeFilterAttribute:(BBFilter)filter
{
    [self doesNotRecognizeSelector:_cmd];
}

-(void)storeOrderAttribute:(BBOrder)order
{
    [self doesNotRecognizeSelector:_cmd];
}

-(NSArray*)itemsFromDataSource
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - do your stuff

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (BBAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (self.dataSource == nil)
    {
        self.isInitialFilter = true;
        self.filter =  [self readFilterAttribute];
        BBOrder order = [self readOrderAttribute];
        
        self.dataSource = self.appDelegate.dataSource;
        [self.dataSource prepareForDelegate:self withFilter:self.filter andOrder:order];
    }
    
    self.filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:(self.filter == self.defaultFilter ? @"button-watched.png" : @"button-unwatched.png")] style:UIBarButtonItemStylePlain target:self action:@selector(filterButtonClicked:)];
    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button-sort.png"] style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonClicked:)];
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button-search.png"] style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonClicked:)];
    
    self.searchTextField = [[BBBarTextField alloc] initWithSize:CGSizeMake(170,40) andTintColor:self.tableView.tintColor];
    [self.searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    UIBarButtonItem *searchBox = [[UIBarButtonItem alloc] initWithCustomView:self.searchTextField];
    
    UIBarButtonItem *dummyButton = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 40)]];
    
    self.navigationItem.rightBarButtonItems  = [NSArray arrayWithObjects:sortButton, self.filterButton, searchButton, searchBox, dummyButton, nil];
    
    [self.navigationItem.titleView setContentMode:UIViewContentModeCenter];
    
    NSInteger count = 0;
    NSInteger sectionsCount = [self.tableView numberOfSections];
    for(int section = 0; section < sectionsCount; section++ )
    {
        count += [self.tableView numberOfRowsInSection:section];
    }
    [self updateTitleWithCount:count];
    
    [self.dataSource updateView];
}


-(void)textFieldDidChange:(id) sender
{
    if (sender == self.searchTextField)
    {
        NSString* searchText = self.searchTextField.text;
        
        self.dataSource.searchText = searchText;
        [self.dataSource updateView];
    }
}

-(void)searchButtonClicked:(id) sender
{
    [self.searchTextField setHidden:![self.searchTextField isHidden]];

    if ([self.searchTextField isHidden])
    {
        self.dataSource.searchText = self.searchTextField.text = @"";
        [self.searchTextField resignFirstResponder];
        [self.dataSource updateView];
    }
    else
    {
        [self.searchTextField becomeFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{   
    return YES;
}

- (void)filterButtonClicked:(id) sender
{
    self.isInitialFilter = false;
    
    UIBarButtonItem* filterButton = (UIBarButtonItem*)sender;
    
    switch (self.filter) {
        case AllMovies:
            self.filter = UnwatchedMovies;
            filterButton.image = [UIImage imageNamed:@"button-watched.png"];
            break;
        case UnwatchedMovies:
            self.filter = AllMovies;
            filterButton.image = [UIImage imageNamed:@"button-unwatched.png"];
            break;
        case AllShows:
            self.filter = UnwatchedShows;
            filterButton.image = [UIImage imageNamed:@"button-watched.png"];
            break;
        case UnwatchedShows:
            self.filter = AllShows;
            filterButton.image = [UIImage imageNamed:@"button-unwatched.png"];
            break;
        default:
            filterButton.image = nil;
    }
    
    [self storeFilterAttribute:self.filter];
    
    self.dataSource.filter = self.filter;
    [self.dataSource updateView];
}

- (void)sortButtonClicked:(id) sender
{
    UIStoryboard *storyboard = [self storyboard];
    BBSortViewController* sortController = [storyboard instantiateViewControllerWithIdentifier:@"SortController"];
    sortController.delegate = self;
    
    if (self.sortPopover == nil)
    {
        self.sortPopover = [[UIPopoverController alloc] initWithContentViewController:sortController];
    }
    
    [self.sortPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (NSString *)filterName
{
    NSString *filterName;
    switch (self.filter) {
        case AllMovies:
            filterName = @"All Movies";
            break;
        case UnwatchedMovies:
            filterName = @"Unwatched";
            break;
        case AllShows:
            filterName = @"All Shows";
            break;
        case UnwatchedShows:
            filterName = @"Unwatched";
            break;
        default:
            filterName = @"Error!!!";
    }
    return filterName;
}

- (void)updateTitleWithCount:(NSInteger)count
{
    NSString* filterName = [self filterName];
    
    self.title = filterName;
    if (count > 0)
    {
        self.title = [NSString stringWithFormat:@"%@ - %li items", filterName, (long)count];
    }
    
    [self.navigationController setTitle:self.title];
}

- (void) databaseDidSync
{
}

-(void)reloadData
{
    //[self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.tableView reloadData];

    if (self.isInitialFilter
        && ([self.tableView numberOfSections] == 0 || [self.tableView numberOfRowsInSection:0] == 0)
        && ((self.filter == UnwatchedMovies && [self.dataSource.movies count] > 0) ||
            (self.filter == UnwatchedShows && [self.dataSource.shows count] > 0)))
    {
        [self filterButtonClicked:self.filterButton];
    }
}

-(void) changeSortOrder:(int) order
{
    [self storeOrderAttribute:order];
    
    self.dataSource.order = order;
    
    [self.dataSource updateView];
    
    [self.sortPopover dismissPopoverAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [self itemsFromDataSource].count;
    
    [self updateTitleWithCount:count];
    
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = self.cellTemplaceToUse;
    BBMediaTableViewCell *cell = [self.tableView  dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    cell.dataSource = self.dataSource;
    cell.mediaItem = [[self itemsFromDataSource] objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 214;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PushMovieDetails"])
    {
        if ([segue.destinationViewController isKindOfClass:[BBMovieDetailsViewController class]])
        {
            BBMovieDetailsViewController *mediaVC = (BBMovieDetailsViewController *)segue.destinationViewController;
            mediaVC.mediaItem =  ((BBMovieTableViewCell*)sender).mediaItem;
            self.selectedScrollPosition = self.tableView.contentOffset;
        }
    }
    else if ([segue.identifier isEqualToString:@"PushShowDetails"])
    {
        if ([segue.destinationViewController isKindOfClass:[BBMovieDetailsViewController class]])
        {
            BBMovieDetailsViewController *mediaVC = (BBMovieDetailsViewController *)segue.destinationViewController;
            mediaVC.mediaItem =  ((BBShowTableViewCell*)sender).mediaItem;
            self.selectedScrollPosition = self.tableView.contentOffset;
        }
    }
}

@end
