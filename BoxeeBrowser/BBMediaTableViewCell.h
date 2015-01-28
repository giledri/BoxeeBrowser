//
//  BBMediaTableViewCell.h
//  BoxeeBrowser
//
//  Created by John Doe on 5/1/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBEnhancedLabel.h"
#import "BBMediaItem.h"
#import "BBDataSource.h"
#import "BBRottenImageView.h"

@interface BBMediaTableViewCell : UITableViewCell

@property (strong, nonatomic)BBDataSource *dataSource;

@property (strong, nonatomic)BBMediaItem *mediaItem;

@property (weak, nonatomic) IBOutlet UIImageView *mediaImage;
@property (weak, nonatomic) IBOutlet UILabel *mediaTitle;
@property (weak, nonatomic) IBOutlet UILabel *mediaDetails;
@property (weak, nonatomic) IBOutlet UILabel *mediaScore;
@property (weak, nonatomic) IBOutlet BBEnhancedLabel *mediaDescription;
@property (weak, nonatomic) IBOutlet UIImageView *mediaIsWatched;
@property (weak, nonatomic) IBOutlet BBRottenImageView *mediaIsRotten;
@property (weak, nonatomic) IBOutlet UILabel *mediaRTScore;

@end
