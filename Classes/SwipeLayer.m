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
//  SwipeLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 15/02/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "SwipeLayer.h"

#define gSwipeMinHorizontal 50
#define gSwipeMaxVertical 100


@implementation SwipeLayer


+(id) nodeWithTarget:(id)t selector:(SEL)s {
    
    return [[[SwipeLayer alloc] initWithTarget:t selector:s] autorelease];
}


-(id) initWithTarget:(id)t selector:(SEL)s {
    
    if(!(self = [super init]))
        return self;
    
    CGSize winSize = [[Director sharedDirector] winSize];

    swiped          = NO;
    swipeStart      = ccp(-1, -1);
    swipeAction     = nil;
    swipeFrom       = CGPointZero;
    swipeTo         = ccp(winSize.width, winSize.height);
    [self setTarget:t selector:s];

    isTouchEnabled  = YES;
    
    return self;
}


-(void) setSwipeAreaFrom:(CGPoint)f to:(CGPoint)t {
    
    swipeFrom = f;
    swipeTo = t;
}


- (void)setTarget:(id)t selector:(SEL)s {
    
    [invocation release];
    invocation = nil;
    
    NSMethodSignature *sig = [[t class] instanceMethodSignatureForSelector:s];
    invocation = [[NSInvocation invocationWithMethodSignature:sig] retain];
    [invocation setTarget:t];
    [invocation setSelector:s];
}


-(BOOL) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if([[event allTouches] count] != 1)
        return [self ccTouchesCancelled:touches withEvent:event];
    
    if(self.position.x != 0 || self.position.y != 0)
        // Not in swipe ready position.
        return kEventIgnored;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    CGPoint swipePoint = ccp(point.y, point.x);
    
    if(swipePoint.x < swipeFrom.x || swipePoint.y < swipeFrom.y
        || swipePoint.x > swipeTo.x || swipePoint.y > swipeTo.y)
        // Lays outside swipeFrom - swipeTo box
        return kEventIgnored;
    
    swipeStart  = swipePoint;
    swiped      = NO;
    
    return kEventHandled;
}


-(BOOL) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if([[event allTouches] count] != 1)
        return [self ccTouchesCancelled:touches withEvent:event];
    
    if(swipeStart.x == -1 && swipeStart.y == -1)
        // Swipe hasn't yet begun.
        return kEventIgnored;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[touch view]];

    CGPoint swipePoint = ccp(point.y, point.x);
    if(fabsf(swipeStart.x - swipePoint.x) > gSwipeMinHorizontal
        && fabsf(swipeStart.y - swipePoint.y) < gSwipeMaxVertical)
        swiped = YES;
    
    CGFloat swipeActionDuration = [GorillasConfig get].transitionDuration;
    if(swipeAction) {
        if(![swipeAction isDone])
            swipeActionDuration -= swipeAction.elapsed;
        [self stopAction:swipeAction];
        [swipeAction release];
    }
    [self runAction:swipeAction = [[MoveTo alloc] initWithDuration:swipeActionDuration
                                                          position:ccp(swipePoint.x - swipeStart.x, 0)]];
    
    return kEventHandled;
}


-(BOOL) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(swipeStart.x == -1 && swipeStart.y == -1)
        return kEventIgnored;
    
    if(swipeAction) {
        [self stopAction:swipeAction];
        [swipeAction release];
        swipeAction = nil;
    }
    
    [self runAction:[MoveTo actionWithDuration:0.1f
                                      position:CGPointZero]];
    swipeStart = ccp(-1, -1);
    
    return kEventHandled;
}


-(BOOL) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(swipeStart.x == -1 && swipeStart.y == -1)
        return kEventIgnored;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    
    CGSize winSize = [[Director sharedDirector] winSize];
    CGPoint swipePoint = ccp(point.y, point.x);
    CGFloat swipeDist = swipePoint.x - swipeStart.x;
    swipeForward = swipeDist < 0;
    CGPoint swipeTarget = ccp(winSize.width * (swipeForward? -1: 1), 0);
    
    if(swipeAction) {
        [self stopAction:swipeAction];
        [swipeAction release];
    }
    
    if(swiped)
        [self runAction:swipeAction = [[Sequence alloc] initOne:[MoveTo actionWithDuration:[[GorillasConfig get] transitionDuration]
                                                                                  position:swipeTarget]
                                                            two:[CallFunc actionWithTarget:self selector:@selector(swipeDone:)]]];
    else
        [self runAction:swipeAction = [[MoveTo alloc] initWithDuration:0.1f
                                                              position:CGPointZero]];
            
    swipeStart = ccp(-1, -1);
    
    return kEventHandled;
}


-(void) swipeDone:(id)sender {

    [invocation setArgument:&swipeForward atIndex:2];
    [invocation invoke];
}


-(void) dealloc {
    
    [invocation release];
    invocation = nil;
    
    [swipeAction release];
    swipeAction = nil;
    
    [super dealloc];
}


@end
