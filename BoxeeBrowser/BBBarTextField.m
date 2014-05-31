//
//  BBBarTextField.m
//  BoxeeBrowser
//
//  Created by John Doe on 5/29/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBBarTextField.h"

@interface BBBarTextField()

@property (nonatomic) CGSize size;

@end

@implementation BBBarTextField

- (id) initWithSize:(CGSize) size andTintColor:(UIColor*) color
{
    size.height -= 4;
    
    self = [super initWithFrame:CGRectMake(0, 0, 0, size.height)];
    if (self) {
        self.size = size;
        [self setBorderStyle:UITextBorderStyleRoundedRect];
        [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [self setAutocorrectionType:UITextAutocorrectionTypeNo];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTextColor:[UIColor darkGrayColor]];
        [self setPlaceholder:@"Search by Title"];
        [self setTintColor:color];
        [self setHidden:YES];
        
        CALayer *layer = self.layer;
        layer.borderWidth = 3;
        layer.borderColor = [self.viewForBaselineLayout.tintColor CGColor];
        layer.cornerRadius = 10;
        layer.masksToBounds = NO;

    }
    return self;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    [self setFrame:CGRectMake(0, 0, [self isHidden] ? 0 : self.size.width, self.size.height)];
}

@end
