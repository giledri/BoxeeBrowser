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
#import "BBAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

@interface BBMovieDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *mediaImage;
@property (weak, nonatomic) IBOutlet UILabel *mediaTitle;
@property (weak, nonatomic) IBOutlet UILabel *mediaDetails;
@property (weak, nonatomic) IBOutlet UILabel *mediaScore;
@property (weak, nonatomic) IBOutlet UILabel *mediaGenreList;
@property (weak, nonatomic) IBOutlet UILabel *mediaDirector;
@property (weak, nonatomic) IBOutlet BBEnhancedLabel *mediaCast;
@property (weak, nonatomic) IBOutlet BBEnhancedLabel *mediaDescription;
@property (weak, nonatomic) IBOutlet UIImageView *mediaIsWatched;
@property (weak, nonatomic) IBOutlet BBRottenImageView *mediaIsRotten;
@property (weak, nonatomic) IBOutlet UILabel *mediaRTScore;
@property (weak, nonatomic) IBOutlet UISwitch *mediaIsWatchedSwitch;
@property (weak, nonatomic) IBOutlet UIButton *deleteMediaButton;

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
    
    self.mediaDescription.text = self.mediaItem.strExtDescription.length ? self.mediaItem.strExtDescription : self.mediaItem.strDescription;
    self.mediaScore.text = [NSString stringWithFormat:@"%.1f", ((double)self.mediaItem.iRating) / 10];
    
    [self.mediaIsRotten setHidden:(self.mediaItem.iRTCriticsScore < 0)];
    [self.mediaRTScore setHidden:(self.mediaItem.iRTCriticsScore < 0)];
    self.mediaIsRotten.isRotten = self.mediaItem.isRotten;
    self.mediaRTScore.text = [NSString stringWithFormat:@"%ld%%", (long)self.mediaItem.iRTCriticsScore];
    
    self.mediaGenreList.text = self.mediaItem.strGenre;
    self.mediaDirector.text = self.mediaItem.strDirector;
    self.mediaCast.text = self.mediaItem.strCast;
    
    [self.mediaIsWatched setHidden:!self.mediaItem.isWatched];
    [self.mediaIsWatchedSwitch setOn:self.mediaItem.isWatched];
    
    CALayer *layer = self.deleteMediaButton.layer;
    layer.borderWidth = 4;
    layer.borderColor = [self.deleteMediaButton.tintColor CGColor];
    layer.cornerRadius = 12;
    layer.masksToBounds = NO;
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

- (IBAction)toggleIsWatched:(UISwitch *)sender
{
    BBAppDelegate *appDelegate = (BBAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.dataSource toggleIsWatched:self.mediaItem];
    [self.mediaIsWatched setHidden:!self.mediaItem.isWatched];
}

- (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertController * alert1=   [UIAlertController
                                   alertControllerWithTitle:title
                                   message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok1 = [UIAlertAction
                          actionWithTitle:@"OK"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action) { }];
    
    [alert1 addAction:ok1];
    
    [self presentViewController:alert1 animated:YES completion:nil];
}

- (IBAction)deleteMedia:(UIButton *)sender
{
    UIAlertController* alert = [UIAlertController
                                  alertControllerWithTitle:@"Delete Movie"
                                  message:@"You are sure?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yes = [UIAlertAction
                         actionWithTitle:@"YES"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                             BBAppDelegate *appDelegate = (BBAppDelegate *)[[UIApplication sharedApplication] delegate];
                             if ([appDelegate.dataSource deleteMedia:self.mediaItem])
                             {
                                 [self.navigationController popViewControllerAnimated:YES];
                             }
                             else
                             {
                                 [self alertWithTitle:@"Delete Movie" andMessage:@"Failed to delete this movie!)"];
                             }
                         }];
    
    UIAlertAction* no = [UIAlertAction
                             actionWithTitle:@"No"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:no];
    [alert addAction:yes];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
