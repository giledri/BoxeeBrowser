//
//  BBSortViewController.m
//  BoxeeBrowser
//
//  Created by John Doe on 5/10/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBSortViewController.h"

@interface BBSortViewController ()

@end

@implementation BBSortViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CALayer *layer = self.tableView.layer;
    layer.borderWidth = 4;
    layer.borderColor = [self.tableView.viewForBaselineLayout.tintColor CGColor];
    layer.cornerRadius = 12;
    layer.masksToBounds = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.delegate changeSortOrder:cell.reuseIdentifier.intValue];
}

@end
