//
//  LightGradientView.h
//  Cookie
//
//  Created by Russell Gray on 20/08/11.
//  Copyright 2011 SweetP Productions, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LightGradientView : NSView
{
    NSColor *startColor;
    NSColor *endColor;
    int angle;
}

@property(copy) NSColor *startColor;
@property(copy) NSColor *endColor;
@property(assign) int angle;

@end
