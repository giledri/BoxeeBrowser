//
//  BBMediaTableViewController.h
//  BoxeeBrowser
//
//  Created by John Doe on 5/24/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBDetailViewController.h"
#import "BBDataSource.h"
#import "BBSortViewController.h"
#import "BBDetailViewController.h"
#import "BBAppDelegate.h"

@interface BBMediaTableViewController : BBDetailViewController <BBDataSourceDelegate,BBSortViewDelegate>

@property (strong, nonatomic)BBAppDelegate* appDelegate;
@property (strong, nonatomic)BBDataSource* dataSource;

@property (nonatomic)BBFilter defaultFilter;
@property (strong, nonatomic)NSString* cellTemplaceToUse;

-(BBFilter)readFilterAttribute;
-(BBOrder)readOrderAttribute;
-(void)storeFilterAttribute:(BBFilter)filter;
-(void)storeOrderAttribute:(BBOrder)order;

-(NSArray*)itemsFromDataSource;

-(void)updateTitleWithCount:(NSInteger)count;

@end
