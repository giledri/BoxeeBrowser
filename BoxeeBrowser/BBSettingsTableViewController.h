//
//  BBSettingsTableViewController.h
//  BoxeeBrowser
//
//  Created by John Doe on 5/13/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBDetailViewController.h"
#import "BBDataSource.h"

@interface BBSettingsTableViewController : BBDetailViewController <UITextFieldDelegate, BBDataSourceDelegate>

@end
