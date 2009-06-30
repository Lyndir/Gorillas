/*
 * This file is part of Gorillas.
 *
 *  Gorillas is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
 */

//
//  UILayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 08/03/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "UILayer.h"
#import "Remove.h"
#define kFilteringFactor            0.4f
#define kAccelerometerFrequency     50 //Hz


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
    
    //UIAccelerometer*  theAccelerometer = [UIAccelerometer sharedAccelerometer];
    //theAccelerometer.updateInterval = 1 / kAccelerometerFrequency;

    isAccelerometerEnabled = YES;

    return self;
}


-(void) setRotation:(float)aRotation {
    
    [super setRotation:aRotation];
    
    NSUInteger barSide = (int)self.rotation / 90;
    if([Director sharedDirector].deviceOrientation == CCDeviceOrientationLandscapeLeft)
        ++barSide;
    else if([Director sharedDirector].deviceOrientation == CCDeviceOrientationLandscapeRight)
        --barSide;
    
    switch (barSide % 4) {
        case 0:
            //[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
            //break;
        case 1:
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            break;
        case 2:
            //[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown animated:YES];
            //break;
        case 3:
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
            break;
    }
}


-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    // Use a basic low-pass filter to keep only the gravity component of each axis.
    accelX = (acceleration.x * kFilteringFactor) + (accelX * (1.0f - kFilteringFactor));
    accelY = (acceleration.y * kFilteringFactor) + (accelY * (1.0f - kFilteringFactor));
    accelZ = (acceleration.z * kFilteringFactor) + (accelZ * (1.0f - kFilteringFactor));
    
    // Use the acceleration data.
    if(accelX > 0.5)
        [self rotateTo:180];
    else if(accelX < -0.5)
        [self rotateTo:0];
}


-(void) rotateTo:(float)aRotation {
    
    if(rotateAction) {
        [self stopAction:rotateAction];
        [rotateAction release];
    }
    
    [self runAction:rotateAction = [[RotateTo alloc] initWithDuration:0.2f angle:aRotation]];
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
        
        //if(![self isScheduled:@selector(popMessageQueue:)])
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
    [messageLabel runAction:[Sequence actions:
                             [MoveBy actionWithDuration:1 position:ccp(0, -([[GorillasConfig get] fontSize] * 2))],
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
            [messageLabel runAction:[Sequence actions:
                                     [MoveTo actionWithDuration:1
                                                       position:ccp(-[messageLabel contentSize].width / 2, [messageLabel position].y)],
                                     [FadeOut actionWithDuration:1],
                                     [Remove action],
                                     nil]];
            [messageLabel release];
        }
        
        messageLabel = [[Label alloc] initWithString:msg
                                            fontName:[[GorillasConfig get] fixedFontName]
                                            fontSize: [[GorillasConfig get] fontSize]];
        [self addChild: messageLabel z:1];
    }
    else
        [messageLabel setString:msg];
    
    CGSize winSize = [[Director sharedDirector] winSize];
    [messageLabel setPosition:ccp([messageLabel contentSize].width / 2 + [[GorillasConfig get] fontSize],
                                  winSize.height + [[GorillasConfig get] fontSize])];
    [messageLabel setOpacity:0xff];
}


-(void) dealloc {
    
    [rotateAction release];
    rotateAction = nil;
    
    [messageQueue release];
    messageQueue = nil;
    
    [callbackQueue release];
    callbackQueue = nil;

    [messageLabel release];
    messageLabel = nil;
    
    [super dealloc];
}


@end
