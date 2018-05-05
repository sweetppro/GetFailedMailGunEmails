//
//  ColoredTextField.m
//  GetFailedMailGunEmails
//
//  Created by Ruussell on 2/12/12.
//  Copyright (c) 2012 SweetP Productions. All rights reserved.
//

#import "ColoredTextField.h"
#import "AppDelegate.h"

@implementation ColoredTextField

- (id) initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

- (void) drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    [self updateLabelWithColor:[NSColor colorWithRed:17/255.0 green:53/255.0 blue:255/255.0 alpha:1.0]];
}

- (void) setNeedsDisplay:(BOOL)needsDisplay
{
    [super setNeedsDisplay:needsDisplay];
}

- (void) updateLabelWithColor:(NSColor *)color
{
    //left aligned
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentLeft];
    
    NSString *labelString = [self stringValue];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    NSDictionary *normalFont = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:color, [NSFont fontWithName:@"menlo" size:12.0], style, nil] forKeys:[NSArray arrayWithObjects:NSForegroundColorAttributeName, NSFontAttributeName, NSParagraphStyleAttributeName, nil]];
    
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"%@", nil), labelString] attributes:normalFont]];
    
    [self setAttributedStringValue:string];
}

@end
