//
//  AppDelegate.h
//  GetFailedMailGunEmails
//
//  Created by Ruussell on 5/5/18.
//  Copyright © 2018 SweetP Productions, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "SYFlatButton.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
{
    NSMutableArray *emails;
    NSMutableArray *checkEmails;
    NSString *nextUrl;
    
    BOOL shouldStop;
    
    IBOutlet NSWindow *windowView;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet SYFlatButton *startButton;
    IBOutlet NSTextField *emailView;
    
    IBOutlet NSTextField *apiField;
    IBOutlet NSTextField *domainField;
}

- (void) initProperties;
- (IBAction) start:(id)sender;
- (IBAction) stop:(id)sender;
- (void) getData;
- (NSString *) getDataForUrl:(NSString *)url;
- (void) processEmails;
- (void) buttonCheck;
- (void) checkApiAndDomain;

@property (nonatomic, retain) NSMutableArray *emails;
@property (nonatomic, retain) NSMutableArray *checkEmails;
@property (nonatomic, copy) NSString *nextUrl;

@property BOOL shouldStop;

@property (nonatomic, retain) NSWindow *windowView;
@property (nonatomic, retain) NSProgressIndicator *progressIndicator;
@property (nonatomic, retain) SYFlatButton *startButton;
@property (nonatomic, retain) NSTextField *emailView;

@property (nonatomic, retain) NSTextField *apiField;
@property (nonatomic, retain) NSTextField *domainField;

@end

