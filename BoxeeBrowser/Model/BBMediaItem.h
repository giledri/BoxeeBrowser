//
//  BBVideoItem.h
//  BoxeeBrowser
//
//  Created by John Doe on 4/29/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBMediaItem : NSObject <NSCopying>

@property (strong, nonatomic) NSString *strBoxeeId;
@property (strong, nonatomic) NSString *strSeriesId;
@property (nonatomic) int idVideo;
@property (nonatomic) int idFile;
@property (strong, nonatomic) NSString *strPath;
@property (strong, nonatomic) NSString *strTitle;
@property (nonatomic) int iDuration;
@property (strong, nonatomic) NSString *strDescription; // seconds
@property (strong, nonatomic) NSString *strExtDescription;
@property (strong, nonatomic) NSString *strCover; // image path
@property (strong, nonatomic) NSData *imageData;
@property (nonatomic) int iRating; //IMDB
@property (nonatomic) int iRTCriticsScore; //Rotten Tomatoes
@property (nonatomic) int iYear;
@property (strong, nonatomic) NSString *strIMDBKey;

@property (strong, nonatomic) NSString *strDirector;
@property (strong, nonatomic) NSString *strCast;

@property (nonatomic) NSDate *dateAdded;

@property (nonatomic) BOOL isWatched;

//@property (nonatomic) BOOL isModified;
//@property (nonatomic) BOOL isDeleted;

- (BBMediaItem*) initWithBoxeeId:(NSString*)strBoxeeId andSeriesId:(NSString*)strSeriesId;

- (NSString*) movieDetails;
- (BOOL) isRotten;
@end
