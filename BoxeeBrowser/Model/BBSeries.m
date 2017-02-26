//
//  BBShow.m
//  BoxeeBrowser
//
//  Created by John Doe on 9/3/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBSeries.h"

@implementation BBSeries

-(id) copyWithZone: (NSZone *) zone
{
    BBSeries *copy = [[BBSeries allocWithZone: zone] init];
    
    copy.strSeriesId = self.strSeriesId;
    copy.strTitle = self.strTitle;
    copy.strDescription = self.strDescription;
    copy.strCover = self.strCover;
    copy.imageData = [self.imageData copy];
    copy.iYear = self.iYear;
    
    copy.shows = self.shows;
    
    return copy;
}

- (BBSeries*) initWithSeriesId:(NSString*)strSeriesId andSeriesTitle:(NSString *)strSeriesTitle
{
    self = [super init];
    
    self.strSeriesId = strSeriesId;
    self.strTitle = strSeriesTitle;
    self.shows = [[NSMutableDictionary alloc] init];
    
    return self;
}

@end
