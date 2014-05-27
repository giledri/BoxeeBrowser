//
//  BBRottenImageView.m
//  BoxeeBrowser
//
//  Created by John Doe on 5/20/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBRottenImageView.h"

@implementation BBRottenImageView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) setIsRotten:(BOOL)isRotten
{
    self.image = [UIImage imageNamed:isRotten ? @"graphic-rotten-bad.png" : @"graphic-rotten-good.png"];
}

@end
