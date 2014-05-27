//
//  BBMoviesTableViewController.m
//  BoxeeBrowser
//
//  Created by John Doe on 5/13/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBMoviesTableViewController.h"
#import "BBMovieTableViewCell.h"
#import "BBAppDelegate.h"
#import "BBMediaItem.h"
#import "BBMovieDetailsViewController.h"
#import "BBSortViewController.h"

@interface BBMoviesTableViewController ()

@end

@implementation BBMoviesTableViewController

-(BBFilter)defaultFilter
{
    return UnwatchedMovies;
}

-(BBFilter)readFilterAttribute
{
    return [self.appDelegate readIntegerAttribute:moviesFilter withDefaultValue:self.defaultFilter];
}

-(BBOrder)readOrderAttribute
{
    return [self.appDelegate readIntegerAttribute:moviesOrder withDefaultValue:DateAddedNewestFirst];
}

-(void)storeFilterAttribute:(BBFilter)filter
{
    [self.appDelegate storeAttribute:moviesFilter withIntegerValue:(int)filter];
}

-(void)storeOrderAttribute:(BBOrder)order
{
    [self.appDelegate storeAttribute:moviesOrder withIntegerValue:order];
}

-(NSArray*)itemsFromDataSource
{
    return self.dataSource.movies;
}

@end
