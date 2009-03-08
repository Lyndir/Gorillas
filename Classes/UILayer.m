//
//  UILayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 08/03/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "UILayer.h"
#import "GorillasConfig.h"
#import "Remove.h"


@interface UILayer (Private)

-(void) resetMessage:(NSString *)msg;

@end


@implementation UILayer


-(id) init {
    
	if (!(self = [super init]))
		return self;
    
    // Build internal structures.
    messageQueue = [[NSMutableArray alloc] initWithCapacity:3];
    callbackQueue = [[NSMutableArray alloc] initWithCapacity:3];
    messageLabel = nil;

    return self;
}


-(void) message:(NSString *)msg {
    
    [self message:msg callback:nil :nil];
}


-(void) message:(NSString *)msg callback:(id)target :(SEL)selector {
    
    NSInvocation *callback = nil;
    if(target) {
        NSMethodSignature *signature = [[target class] instanceMethodSignatureForSelector:selector];
        callback = [NSInvocation invocationWithMethodSignature:signature];
        [callback setTarget:[target retain]];
        [callback setSelector:selector];
    }
    
    @synchronized(messageQueue) {
        [messageQueue insertObject:msg atIndex:0];
        [callbackQueue insertObject:callback? callback: (id)[NSNull null] atIndex:0];
        
        if(![self isScheduled:@selector(popMessageQueue:)])
            [self schedule:@selector(popMessageQueue:)];
    }
}


-(void) popMessageQueue: (ccTime)dt {
    
    @synchronized(messageQueue) {
        [self unschedule:@selector(popMessageQueue:)];
        
        if(![messageQueue count])
            // No messages left, don't reschedule.
            return;
        
        [self schedule:@selector(popMessageQueue:) interval:1.5f];
    }
    
    NSString *msg = [[messageQueue lastObject] retain];
    [messageQueue removeLastObject];
    
    NSInvocation *callback = [[callbackQueue lastObject] retain];
    [callbackQueue removeLastObject];
    
    [self resetMessage:msg];
    [messageLabel do:[Sequence actions:
                  [MoveBy actionWithDuration:1 position:cpv(0, -([[GorillasConfig get] fontSize] * 2))],
                  [FadeTo actionWithDuration:2 opacity:0x00],
                  nil]];
    
    if(callback != (id)[NSNull null]) {
        [callback invoke];
        [[callback target] release];
    }
    
    [msg release];
    [callback release];
}


-(void) resetMessage:(NSString *)msg {
    
    if(!messageLabel || [messageLabel numberOfRunningActions]) {
        // Detach existing label & create a new message label for the next message.
        if(messageLabel) {
            [messageLabel stopAllActions];
            [messageLabel do:[Sequence actions:
                              [MoveTo actionWithDuration:1
                                                position:cpv(-[messageLabel contentSize].width / 2, [messageLabel position].y)],
                              [FadeOut actionWithDuration:1],
                              [Remove action],
                              nil]];
            [messageLabel release];
        }
        
        messageLabel = [[Label alloc] initWithString:msg
                                            fontName:[[GorillasConfig get] fixedFontName]
                                            fontSize: [[GorillasConfig get] fontSize]];
        [self add: messageLabel z:1];
    }
    else
        [messageLabel setString:msg];
    
    CGSize winSize = [[Director sharedDirector] winSize];
    [messageLabel setPosition:cpv([messageLabel contentSize].width / 2 + [[GorillasConfig get] fontSize],
                                  winSize.height + [[GorillasConfig get] fontSize])];
    [messageLabel setOpacity:0xff];
}


-(void) dealloc {
    
    [messageQueue release];
    messageQueue = nil;
    
    [callbackQueue release];
    callbackQueue = nil;

    [messageLabel release];
    messageLabel = nil;
    
    [super dealloc];
}


@end
