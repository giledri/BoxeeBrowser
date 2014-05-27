//
//  BBDetailsViewControllerBase.h
//  BoxeeBrowser
//
//  Created by John Doe on 5/14/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSplitViewButtonHandler.h"

@interface BBDetailViewController : UITableViewController <BBSplitViewButtonHandler>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end
