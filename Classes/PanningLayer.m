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
//  PanningLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 15/02/09.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//

#import "PanningLayer.h"
#import "GorillasConfig.h"


@implementation PanningLayer


-(id) init {
    
    if (!(self = [super init]))
		return self;
    
    isTouchEnabled  = YES;
    initialDist    = -1;
    
    return self;
}


-(void) reset {

    if ([self scale] != 1) {
        if (scaleAction) {
            [self stopAction:scaleAction];
            [scaleAction release];
        }
        
        [self do:scaleAction = [[ScaleTo alloc] initWithDuration:[[GorillasConfig get] transitionDuration]
                                                           scale:1]];
    }
}


-(BOOL) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if([[event allTouches] count] != 2)
        return [self ccTouchesCancelled:touches withEvent:event];
    
    NSArray *touchesArray = [[event allTouches] allObjects];
    UITouch *from = [touchesArray objectAtIndex:0];
    UITouch *to = [touchesArray objectAtIndex:1];
    CGPoint pFrom = [from locationInView: [from view]];
    CGPoint pTo = [to locationInView: [to view]];
    
    initialScale = [self scale];
    initialDist = fabsf(pFrom.y - pTo.y);
    
    return kEventHandled;
}


-(BOOL) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if([[event allTouches] count] != 2)
        return [self ccTouchesCancelled:touches withEvent:event];

    if(initialDist < 0)
        return [self ccTouchesBegan:touches withEvent:event];
    
    NSArray *touchesArray = [[event allTouches] allObjects];
    UITouch *from = [touchesArray objectAtIndex:0];
    UITouch *to = [touchesArray objectAtIndex:1];
    CGPoint pFrom = [from locationInView: [from view]];
    CGPoint pTo = [to locationInView: [to view]];

    cpFloat newDist = fabsf(pFrom.y - pTo.y);
    cpFloat newScale = initialScale * (newDist / initialDist);
    cpFloat limitedScale = fmaxf(fminf(newScale, 1.1f), 0.8f);
    if(limitedScale != newScale) {
        newScale = limitedScale;
        initialDist = newDist;
        initialScale = newScale;
    }

    [self scaleTo:newScale];
    
    return kEventHandled;
}


-(BOOL) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

    if(initialDist < 0)
        return kEventIgnored;
    
    [self setScale:initialScale];
    initialDist = -1;
    
    return kEventHandled;
}


-(BOOL) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(initialDist < 0)
        return kEventIgnored;
    
    initialDist = -1;
    
    return kEventHandled;
}


-(void) scaleTo:(cpFloat)newScale {
    
    cpFloat duration = [GorillasConfig get].transitionDuration;
    if(scaleAction != nil && ![scaleAction isDone]) {
        duration -= [scaleAction elapsed];
        [self stopAction:scaleAction];
    }
    [scaleAction release];
    [self do:scaleAction = [[ScaleTo alloc] initWithDuration:duration
                                                       scale:newScale]];
}


-(void) dealloc {
    
    [scaleAction release];
    scaleAction = nil;
    
    [super dealloc];
}


@end
