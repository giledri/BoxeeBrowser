//
//  BBMasterViewController.m
//  BoxeeBrowser
//
//  Created by John Doe on 5/1/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBMasterViewController.h"
#import "BBSettingsTableViewController.h"

@interface BBMasterViewController ()

@end

@implementation BBMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
   
    [self.splitViewController setDelegate:self];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor blackColor]];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Split View Delegate
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    UINavigationController *navController = [[[self splitViewController ] viewControllers ] lastObject ];
    BBDetailViewController *vc = [[navController viewControllers] firstObject];
    
    [vc setSplitViewButton:barButtonItem forPopoverController:popoverController];
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    UINavigationController *navController = [[[self splitViewController ] viewControllers ] lastObject ];
    BBDetailViewController *vc = [[navController viewControllers] firstObject];
    
    [vc setSplitViewButton:nil forPopoverController:nil];
}

#pragma mark - Table View
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0 && indexPath.row > 1) ||
        (indexPath.section == 1 && indexPath.row > 0) ||
        indexPath.section > 1)
    {
        return nil;
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UIStoryboard *storyboard = [self storyboard];
        BBDetailViewController *newController = nil;
        
        switch (indexPath.section)
        {
            case 0:
                switch (indexPath.row)
                {
                    case 0:
                        newController = [storyboard instantiateViewControllerWithIdentifier:@"MoviesController"];
                        break;
                    case 1:
                        newController = [storyboard instantiateViewControllerWithIdentifier:@"ShowsController"];
                        break;
                    default:
                        return;
                }
                break;
            case 1:
                newController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsController"];
                break;
            default:
                return;
        }
        
        // now set this to the navigation controller
        UINavigationController *navController = [[[self splitViewController ] viewControllers ] lastObject ];
        BBDetailViewController *oldController = [[navController viewControllers] firstObject];
        
        NSArray *newStack = [NSArray arrayWithObjects:newController, nil ];
        [navController setViewControllers:newStack];
        
        UIBarButtonItem *splitViewButton = [[oldController navigationItem] leftBarButtonItem];
        UIPopoverController *popoverController = [oldController masterPopoverController];
        [newController setSplitViewButton:splitViewButton forPopoverController:popoverController];
        
        // see if we should be hidden
        if (!UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            // we are in portrait mode so go away
            [popoverController dismissPopoverAnimated:YES];
        }
    }
}

@end
