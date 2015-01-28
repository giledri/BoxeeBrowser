//
//  BBVideoItem.m
//  BoxeeBrowser
//
//  Created by John Doe on 4/29/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBMediaItem.h"
#import "BBAppDelegate.h"

@interface BBMediaItem()

@end

@implementation BBMediaItem

-(id) copyWithZone: (NSZone *) zone
{
    BBMediaItem *copy = [[BBMediaItem allocWithZone: zone] init];
    
    copy.strBoxeeId = self.strBoxeeId;
    copy.strSeriesId = self.strSeriesId;
    copy.idVideo = self.idVideo;
    copy.idFile = self.idFile;
    copy.strPath = self.strPath;
    copy.strTitle = self.strTitle;
    copy.iDuration = self.iDuration;
    copy.strDescription = self.strDescription;
    copy.strExtDescription = self.strExtDescription;
    copy.strCover = self.strCover;
    copy.imageData = [self.imageData copy];
    copy.iRating = self.iRating;
    copy.iRTCriticsScore = self.iRTCriticsScore;
    copy.iYear = self.iYear;
    copy.strIMDBKey = self.strIMDBKey;
    
    copy.strDirector = self.strDirector;
    copy.strCast = self.strCast;
    
    copy.dateAdded = self.dateAdded;
    
    copy.isWatched = self.isWatched;
    
    //copy.isModified = self.isModified;
    //copy.isDeleted = self.isDeleted;
    
    return copy;
}

- (BBMediaItem*) initWithBoxeeId:(NSString*)strBoxeeId andSeriesId:(NSString*)strSeriesId
{
    self = [super init];
    
    self.strBoxeeId = strBoxeeId;
    self.strSeriesId = strSeriesId;
    
    return self;
}

- (NSString*) movieDetails
{
    return [NSString stringWithFormat:@"%ld minutes • %ld", self.iDuration / 60, (long)self.iYear];
}

- (BOOL) isRotten
{
    return (self.iRTCriticsScore <= 60);
}

@end
