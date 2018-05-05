//
//  LightGradientView.m
//  Cookie
//
//  Created by Russell Gray on 20/08/11.
//  Copyright 2011 SweetP Productions, Inc. All rights reserved.
//
//

#import "LightGradientView.h"

@implementation LightGradientView

@synthesize startColor, endColor, angle;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code here.
        [self setStartColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]];
        [self setEndColor:[NSColor colorWithCalibratedWhite:0.98 alpha:1.0]];
        [self setAngle:60];
    }
    return self;
}

- (void)drawRect:(NSRect)rect
{
    if (endColor == nil || [startColor isEqual:endColor])
    {
        // Fill view with a standard background color
        [startColor set];
        NSRectFill(rect);
    }
    else
    {
        // Fill view with a top-down gradient
        // from startingColor to endingColor
        NSGradient* aGradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
        [aGradient drawInRect:[self bounds] angle:angle];
    }
}

@end
