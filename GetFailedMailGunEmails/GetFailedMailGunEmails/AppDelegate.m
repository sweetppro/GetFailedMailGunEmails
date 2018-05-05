//
//  AppDelegate.m
//  GetFailedMailGunEmails
//
//  Created by Ruussell on 5/5/18.
//  Copyright © 2018 SweetP Productions, Inc. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
@synthesize emails, checkEmails, nextUrl, shouldStop;
@synthesize windowView, progressIndicator, startButton, emailView, apiField, domainField;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self forKeyPath:@"apiKey" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    [defaults addObserver:self forKeyPath:@"domain" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
}

- (void) applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (object == defaults)
    {
        if ([keyPath isEqualToString:@"apiKey"] || [keyPath isEqualToString:@"domain"]) {
            [self checkApiAndDomain];
        }
    }
}

- (void) awakeFromNib
{
    windowView.movableByWindowBackground  = true;
    [self.progressIndicator setUsesThreadedAnimation:YES];
    
    [self.startButton setEnabled:NO];
    [self checkApiAndDomain];
}

- (void) initProperties
{
    self.emails = [NSMutableArray new];
    self.checkEmails = [NSMutableArray new];
    self.nextUrl = nil;
}

- (IBAction) start:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initProperties];
        [self.progressIndicator setHidden:NO];
        [self.progressIndicator startAnimation:self];
        [self.apiField setEnabled:NO];
        [self.domainField setEnabled:NO];
        self.shouldStop = NO;
        
        [self.emailView setStringValue:@"Getting emails from Mailgun..."];
        
        [self buttonCheck];
        [self.startButton setTitle:@"Stop..."];
        [self.startButton setAction:@selector(stop:)];
        
        dispatch_queue_t queue = dispatch_queue_create("com.sweetpproductions.GetFailedMailGunEmails.task", NULL);
        dispatch_async(queue, ^{
                           [self getData];
                       });
    });
}

- (IBAction) stop:(id)sender
{
    self.shouldStop = YES;
    
    if ([[self.emailView stringValue] isEqualToString:@"Getting emails from Mailgun..."])
        [self.emailView setStringValue:@"Ready to get Mailgun emails..."];
    
    [self processEmails];
}

- (void) getData
{
    if (self.shouldStop == YES)
        return;
    
    if ([self.nextUrl isEqualToString:@"end"]) {
        [self processEmails];
        return;
    }
    
    NSString *jsonString = [self getDataForUrl:self.nextUrl];
    if (!jsonString || [jsonString isEqualToString:@""]) {
        [self processEmails];
        return;
    }
    
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization
                          JSONObjectWithData:jsonData
                          options:0
                          error:&error];
    
    NSArray *itemArray = [dict objectForKey:@"items"];
    for (id item in itemArray) {
        if (self.shouldStop == YES)
            return;
        
        if ([item isKindOfClass:[NSDictionary class]])
        {
            NSMutableDictionary *mut = [NSMutableDictionary new];
            
            if ([item objectForKey:@"severity"])
                [mut setObject:[item objectForKey:@"severity"] forKey:@"severity"];
            else
                [mut setObject:@"" forKey:@"severity"];
            
            if ([item objectForKey:@"id"])
                [mut setObject:[item objectForKey:@"id"] forKey:@"id"];
            else
                [mut setObject:@"" forKey:@"id"];
            
            if ([item objectForKey:@"delivery-status"]) {
                NSDictionary *delivery = [item objectForKey:@"delivery-status"];
                if ([delivery objectForKey:@"code"]) {
                    NSString *code = [delivery objectForKey:@"code"];
                    [mut setObject:code forKey:@"code"];
                }
                else
                    [mut setObject:@"" forKey:@"code"];
                
                if ([delivery objectForKey:@"message"]) {
                    NSString *deliveryMessage = [delivery objectForKey:@"message"];
                    
                    //santize for csv
                    deliveryMessage = [deliveryMessage stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                    deliveryMessage = [deliveryMessage stringByReplacingOccurrencesOfString:@"," withString:@" "];
                    [mut setObject:deliveryMessage forKey:@"message"];
                }
                else
                    [mut setObject:@"" forKey:@"message"];
            }
            else {
                [mut setObject:@"" forKey:@"code"];
                [mut setObject:@"" forKey:@"message"];
            }
            
            if ([item objectForKey:@"message"]) {
                NSDictionary *message = [item objectForKey:@"message"];
                if ([message objectForKey:@"headers"]) {
                    NSDictionary *headers = [message objectForKey:@"headers"];
                    if ([headers objectForKey:@"to"] == [NSNull null])
                        continue;
                    
                    if ([headers objectForKey:@"to"]) {
                        NSString *to = [headers objectForKey:@"to"];
                        to = [to stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        NSArray *components = [to componentsSeparatedByString:@" "];
                        
                        BOOL shouldAdd = YES;
                        
                        NSString *email = [components lastObject];
                        if ([email containsString:@"<"]) {
                            email = [email stringByReplacingOccurrencesOfString:@"<" withString:@""];
                            email = [email stringByReplacingOccurrencesOfString:@">" withString:@""];
                        }
                        
                        [mut setObject:email forKey:@"email"];
                        if ([self.checkEmails containsObject:email])
                            shouldAdd = NO;
                        else
                            [self.checkEmails addObject:email];
                        
                        for (NSString *comp in components)
                        {
                            if (components.count == 1 || [comp containsString:@"@"])
                                continue;
                            else {
                                if ([comp isEqualToString:[components firstObject]]) {
                                    [mut setObject:comp forKey:@"firstName"];
                                } else {
                                    [mut setObject:comp forKey:@"lastName"];
                                }
                            }
                        }
                        if (shouldAdd == YES)
                        {
                            if (![mut objectForKey:@"firstName"])
                                [mut setObject:@"" forKey:@"firstName"];
                            if (![mut objectForKey:@"lastName"])
                                [mut setObject:@"" forKey:@"lastName"];
                            
                            [self.emails addObject:mut];
                            mut = nil;
                        }
                    }
                }
            }
        }
    }
    
    NSString *foundString = [NSString stringWithFormat:@"Found %lu emails", (unsigned long)[emails count]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.emailView setStringValue:foundString];
    });
    
    NSDictionary *pagingDict = [dict objectForKey:@"paging"];
    if ([pagingDict objectForKey:@"next"])
        self.nextUrl = [pagingDict objectForKey:@"next"];
    else
        self.nextUrl = @"end";
    
    [self getData];
}

- (NSString *) getDataForUrl:(NSString *)url
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *domain = [defaults stringForKey:@"domain"];
    if (url == nil)
        url = [NSString stringWithFormat:@"https://api.mailgun.net/v3/%@/events --data-urlencode event='rejected OR failed'", domain];
    
    
    NSString *apiKey = [defaults stringForKey:@"apiKey"];
    NSString *curlString = [NSString stringWithFormat:@"curl -s --user 'api:%@' -G %@", apiKey, url];
    
    NSTask *task = [NSTask new];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:@[@"-c", curlString]];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    return string;
}

- (void) processEmails
{
    NSString *saveString = @"id,severity,code,message,firstName,lastName,email\n";
    for (NSDictionary *dict in self.emails) {
        NSString *firstName = [dict objectForKey:@"firstName"];
        NSString *lastName = [dict objectForKey:@"lastName"];
        NSString *email = [dict objectForKey:@"email"];
        
        NSString *messageID = [dict objectForKey:@"id"];
        NSString *severity = [dict objectForKey:@"severity"];
        NSString *code = [dict objectForKey:@"code"];
        NSString *message = [dict objectForKey:@"message"];
        
        NSString *string = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@\n", messageID, severity, code, message, firstName, lastName, email];
        saveString = [saveString stringByAppendingString:string];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressIndicator setHidden:YES];
        [self.progressIndicator stopAnimation:self];
        [self.apiField setEnabled:YES];
        [self.domainField setEnabled:YES];
        
        [self.startButton setEnabled:YES];
        [self.startButton setTitle:@"Get Started..."];
        [self.startButton setAction:@selector(start:)];
        [self buttonCheck];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSSavePanel *savePanel;
        savePanel = [NSSavePanel savePanel];
        [savePanel setExtensionHidden:YES];
        [savePanel setCanSelectHiddenExtension:NO];
        [savePanel setTreatsFilePackagesAsDirectories:NO];
        [savePanel setNameFieldStringValue:@"Failed.csv"];
        [savePanel setMessage:@"Save csv file"];
        [savePanel setAllowsOtherFileTypes:NO];
        [savePanel setAllowedFileTypes:@[@"csv"]];
        if ([savePanel runModal] == NSModalResponseOK)
        {
            NSURL *url = [savePanel URL];
            
            // create the file
            if( ![fm fileExistsAtPath:[url path]] )
                [saveString writeToFile:[url path] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            if( [fm fileExistsAtPath:[url path]] )
            {
                [fm removeItemAtPath:[url path] error:nil];
                [saveString writeToFile:[url path] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
        }
    });
}

- (void) buttonCheck
{
    if (self.startButton.enabled == NO)
    {
        startButton.backgroundNormalColor = [NSColor colorWithRed:122/255.0 green:129/255.0 blue:255/255.0 alpha:0.1];
        startButton.backgroundHighlightColor = [NSColor colorWithRed:122/255.0 green:129/255.0 blue:255/255.0 alpha:0.1];
    }
    else
    {
        startButton.backgroundNormalColor = [NSColor colorWithRed:122/255.0 green:129/255.0 blue:255/255.0 alpha:1.0];
        startButton.backgroundHighlightColor = [NSColor colorWithRed:122/255.0 green:129/255.0 blue:255/255.0 alpha:0.7];
    }
}

- (void) checkApiAndDomain
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *newString = @"Ready to get Mailgun emails...";
        [self.startButton setEnabled:YES];
        
        if ([[defaults stringForKey:@"domain"] length] == 0)
        {
            newString = @"Please set a Mailgun domain...";
            [self.startButton setEnabled:NO];
        }
        
        if ([[defaults stringForKey:@"apiKey"] length] == 0)
        {
            newString = @"Please set your Mailgun API key...";
            [self.startButton setEnabled:NO];
        }
        
        [self.emailView setStringValue:newString];
        
        [self buttonCheck];
        
        [self.apiField setPlaceholderString:@"key-yourAPIkey"];
        [self.domainField setPlaceholderString:@"yourURL.com"];
    });
}

- (void) windowWillClose:(NSNotification *)notification
{
    [NSApp terminate:self];
}

@end
