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
    
    self.touchEnabled   = YES;
    initialDist         = -1;
    
    [self runAction:tween = [[PearlCCAutoTween alloc] initWithDuration:0.5f]];
    tween.tag           = kCCActionTagIgnoreTimeScale;
    
    targetScale         = self.scale;
    
    return self;
}


-(void) registerWithTouchDispatcher {
    
    [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:NO];
}


-(void) reset {
    
    [self scaleTo:1.0f];
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    initialDist = -1;
    
    return YES;
}


- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if([[event allTouches] count] != 2)
        return;
    
    NSArray *touchesArray = [[event allTouches] allObjects];
    UITouch *fromTouch = [touchesArray objectAtIndex:0];
    UITouch *toTouch = [touchesArray objectAtIndex:1];
    CGPoint from  = [fromTouch locationInView: [fromTouch view]];
    CGPoint to  = [toTouch locationInView: [toTouch view]];
    
    if (initialDist < 0) {
        initialDist = ccpDistance(from, to);
        initialScale = self.scale;
    } else {
        CGFloat newDist = ccpDistance(from, to);
        CGFloat newScale = initialScale * (newDist / initialDist);
        
        [self scaleTo:newScale];
    }
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
    
    [self scaleTo:newScale limited:YES];
}


-(void) scaleTo:(CGFloat)newScale limited:(BOOL)limited {
    
    if (limited)
        newScale = fmaxf(fminf(newScale, 1.1f), 0.8f);
    
    [tween tweenKeyPath:@"scale" to:targetScale = newScale];
}


-(void) scrollToCenter:(CGPoint)r horizontal:(BOOL)horizontal {
    
    CGPoint pos = r;
    if (!CGPointEqualToPoint(r, CGPointZero)) {
        // Save and reset position so it doesn't affect coordinate space conversions.
        CGPoint savePosition    = self.position;
        CGFloat saveScale       = self.scale;
        self.position           = CGPointZero;
        self.scale              = targetScale;
        
        CGSize winSize          = [CCDirector sharedDirector].winSize;
        GameLayer *gameLayer    = [GorillasAppDelegate get].gameLayer;
        CityLayer *cityLayer    = gameLayer.cityLayer;
        
        // Figure out where (in world coordinates) the buildings start and end.
        CGRect field            = [cityLayer fieldInSpaceOf:nil];
        CGFloat left            = field.origin.x;
        CGFloat right           = field.origin.x + field.size.width;
        CGFloat bottom          = field.origin.y;
        CGFloat top             = CGFLOAT_MAX;
        
        // Limit the camera center (in world coordinates) inside the field.
        r                       = [cityLayer convertToWorldSpace:r];
        CGPoint middle          = ccp(winSize.width / 2, winSize.height / 2);
        
        if(horizontal) {
            CGPoint min             = ccpAdd(ccp(left, bottom), middle);
            CGPoint max             = ccpSub(ccp(right, top), middle);
            r                   = ccp(fmaxf(fminf(r.x, max.x), min.x),
                                      fmaxf(fminf(r.y, max.y), min.y));
        } else {
            r.x                 = middle.x;
            if(r.y < middle.y * 2 * 0.8f)
                r.y             = middle.y;
        }
        
        // Start a new scroll with an updated destination point.
        pos                     = ccpSub(ccp(winSize.width / 2, winSize.height / 2),
                                         [self.parent convertToNodeSpace:r]);
        
        // Restore position.
        self.position           = savePosition;
        self.scale              = saveScale;
    }
    
    [tween tweenKeyPath:@"position" to:pos.x
              valueSize:sizeof(CGPoint) valueOffset:offsetof(CGPoint, x)];
    [tween tweenKeyPath:@"position" to:pos.y
              valueSize:sizeof(CGPoint) valueOffset:offsetof(CGPoint, y)];
}


-(void) dealloc {
    
    [tween release];
    tween = nil;
    
    [super dealloc];
}


@end
