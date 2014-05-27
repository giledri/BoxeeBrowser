//
//  BBSplitViewButtonHandler.h
//  BoxeeBrowser
//
//  Created by John Doe on 5/14/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BBSplitViewButtonHandler

@property (nonatomic, strong) UIBarButtonItem *splitViewButton;

-(void)setSplitViewButton:(UIBarButtonItem *)splitViewButton forPopoverController:(UIPopoverController *)popoverController;

@end