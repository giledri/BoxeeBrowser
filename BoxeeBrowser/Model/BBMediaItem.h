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
@property (nonatomic) int idfFolder;
@property (strong, nonatomic) NSString *strFolderPath;
@property (nonatomic) BOOL isSharedFolder;
@property (strong, nonatomic) NSString *strTitle;
@property (nonatomic) NSInteger iDuration;
@property (strong, nonatomic) NSString *strDescription; // seconds
@property (strong, nonatomic) NSString *strExtDescription;
@property (strong, nonatomic) NSString *strCover; // image path
@property (strong, nonatomic) NSData *imageData;
@property (nonatomic) NSInteger iRating; //IMDB
@property (nonatomic) NSInteger iRTCriticsScore; //Rotten Tomatoes
@property (nonatomic) NSInteger iYear;
@property (strong, nonatomic) NSString *strIMDBKey;

@property (strong, nonatomic) NSString *strDirector;
@property (strong, nonatomic) NSString *strCast;
@property (strong, nonatomic) NSString *strGenre;


@property (nonatomic) NSDate *dateAdded;

@property (nonatomic) BOOL isWatched;

//@property (nonatomic) BOOL isModified;
//@property (nonatomic) BOOL isDeleted;

- (BBMediaItem*) initWithBoxeeId:(NSString*)strBoxeeId andSeriesId:(NSString*)strSeriesId;

- (NSString*) movieDetails;
- (BOOL) isRotten;
@end
