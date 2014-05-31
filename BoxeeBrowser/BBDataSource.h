//
//  BBDataSourceController.h
//  BoxeeBrowser
//
//  Created by John Doe on 5/5/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBFtp.h"
#import "BBMediaItem.h"

@protocol BBDataSourceDelegate <NSObject>

- (void)databaseDidSync;
- (void)reloadData;

@end

@interface BBDataSource : NSObject <BBFtpDelegate>

typedef enum {
    AllMovies,
    UnwatchedMovies,
    AllShows,
    UnwatchedShows
} BBFilter;

typedef enum {
    TitleAtoZ = 1,
    TitleZtoA = 2,
    DateAddedNewestFirst = 3,
    dateAddedOldestFirst = 4
} BBOrder;

@property (nonatomic)BBFilter filter;
@property (nonatomic)BBOrder order;
@property (strong, nonatomic)NSString *searchText;

@property (strong, nonatomic)id<BBDataSourceDelegate> delegate;

@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSArray *shows;

-(BBDataSource*)initWithDelegate:(id<BBDataSourceDelegate>) delegate;

-(BBDataSource*)initWithDelegate:(id<BBDataSourceDelegate>) delegate forceSyncDatabase:(BOOL)forceSync;


-(void) updateView;

-(BOOL)itemHasMissingInformation:(BBMediaItem*)item;
- (NSData*)loadImageForItem:(BBMediaItem*)item completion:(void (^)())completionBlock;
- (void)findInfoFromOtherSourcesAsync:(BBMediaItem *)item completionBlock:(void (^)())completionBlock;

-(void) prepareForDelegate:(id<BBDataSourceDelegate>) delegate withFilter:(BBFilter) filter andOrder:(BBOrder) order;

@end
