//
//  BBMediaTableViewCell.m
//  BoxeeBrowser
//
//  Created by John Doe on 5/1/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBMediaTableViewCell.h"

@interface BBMediaTableViewCell()

@property (strong, nonatomic) UIImage *defaultImage;

@end

@implementation BBMediaTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMediaItem:(BBMediaItem *)mediaItem
{
    [self setMediaItem:mediaItem tryOtherSources:YES];
}

-(void)setMediaItem:(BBMediaItem *)mediaItem tryOtherSources:(BOOL)tryOtherSources
{
    if (self.defaultImage == nil)
    {
        self.defaultImage = self.mediaImage.image;
    }
    
    _mediaItem = mediaItem;
    
    NSString *seriesHeader;
    if (mediaItem.iSeason > 0)
    {
        seriesHeader = [NSString stringWithFormat:@"Season %d" , mediaItem.iSeason];
    }
    if (mediaItem.iEpisode > 0)
    {
        seriesHeader = [NSString stringWithFormat:@"%@%@Episode %d",
                        seriesHeader != nil ? seriesHeader : @"",
                        seriesHeader != nil ? @", " : @"",
                        mediaItem.iEpisode];
    }
    
    self.mediaTitle.text = [NSString stringWithFormat:@"%@%@%@ ",
                            seriesHeader != nil ? seriesHeader : @"",
                            seriesHeader != nil ? @" : " : @"",
                            mediaItem.strTitle];
    self.mediaDetails.text = mediaItem.movieDetails;
    UIImage *mediaImage = [self loadImageForCell:self forItem:mediaItem];
    self.mediaImage.image = mediaImage != nil ? mediaImage : self.defaultImage;
    self.mediaDescription.text = mediaItem.strDescription.length ? mediaItem.strDescription : mediaItem.strExtDescription;
    self.mediaScore.text = [NSString stringWithFormat:@"%.1f", ((double)mediaItem.iRating) / 10];
    
    [self.mediaIsRotten setHidden:(mediaItem.iRTCriticsScore < 0)];
    [self.mediaRTScore setHidden:(mediaItem.iRTCriticsScore < 0)];
    self.mediaIsRotten.isRotten = mediaItem.isRotten;
    self.mediaRTScore.text = [NSString stringWithFormat:@"%ld%%", (long)mediaItem.iRTCriticsScore];

    [self.mediaIsWatched setHidden:!mediaItem.isWatched];
    
    if (tryOtherSources && [self.dataSource itemHasMissingInformation:mediaItem])
    {
        [self findInfoFromOtherSources:self forItem:mediaItem];
    }
}

- (void)findInfoFromOtherSources:(BBMediaTableViewCell *)cell forItem:(BBMediaItem *)item
{
    [self.dataSource findInfoFromOtherSourcesAsync:item completionBlock:^{
        if ( cell.mediaItem == item )
        {
            [self setMediaItem:item tryOtherSources:NO];
        }
    }];
}

- (id)loadImageForCell:(BBMediaTableViewCell *)cell forItem:(BBMediaItem *)item
{
    if (item.imageData == nil)
    {
        item.imageData = [self.dataSource loadImageForItem:item completion:^{
            if ( cell.mediaItem == item )
            {
                cell.mediaImage.image = [UIImage imageWithData:item.imageData];
            }
        }];
    }
    
    return [UIImage imageWithData:item.imageData];
}

- (IBAction)imdbButtonClicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.imdb.com/title/%@/", self.mediaItem.strIMDBKey]]];
}


@end
