//
//  BBShowsTableViewController.m
//  BoxeeBrowser
//
//  Created by John Doe on 5/15/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBShowsTableViewController.h"
#import "BBShowTableViewCell.h"
#import "BBSeries.h"


@interface BBShowsTableViewController ()

@end

@implementation BBShowsTableViewController


- (void)awakeFromNib
{
    self.cellTemplaceToUse = @"Show Item";
    
    self.tableView.sectionHeaderHeight = 50;
    
    [super awakeFromNib];
}

-(BBFilter)defaultFilter
{
    return UnwatchedShows;
}

-(BBFilter)readFilterAttribute
{
    return (BBFilter)[self.appDelegate readIntegerAttribute:showsFilter withDefaultValue:self.defaultFilter];
}

-(BBOrder)readOrderAttribute
{
    return (BBOrder)[self.appDelegate readIntegerAttribute:showsOrder withDefaultValue:DateAddedNewestFirst];
}

-(void)storeFilterAttribute:(BBFilter)filter
{
    [self.appDelegate storeAttribute:showsFilter withIntegerValue:(int)filter];
}

-(void)storeOrderAttribute:(BBOrder)order
{
    [self.appDelegate storeAttribute:showsOrder withIntegerValue:order];
}

-(NSArray*)itemsFromDataSource
{
    return self.dataSource.shows;
}

-(NSArray*)seriesFromDataSource
{
    return self.dataSource.series;
}

-(NSDictionary*)showsBySeriesFromDataSource
{
    return self.dataSource.showsBySeries;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of series.
    return [self seriesFromDataSource].count;;
}

- (NSArray *)showsBySection:(NSInteger)section
{
    BBSeries *series = [[self seriesFromDataSource] objectAtIndex:section];
    NSDictionary *showsBySeries = [self showsBySeriesFromDataSource];
    NSArray *shows = [showsBySeries objectForKey:series.strSeriesId];
    return shows;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *shows = [self showsBySection:section];
    NSInteger count = shows.count;
    
    [self updateTitleWithCount:self.dataSource.shows.count];
    
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    BBSeries *series = [[self seriesFromDataSource] objectAtIndex:section];
    NSArray *shows = [self showsBySection:section];
    
    return [NSString stringWithFormat:@"%@ - %li shows", series.strTitle, shows.count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = self.cellTemplaceToUse;
    BBShowTableViewCell *cell = [self.tableView  dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    NSArray *shows = [self showsBySection:indexPath.section];
    
    cell.dataSource = self.dataSource;
    cell.mediaItem = [shows objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor blackColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:self.tableView.backgroundColor];
    [header.textLabel setFont:[UIFont fontWithDescriptor:header.textLabel.font.fontDescriptor size:20]];
    
    CALayer *layer = header.layer;
    layer.borderWidth = 4;
    layer.borderColor = [self.tableView.tintColor CGColor];
    layer.cornerRadius = 10;
    layer.masksToBounds = NO;
}

@end
