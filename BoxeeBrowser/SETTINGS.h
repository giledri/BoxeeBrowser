//
//  SETTINGS.h
//  BoxeeBrowser
//
//  Created by John Doe on 5/16/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SETTINGS : NSManagedObject

@property (nonatomic, retain) NSString * ipAddress;
@property (nonatomic, retain) NSNumber * moviesFilter;
@property (nonatomic, retain) NSNumber * moviesOrder;
@property (nonatomic, retain) NSNumber * showsFilter;
@property (nonatomic, retain) NSNumber * showsOrder;

@end
