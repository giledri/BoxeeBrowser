//
//  BBUITableViewCell.m
//  BoxeeBrowser
//
//  Created by John Doe on 5/18/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBUITableViewCell.h"

@interface BBUITableViewCell()

@property (strong, nonatomic)CALayer *subLayer;;

@end
@implementation BBUITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    self.subLayer = [CALayer layer];
    self.subLayer.frame = CGRectInset(self.contentView.frame, 6, 6);
    self.subLayer.cornerRadius = 12;
    self.subLayer.masksToBounds = NO;
    self.subLayer.borderColor = [self.tintColor CGColor];

    CALayer *layer = self.layer;
    [layer addSublayer:self.subLayer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];
    
    self.subLayer.frame = CGRectInset(self.contentView.frame, 6, 6);

    if (selected && self.reuseIdentifier )
    {
        self.subLayer.borderWidth = 4;
    }
    else
    {
        self.subLayer.borderWidth = 0;
    }
}

@end
