//
//  BBSortViewController.h
//  BoxeeBrowser
//
//  Created by John Doe on 5/10/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBSortViewDelegate <NSObject>

-(void) changeSortOrder:(int) order;

@end

@interface BBSortViewController : UITableViewController

@property (strong, nonatomic)id <BBSortViewDelegate>delegate;

@end
