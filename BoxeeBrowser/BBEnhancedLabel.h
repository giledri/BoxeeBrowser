//
//  BBEnancedLabel.h
//  BoxeeBrowser
//
//  Created by John Doe on 4/30/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface BBEnhancedLabel : UILabel

@property (nonatomic, readwrite) VerticalAlignment verticalAlignment;

@end
