//
//  BBShow.h
//  BoxeeBrowser
//
//  Created by John Doe on 9/3/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSeries : NSObject <NSCopying>

@property (strong, nonatomic) NSString *strSeriesId;
@property (strong, nonatomic) NSString *strTitle;
@property (strong, nonatomic) NSString *strDescription; // seconds
@property (strong, nonatomic) NSString *strCover; // image path
@property (strong, nonatomic) NSData *imageData;
@property (nonatomic) int iYear;

@property (strong, nonatomic) NSMutableDictionary *shows;

- (BBSeries*) initWithSeriesId:(NSString*)strSeriesId;

@end
