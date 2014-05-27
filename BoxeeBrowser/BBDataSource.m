//
//  BBDataSource.m
//  BoxeeBrowser
//
//  Created by John Doe on 5/5/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBDataSource.h"
#import "BBAppDelegate.h"
#import "BBFtp.h"
#import "BBMediaItem.h"
#import <sqlite3.h>


@interface BBDataSource()

@property (strong, nonatomic) NSString *boxeeUserCatalogPathTmp;
@property (strong, nonatomic) NSString *boxeeCatalogPath;
@property (strong, nonatomic) NSString *boxeeUserCatalogPath;

@property (strong, nonatomic) NSMutableDictionary *videoItemsByKey;
@property (strong, nonatomic) NSMutableDictionary *updatedItemsByKey;

@property (strong, nonatomic) NSMutableDictionary* unTouched;

@property (strong, nonatomic)BBAppDelegate *appDelegate;
@property (strong, nonatomic)BBFtp *ftp;

@property (nonatomic)sqlite3 *catalogDb;

@property (nonatomic)sqlite3_stmt *videoFilesStatement;

@property (nonatomic)int videoItemsIndex;

@property (strong, nonatomic) NSMutableArray *allMovies;
@property (strong, nonatomic) NSMutableArray *unWatchedMovies;

@property (strong, nonatomic) NSMutableArray *allShows;
@property (strong, nonatomic) NSMutableArray *unWatchedShows;

@property (nonatomic)BOOL *isRunningPtr;
@property (nonatomic)BOOL *abortRunningPtr;

@property (nonatomic)dispatch_queue_t queue;

@end

@implementation BBDataSource

-(BBDataSource*)init
{
    return [self initWithDelegate:nil];
}

-(BBDataSource*)initWithDelegate:(id<BBDataSourceDelegate>) delegate
{
    return [self initWithDelegate:delegate forceSyncDatabase:FALSE];
}

-(BBDataSource*)initWithDelegate:(id<BBDataSourceDelegate>) delegate forceSyncDatabase:(BOOL)forceSync
{
    self = [super init];
    
    self.delegate = delegate;
    
    self.appDelegate = (BBAppDelegate *)[[UIApplication sharedApplication] delegate];

    self.videoItemsByKey = [[NSMutableDictionary alloc] init];
    self.allMovies = [[NSMutableArray alloc] init];
    self.unWatchedMovies = [[NSMutableArray alloc] init];
    self.allShows = [[NSMutableArray alloc] init];
    self.unWatchedShows = [[NSMutableArray alloc] init];
    self.updatedItemsByKey = [[NSMutableDictionary alloc] init];
    
    BOOL syncOnStartup = [self.appDelegate readIntegerAttribute:settingsSyncOnStatup withDefaultValue:TRUE];
    if (forceSync || syncOnStartup)
    {
        // start FTP download of catalog db files
        self.ftp = [[BBFtp alloc] init];
        NSString* ipAddress = [self.appDelegate readStringAttribute:settingsIpAddress withDefaultValue:@"10.0.0.1"];
        [self.ftp initWithAddress:ipAddress andEventSink:self];
        [self.ftp downloadFile:@"/data/.boxee/UserData/profiles/gedri/Database/boxee_user_catalog.db"
                   toLocalPath:[self getDbLocalPath:@"tmp_boxee_user_catalog.db"]];
        [self.ftp downloadFile:@"/data/.boxee/UserData/Database/boxee_catalog.db"
                   toLocalPath:[self getDbLocalPath:@"tmp_boxee_catalog.db"]];
    }
    
    // start reading from local version o catalog db files
    self.boxeeCatalogPath = [self getDbLocalPath:@"boxee_catalog.db"];
    self.boxeeUserCatalogPath = [self getDbLocalPath:@"boxee_user_catalog.db"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ( [fileManager  fileExistsAtPath:self.boxeeUserCatalogPath]
        && [fileManager  fileExistsAtPath:self.boxeeCatalogPath] )
    {
        [self readFromCatalog];
    }
    
    return self;
}

-(void) prepareForDelegate:(id<BBDataSourceDelegate>) delegate withFilter:(BBFilter) filter andOrder:(BBOrder) order
{
    self.delegate = delegate;
    self.filter = filter;
    self.order = order;
}

-(void) updateView
{
    if (self.delegate == nil)
    {
        return;
    }
    
    NSArray *listToSort;
    switch (self.filter)
    {
        case AllMovies:
            listToSort = self.allMovies;
            break;
        case UnwatchedMovies:
            listToSort = self.unWatchedMovies;
            break;
        case AllShows:
            listToSort = self.allShows;
            break;
        case UnwatchedShows:
            listToSort = self.unWatchedShows;
            break;
    }
    
    NSArray *sortedList = [listToSort sortedArrayUsingComparator:^(id obj1, id obj2) {
        switch (self.order)
        {
            case TitleAtoZ:
                return [[(BBMediaItem *)obj1 strTitle] caseInsensitiveCompare:[(BBMediaItem *)obj2 strTitle]];
            case TitleZtoA:
                return [[(BBMediaItem *)obj2 strTitle] caseInsensitiveCompare:[(BBMediaItem *)obj1 strTitle]];
            case DateAddedNewestFirst:
                return [[(BBMediaItem *)obj2 dateAdded] compare:[(BBMediaItem *)obj1 dateAdded]];
            case dateAddedOldestFirst:
                return [[(BBMediaItem *)obj1 dateAdded] compare:[(BBMediaItem *)obj2 dateAdded]];
            default:
                return NSOrderedSame;
        }
    }];
    
    switch (self.filter)
    {
        case AllMovies:
        case UnwatchedMovies:
            self.movies = sortedList;
            break;
        case AllShows:
        case UnwatchedShows:
            self.shows = sortedList;
            break;
    }
    
    [self.delegate reloadData];
}

- (NSString*)getDbLocalPath:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (void)abortReadingFromCatalog
{
    if (self.queue == NULL || self.isRunningPtr == nil || self.abortRunningPtr == nil)
    {
        return;
    }
    
    if ( *(self.isRunningPtr) )
    {
        *(self.abortRunningPtr) = YES;
    }
    
    dispatch_sync(self.queue, ^{});
    
    *(self.abortRunningPtr) = NO;
}

- (NSString*)readDirectorForVideo:(int)idVideo
{
    NSString * strDirector = nil;
    
    const char *catalogDbPath = [self.boxeeCatalogPath UTF8String];
    sqlite3 *database;
    
    if (sqlite3_open(catalogDbPath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"  \
                                SELECT  d.strName           \
                                FROM director_to_video dv   \
                                INNER JOIN directors d ON d.idDirector = dv.idDirector      \
                                WHERE dv.idVideo=%d", idVideo];
        
        const char *query_stmt = [querySQL UTF8String];
        
        sqlite3_stmt    *statement;
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                strDirector = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
            }
            
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(database);
    }
    
    return strDirector;
}

- (NSString*)readCastForVideo:(int)idVideo
{
    NSString * strCast = nil;
    
    const char *catalogDbPath = [self.boxeeCatalogPath UTF8String];
    sqlite3 *database;
    
    if (sqlite3_open(catalogDbPath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"  \
                              SELECT  a.strName        \
                              FROM actor_to_video av   \
                              INNER JOIN actors a ON a.idActor = av.idActor      \
                              WHERE av.idVideo=%d", idVideo];
        
        const char *query_stmt = [querySQL UTF8String];
        
        sqlite3_stmt    *statement;
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                strCast = strCast == nil
                    ? strCast = @""
                    : [strCast stringByAppendingString:@", "];
                
                strCast = [strCast stringByAppendingString:[[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)]];
            }
            
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(database);
    }
    
    return strCast;
}

const NSString *queryVideoFiles = @"\
        SELECT  vf.strBoxeeId,          \
                vf.strSeriesId,         \
                vf.idVideo,             \
                vf.idFile,              \
                vf.strPath,             \
                vf.strTitle,            \
                vf.iDuration,           \
                vf.iYear,               \
                vf.strDescription,      \
                vf.strExtDescription,   \
                vf.strCover,            \
                vf.iDateAdded,          \
                vf.iRating,             \
                VF.strIMDBKey,          \
                vf.iRTCriticsScore      \
        FROM video_files vf             \
        INNER JOIN media_folders mf ON vf.idFolder=mf.idFolder      \
        GROUP BY strBoxeeId";

const NSString *queryWatched =  @"SELECT strBoxeeId FROM watched";

- (void)copyInfoFromUpdatedItem:(BBMediaItem *)updatedItem toItem:(BBMediaItem *)item
{
    item.strTitle = updatedItem.strTitle;
    item.iDuration = updatedItem.iDuration;
    item.iYear = updatedItem.iYear;
    item.strExtDescription = updatedItem.strExtDescription;
    item.strDescription = updatedItem.strDescription;
    item.strCover = updatedItem.strCover;
    item.iRating = updatedItem.iRating;
    item.strIMDBKey = updatedItem.strIMDBKey;
    item.iRTCriticsScore = updatedItem.iRTCriticsScore;
}

- (BBMediaItem *)newOrExistingItemByBoxeeId:(NSString *)strBoxeeId andSeriesId:(NSString *)strSeriesId
{
    BBMediaItem *item = [self.videoItemsByKey valueForKey:strBoxeeId];
    
    if (item == nil)
    {
        item = [[BBMediaItem alloc] initWithBoxeeId:strBoxeeId andSeriesId:strSeriesId];
        
        [self.videoItemsByKey setValue:item forKey:strBoxeeId];
        
        if ([strSeriesId length])
        {
            [self.allShows addObject:item];
        }
        else
        {
            [self.allMovies addObject:item];
        }
    }
    else
    {
        //item.isModified = YES;
        [self.unTouched removeObjectForKey:strBoxeeId];
    }
    
    return item;
}

- (void)processQueryVideoFilesRow:(sqlite3_stmt *)statement
{
    int columnIndex = 0;
    NSString* strBoxeeId = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, columnIndex++)];
    NSString* strSeriesId = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, columnIndex++)];
    
    BBMediaItem *item;
    item = [self newOrExistingItemByBoxeeId:strBoxeeId andSeriesId:strSeriesId];
    
    item.idVideo = sqlite3_column_int(statement, columnIndex++);
    item.idFile = sqlite3_column_int(statement, columnIndex++);
    item.strPath = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, columnIndex++)];
    item.strTitle = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, columnIndex++)];
    item.iDuration = sqlite3_column_int(statement, columnIndex++);
    item.iYear = sqlite3_column_int(statement, columnIndex++);
    item.strExtDescription = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, columnIndex++)];
    item.strDescription = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, columnIndex++)];
    item.strCover = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, columnIndex++)];
    item.dateAdded = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_int(statement, columnIndex++)];
    item.iRating = sqlite3_column_int(statement, columnIndex++);
    item.strIMDBKey = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, columnIndex++)];
    item.iRTCriticsScore = sqlite3_column_int(statement, columnIndex++);
    
    item.strDirector = [self readDirectorForVideo:item.idVideo];
    item.strCast = [self readCastForVideo:item.idVideo];
    
    if ([self itemHasMissingInformation:item])
    {
        BBMediaItem *updatedItem = [self.updatedItemsByKey objectForKey:item.strBoxeeId];
        if (updatedItem)
        {
            [self copyInfoFromUpdatedItem:updatedItem toItem:item];
        }
    }
    
//   NSLog(@"%@|%@", strBoxeeId, item.strTitle);
}

- (void)processQueryWatchedRow:(sqlite3_stmt *)statement
{
    NSString* strBoxeeId = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
    
    BBMediaItem *item = [self.videoItemsByKey valueForKey:strBoxeeId];
    
    if (item != nil)
    {
        item.isWatched = true;
        
        
        if ([item.strSeriesId length])
        {
            [self.unWatchedShows removeObject:item];
        }
        else
        {
            [self.unWatchedMovies removeObject:item];
        }
        
    }
    
    //NSLog(@"item %d is watched", item.idVideo);
}

- (void)readFromCatalog
{
    if (self.queue == NULL)
    {
        self.queue = dispatch_queue_create("ReadFromCatalogQueue", NULL);
    }
    else
    {
        [self abortReadingFromCatalog];
    }
    
    __block BOOL isRunning = NO;
    __block BOOL abortRunning = NO;
    
    dispatch_async(self.queue, ^
    {
        isRunning= YES;
        self.unTouched = [[NSMutableDictionary alloc] initWithDictionary:self.videoItemsByKey];
        
        const char *catalogDbPath = [self.boxeeCatalogPath UTF8String];
        const char * userCatalogDbPath = [self.boxeeUserCatalogPath UTF8String];
        sqlite3 *database;
        
        if (sqlite3_open(catalogDbPath, &database) == SQLITE_OK)
        {
            const char *query_stmt = [queryVideoFiles UTF8String];
            
            sqlite3_stmt *statement;
            
            if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                while (sqlite3_step(statement) == SQLITE_ROW
                       && !abortRunning)
                {
                    [self processQueryVideoFilesRow:statement];
                }
                
                sqlite3_finalize(statement);
            }
            
            sqlite3_close(database);
        }
        
        if (!abortRunning)
        {
            for (NSString *keyToDelete in self.unTouched.allKeys)
            {
                BBMediaItem *item = [self.videoItemsByKey valueForKey:keyToDelete];
                [self.allMovies removeObject:item];
                [self.allShows removeObject:item];
                [self.videoItemsByKey removeObjectForKey:keyToDelete];
            }
            
            [self.unWatchedMovies removeAllObjects];
            [self.unWatchedMovies addObjectsFromArray:self.allMovies];
            
            if (sqlite3_open(userCatalogDbPath, &database) == SQLITE_OK)
            {
                const char *query_stmt = [queryWatched UTF8String];
                
                sqlite3_stmt    *statement;
                
                if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
                {
                    while (sqlite3_step(statement) == SQLITE_ROW && !abortRunning)
                    {
                        [self processQueryWatchedRow:statement];
                    }
                    
                    sqlite3_finalize(statement);
                }
                
                sqlite3_close(database);
            }
        }
        
        if (!abortRunning)
        {
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                [self updateView];
            });

        }
        
        isRunning = NO;
    });
    
    self.isRunningPtr = &isRunning;
    self.abortRunningPtr = &abortRunning;
}


#pragma mark - BBFtpEventSink

- (void)downloadCompleted:(NSString *)filename toLocalPath:(NSString *)path
{
    if ([filename isEqualToString:@"tmp_boxee_user_catalog.db"])
    {
        self.boxeeUserCatalogPathTmp = path;
    }
    else if ([filename isEqualToString:@"tmp_boxee_catalog.db"])
    {
        [self abortReadingFromCatalog];
        
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        [fileManager removeItemAtPath:self.boxeeUserCatalogPath error:&error];
        [fileManager moveItemAtPath:self.boxeeUserCatalogPathTmp toPath:self.boxeeUserCatalogPath   error:&error];
        
        [fileManager removeItemAtPath:self.boxeeCatalogPath error:&error];
        [fileManager moveItemAtPath:path toPath:self.boxeeCatalogPath error:&error];

        NSString* lastSyncTime = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
        [self.appDelegate storeAttribute:settingsLastSyncTime withStringValue:lastSyncTime];
        
        if (self.delegate != nil)
        {
            [self.delegate databaseDidSync];
        }
        
        [self readFromCatalog];
    }
}

- (void)downloadFailed:(NSString *)filename withError:(NSString *)errorString
{
    
}

-(BOOL)itemHasMissingInformation:(BBMediaItem*)item
{
    return (!item.strCover.length ||
            (!item.strDescription.length && !item.strExtDescription.length) ||
            !item.iYear ||
            !item.iDuration ||
            !item.iRating);
}

-(BOOL)findInfoFromOMDB:(BBMediaItem*)item
{
    BOOL itemUpdated = NO;
    
    NSString *url = [NSString stringWithFormat:@"http://www.omdbapi.com/?i=%@&t=%@", item.strIMDBKey, item.strIMDBKey.length ? @"" : [item.strTitle stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    if (data)
    {
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
        
        NSString *strPoster = [dict valueForKey:@"Poster"];
        NSString *strPlot = [dict valueForKey:@"Plot"];
        NSString *strYear = [dict valueForKey:@"Year"];
        NSString *strRuntime = [dict valueForKey:@"Runtime"];
        NSString *strImdbRating = [dict valueForKey:@"imdbRating"];
        
        if (!item.strCover.length &&
            strPoster.length && ![strPoster isEqualToString:@"N/A"])
        {
            itemUpdated = YES;
            item.strCover = strPoster;
        }
        
        if (!item.strDescription.length && !item.strExtDescription.length
            && strPlot.length && ![strPlot isEqualToString:@"N/A"])
        {
            itemUpdated = YES;
            item.strDescription = item.strExtDescription = strPlot;
        }
        
        if (!item.iDuration
            && strRuntime.length && ![strRuntime isEqualToString:@"N/A"])
        {
            int iDuration = [strRuntime integerValue] * 60;
            if (iDuration)
            {
                itemUpdated = YES;
                item.iDuration = iDuration;
            }
        }
        
        if (!item.iYear
            && strYear.length && ![strYear isEqualToString:@"N/A"])
        {
            int iYear = [strYear integerValue];
            if (iYear)
            {
                itemUpdated = YES;
                item.iYear = iYear;
            }
        }

        if (!item.iRating
            && strImdbRating.length && ![strImdbRating isEqualToString:@"N/A"])
        {
            int iRating = [strImdbRating integerValue] * 10;
            if (iRating)
            {
                itemUpdated = YES;
                item.iRating = iRating;
            }
        }
    }
    
    return itemUpdated;
}

- (void)findInfoFromOtherSourcesAsync:(BBMediaItem *)item completionBlock:(void (^)())completionBlock
{
    if (item.strIMDBKey.length || item.strTitle.length)
    {
        const char *queueName = [[@"FindInfoFromOtherSourceQueue" stringByAppendingString:item.strBoxeeId] cStringUsingEncoding:[NSString defaultCStringEncoding]];
        dispatch_queue_t queue = dispatch_queue_create(queueName, NULL);
        dispatch_async(queue, ^{
            NSLog(@"searching information in other source (item: %@ BoxeeId: %@ IMDB Id: %@)", item.strTitle, item.strBoxeeId, item.strIMDBKey);
            if ([self findInfoFromOMDB:item])
            {
                id updatedItem = [item copy];
                [self.updatedItemsByKey setObject:updatedItem forKey:item.strBoxeeId];
                
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    completionBlock();
                });
            }
        });
    }
}

- (void)downloadImageAsync:(BBMediaItem *)item cachedImagePath:(NSString *)cachedImagePath completionBlock:(void (^)())completionBlock
{
    NSLog(@"image not in cache - downloading image (item: %@ BoxeeId: %@ IMDB Id: %@ url: %@)", item.strTitle, item.strBoxeeId, item.strIMDBKey, item.strCover);
    
    const char *queueName = [[@"LoadCellImageQueue" stringByAppendingString:item.strBoxeeId] cStringUsingEncoding:[NSString defaultCStringEncoding]];
    dispatch_queue_t queue = dispatch_queue_create(queueName, NULL);
    dispatch_async(queue, ^{
        item.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:item.strCover]];
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^{
            NSLog(@"updating image in cell (item: %@ BoxeeId: %@ IMDB Id: %@)", item.strTitle, item.strBoxeeId, item.strIMDBKey);
            completionBlock();
        });
        [item.imageData writeToFile:cachedImagePath atomically:YES];
    });
}

- (NSData*)loadImageForItem:(BBMediaItem*)item completion:(void (^)())completionBlock
{
    NSLog(@"loadImageForItem (item: %@ BoxeeId: %@ IMDB Id: %@)", item.strTitle, item.strBoxeeId, item.strIMDBKey);
    
    NSData* imageData = nil;
    
    if (item.strCover.length)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        NSString *cachedImagePath = [documentsDirectory stringByAppendingPathComponent:[item.strCover lastPathComponent]];
        
        imageData = [NSData dataWithContentsOfFile:cachedImagePath];
        if (imageData == nil)
        {
            [self downloadImageAsync:item cachedImagePath:cachedImagePath completionBlock:completionBlock];
        }
    }
    
    return imageData;
}


@end