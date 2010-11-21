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
//  PanningLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 15/02/09.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//

#import "PanningLayer.h"
#import "GorillasAppDelegate.h"


@implementation PanningLayer


-(id) init {
    
    if (!(self = [super init]))
		return self;
    
    self.anchorPoint    = ccp(0.5f, 0.0f);
    
    self.isTouchEnabled = YES;
    initialDist         = -1;
    
    return self;
}


-(void) registerWithTouchDispatcher {
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}


-(void) reset {
    
    if (self.scale != 1) {
        if (scaleAction)
            [self stopAction:[scaleAction autorelease]];
        
        [self runAction:scaleAction = [[CCScaleTo alloc] initWithDuration:[[GorillasConfig get].transitionDuration floatValue] scale:1.0f]];
    }
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if([[event allTouches] count] != 2)
        return NO;
    
    NSArray *touchesArray = [[event allTouches] allObjects];
    UITouch *from = [touchesArray objectAtIndex:0];
    UITouch *to = [touchesArray objectAtIndex:1];
    CGPoint pFrom = [from locationInView: [from view]];
    CGPoint pTo = [to locationInView: [to view]];
    
    initialScale = self.scale;
    initialDist = fabsf(pFrom.y - pTo.y);
    
    return YES;
}


- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if([[event allTouches] count] != 2)
        return;
    
    if(initialDist < 0)
        return;

    NSArray *touchesArray = [[event allTouches] allObjects];
    UITouch *from = [touchesArray objectAtIndex:0];
    UITouch *to = [touchesArray objectAtIndex:1];
    CGPoint pFrom = [from locationInView: [from view]];
    CGPoint pTo = [to locationInView: [to view]];
    
    CGFloat newDist = fabsf(pFrom.y - pTo.y);
    CGFloat newScale = initialScale * (newDist / initialDist);
    CGFloat limitedScale = fmaxf(fminf(newScale, 1.1f), 0.8f);
    if(limitedScale != newScale) {
        newScale = limitedScale;
        initialDist = newDist;
        initialScale = newScale;
    }
    
    [self scaleTo:newScale limited:YES];
}


- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if(initialDist < 0)
        return;
    
    [self setScale:initialScale];
    initialDist = -1;
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if(initialDist < 0)
        return;
    
    initialDist = -1;
}


-(void) scaleTo:(CGFloat)newScale {
    
    [self scaleTo:newScale limited:NO];
}


-(void) scaleTo:(CGFloat)newScale limited:(BOOL)limited {
    
    if (limited)
        newScale = fmaxf(fminf(newScale, 1.1f), 0.8f);
    
    CGFloat duration = [[GorillasConfig get].transitionDuration floatValue];
    if(scaleAction != nil && ![scaleAction isDone]) {
        duration -= [scaleAction elapsed];
        [self stopAction:scaleAction];
    }
    [scaleAction release];
    [self runAction:scaleAction = [[CCScaleTo alloc] initWithDuration:duration
                                                                scale:newScale]];
}


-(void) scrollToCenter:(CGPoint)r horizontal:(BOOL)horizontal {
    
    CGPoint pos = r;
    if (!CGPointEqualToPoint(r, CGPointZero)) {
        // Save and reset position so it doesn't affect coordinate space conversions.
        CGPoint savePosition = self.position;
        self.position = CGPointZero;
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        GameLayer *gameLayer    = [GorillasAppDelegate get].gameLayer;
        CityLayer *cityLayer    = gameLayer.cityLayer;
        
        // Figure out where (in world coordinates) the buildings start and end.
        CGRect field            = [cityLayer fieldInSpaceOf:nil];
        CGFloat left            = field.origin.x;
        CGFloat right           = field.origin.x + field.size.width;
        CGFloat bottom          = field.origin.y;
        CGFloat top             = field.origin.y + field.size.height;
        
        // Limit the camera center (in world coordinates) inside the field.
        r                       = [cityLayer convertToWorldSpace:r];
        CGPoint middle          = ccp(winSize.width / 2, winSize.height / 2);
        CGPoint min             = ccpAdd(ccp(left, bottom), middle);
        CGPoint max             = ccpSub(ccp(right, top), middle);
        
        if(horizontal)
            r                   = ccp(fmaxf(fminf(r.x, max.x), min.x),
                                      fmaxf(fminf(r.y, max.y), min.y));
        else {
            r.x                 = middle.x;
            if(r.y < middle.y * 2 * 0.8f)
                r.y             = middle.y;
        }
        
        // Start a new scroll with an updated destination point.
        pos                     = ccpSub(ccp(self.contentSize.width / 2,
                                             self.contentSize.height / 2),
                                         [self.parent convertToNodeSpace:r]);

        // Restore position.
        self.position = savePosition;
    }
    
    // Stop the current scroll.
    ccTime scrollActionElapsed = [scrollAction isDone]? 0: scrollAction.elapsed;
    
    // Scroll to current point should take initial duration minus what has already elapsed to scroll to approach previous points.
    if(!scrollAction || [scrollAction isDone]) {
        if(scrollAction)
            [self stopAction: scrollAction];
        [scrollAction release];
        
        [self runAction:(scrollAction = [[MovingTo alloc] initWithDuration:[[GorillasConfig get].gameScrollDuration floatValue] - scrollActionElapsed
                                                                position:pos])];
    }
    else
        [scrollAction updatePosition:pos];
}


-(void) dealloc {
    
    [scrollAction release];
    scrollAction = nil;
    
    [scaleAction release];
    scaleAction = nil;
    
    [super dealloc];
}


@end
