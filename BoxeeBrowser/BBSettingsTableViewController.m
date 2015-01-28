//
//  BBSettingsTableViewController.m
//  BoxeeBrowser
//
//  Created by John Doe on 5/13/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBSettingsTableViewController.h"
#import "BBAppDelegate.h"
#include <arpa/inet.h>

@interface BBSettingsTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ipAddressLabel;
@property (weak, nonatomic) IBOutlet UITextField *ipAddress;
@property (weak, nonatomic) IBOutlet UILabel *lastSyncTime;
@property (weak, nonatomic) IBOutlet UISwitch *syncOnStartupSwitch;
@property (weak, nonatomic) IBOutlet UIButton *syncNowButton;

@property (strong, nonatomic)BBAppDelegate* appDelegate;

@end

@implementation BBSettingsTableViewController

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
    
    self.appDelegate = (BBAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        [self.ipAddress setDelegate:self];
        self.ipAddress.text = [self.appDelegate readStringAttribute:settingsIpAddress withDefaultValue:@"10.0.0.1"];
    }

    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            NSString* lasySyncTime = [self.appDelegate readStringAttribute:settingsLastSyncTime withDefaultValue:@"Never"];
        
            self.lastSyncTime.text = lasySyncTime;
        }
        else if (indexPath.row == 1)
        {
            BOOL syncOnStartup = [self.appDelegate readIntegerAttribute:settingsSyncOnStatup withDefaultValue:TRUE];
            self.syncOnStartupSwitch.on = syncOnStartup;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // enter closes the keyboard
    if ([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString* ipAddress = [self.appDelegate readStringAttribute:settingsIpAddress withDefaultValue:@"10.0.0.1"];
    
    if (![textField.text isEqualToString:ipAddress])
    {
        [self.appDelegate storeAttribute:settingsIpAddress withStringValue:textField.text];
        self.appDelegate.dataSource = [[BBDataSource alloc] initWithDelegate:self forceSyncDatabase:TRUE];
    }
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    const char *utf8 = [textField.text UTF8String];
    int success;
    
    struct in_addr dst;
    success = inet_pton(AF_INET, utf8, &dst);
    if (success != 1) {
        struct in6_addr dst6;
        success = inet_pton(AF_INET6, utf8, &dst6);
    }
    
    return (success == 1);
}

- (IBAction)syncOnStartupDidChange:(id)sender
{
    if (sender == self.syncOnStartupSwitch)
    {
        [self.appDelegate storeAttribute:settingsSyncOnStatup withIntegerValue:self.syncOnStartupSwitch.on];
    }
}

- (IBAction)synchNow:(id)sender
{
    if (sender == self.syncNowButton)
    {
        [self.syncNowButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [self.syncNowButton setEnabled:FALSE];
    
        self.appDelegate.dataSource = [[BBDataSource alloc] initWithDelegate:self forceSyncDatabase:TRUE];
    }
}

- (void) databaseDidSync
{
    [self.syncNowButton setEnabled:TRUE];	

    [self.tableView reloadData];
}

-(void)reloadData
{
}

@end
