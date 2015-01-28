//
//  BBShowsTableViewController.m
//  BoxeeBrowser
//
//  Created by John Doe on 5/15/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBShowsTableViewController.h"


@interface BBShowsTableViewController ()

@end

@implementation BBShowsTableViewController


- (void)awakeFromNib
{
    self.cellTemplaceToUse = @"Show Item";
    
    [super awakeFromNib];
}

-(BBFilter)defaultFilter
{
    return UnwatchedShows;
}

-(BBFilter)readFilterAttribute
{
    return [self.appDelegate readIntegerAttribute:showsFilter withDefaultValue:self.defaultFilter];
}

-(BBOrder)readOrderAttribute
{
    return [self.appDelegate readIntegerAttribute:showsOrder withDefaultValue:DateAddedNewestFirst];
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

@end
