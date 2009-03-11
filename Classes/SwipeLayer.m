/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  SwipeLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 15/02/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "SwipeLayer.h"
#import "GorillasConfig.h"
#import "Utility.h"

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
    swipeStart      = cpv(-1, -1);
    swipeAction     = nil;
    swipeFrom       = cpvzero;
    swipeTo         = cpv(winSize.width, winSize.height);
    [self setTarget:t selector:s];

    isTouchEnabled  = YES;
    
    return self;
}


-(void) setSwipeAreaFrom:(cpVect)f to:(cpVect)t {
    
    swipeFrom = f;
    swipeTo = t;
}


- (void)setTarget:(id)t selector:(SEL)s {
    
    [[invocation target] release];
    [invocation release];
    invocation = nil;
    
    NSMethodSignature *sig = [[t class] instanceMethodSignatureForSelector:s];
    invocation = [[NSInvocation invocationWithMethodSignature:sig] retain];
    [invocation setTarget:[t retain]];
    [invocation setSelector:s];
}


-(BOOL) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if([[event allTouches] count] != 1)
        return [self ccTouchesCancelled:touches withEvent:event];
    
    if(position.x != 0 || position.y != 0)
        // Not in swipe ready position.
        return kEventIgnored;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    cpVect swipePoint = cpv(point.y, point.x);
    
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

    cpVect swipePoint = cpv(point.y, point.x);
    if(fabsf(swipeStart.x - swipePoint.x) > gSwipeMinHorizontal
        && fabsf(swipeStart.y - swipePoint.y) < gSwipeMaxVertical)
        swiped = YES;
    
    cpFloat swipeActionDuration = [[GorillasConfig get] transitionDuration];
    if(swipeAction) {
        if(![swipeAction isDone])
            swipeActionDuration -= [swipeAction elapsed];
        [self stopAction:swipeAction];
        [swipeAction release];
    }
    [self runAction:swipeAction = [[MoveTo alloc] initWithDuration:swipeActionDuration
                                                          position:cpv(swipePoint.x - swipeStart.x, 0)]];
    
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
                                      position:cpvzero]];
    swipeStart = cpv(-1, -1);
    
    return kEventHandled;
}


-(BOOL) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(swipeStart.x == -1 && swipeStart.y == -1)
        return kEventIgnored;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[touch view]];
    
    CGSize winSize = [[Director sharedDirector] winSize];
    cpVect swipePoint = cpv(point.y, point.x);
    cpFloat swipeDist = swipePoint.x - swipeStart.x;
    swipeForward = swipeDist < 0;
    cpVect swipeTarget = cpv(winSize.width * (swipeForward? -1: 1), 0);
    
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
                                                              position:cpvzero]];
            
    swipeStart = cpv(-1, -1);
    
    return kEventHandled;
}


-(void) swipeDone:(id)sender {

    [invocation setArgument:&swipeForward atIndex:2];
    [invocation invoke];
}


-(void) dealloc {
    
    [[invocation target] release];
    [invocation release];
    invocation = nil;
    
    [swipeAction release];
    swipeAction = nil;
    
    [super dealloc];
}


@end
