//
//  BBAppDelegate.h
//  BoxeeBrowser
//
//  Created by John Doe on 5/1/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBDataSource.h"
#import "BBDataSource.h"

@interface BBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (strong, nonatomic) BBDataSource *dataSource;


extern const NSString* moviesFilter;
extern const NSString* moviesOrder;
extern const NSString* showsFilter;
extern const NSString* showsOrder;
extern const NSString* settingsIpAddress;
extern const NSString* settingsLastSyncTime;
extern const NSString* settingsSyncOnStatup;


-(void) storeAttribute:(const NSString*)attribute withIntegerValue:(int)value;

-(void) storeAttribute:(const NSString*)attribute withStringValue:(NSString*)value;

-(int) readIntegerAttribute:(const NSString*)attribute withDefaultValue:(int)defaultValue;

-(NSString*) readStringAttribute:(const NSString*)attribute withDefaultValue:(NSString*)defaultValue;

@end
