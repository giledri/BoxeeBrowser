//
//  BBMediaViewController.m
//  BoxeeBrowser
//
//  Created by John Doe on 5/6/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBMovieDetailsViewController.h"
#import "BBEnhancedLabel.h"
#import "BBRottenImageView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface BBMovieDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *mediaImage;
@property (weak, nonatomic) IBOutlet UILabel *mediaTitle;
@property (weak, nonatomic) IBOutlet UILabel *mediaDetails;
@property (weak, nonatomic) IBOutlet UILabel *mediaScore;
@property (weak, nonatomic) IBOutlet UILabel *mediaDirector;
@property (weak, nonatomic) IBOutlet BBEnhancedLabel *mediaCast;
@property (weak, nonatomic) IBOutlet BBEnhancedLabel *mediaDescription;
@property (weak, nonatomic) IBOutlet UIImageView *mediaIsWatched;
@property (weak, nonatomic) IBOutlet BBRottenImageView *mediaIsRotten;
@property (weak, nonatomic) IBOutlet UILabel *mediaRTScore;

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@end

@implementation BBMovieDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpg"]]];

    self.mediaTitle.text = self.mediaItem.strTitle;
    self.mediaDetails.text = self.mediaItem.movieDetails;
    
    if (self.mediaItem.imageData)
    {
        self.mediaImage.image = [UIImage imageWithData:self.mediaItem.imageData];
    }
    
    self.mediaDescription.text = self.mediaItem.strExtDescription;
    self.mediaScore.text = [NSString stringWithFormat:@"%.1f", ((double)self.mediaItem.iRating) / 10];
    
    [self.mediaIsRotten setHidden:(self.mediaItem.iRTCriticsScore < 0)];
    [self.mediaRTScore setHidden:(self.mediaItem.iRTCriticsScore < 0)];
    self.mediaIsRotten.isRotten = self.mediaItem.isRotten;
    self.mediaRTScore.text = [NSString stringWithFormat:@"%d%%", self.mediaItem.iRTCriticsScore];
    
    self.mediaDirector.text = self.mediaItem.strDirector;
    self.mediaCast.text = self.mediaItem.strCast;
    
    [self.mediaIsWatched setHidden:!self.mediaItem.isWatched];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)imdbButtonClicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.imdb.com/title/%@/", self.mediaItem.strIMDBKey]]];
}

/*
- (IBAction)playOnDevice:(id)sender
{
    NSURL *url = [NSURL URLWithString:self.mediaItem.strPath];
    self.moviePlayer =  [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer];
    
    self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
    self.moviePlayer.shouldAutoplay = YES;
    [self.view addSubview:self.moviePlayer.view];
    [self.moviePlayer setFullscreen:YES animated:YES];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    if ([player
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    }
}
*/

@end
