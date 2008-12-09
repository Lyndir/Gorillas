/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
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
//  Throw.m
//  Gorillas
//
//  Created by Maarten Billemont on 22/11/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "Throw.h"
#import "GorillasConfig.h"
#import "GorillasAppDelegate.h"


@implementation Throw


+(Throw *) actionWithVelocity: (cpVect)velocity startPos: (cpVect)startPos {
    
    return [[[Throw alloc] initWithVelocity: velocity startPos: startPos] autorelease];
}


-(Throw *) initWithVelocity: (cpVect)velocity startPos: (cpVect)startPos {
    
    v = velocity;
    r0 = startPos;
    float g = [[GorillasConfig get] gravity];
    
    ccTime t = (v.y + sqrt(v.y * v.y + 2.0 * g * r0.y)) / g;

    if(!(self = [super initWithDuration:t]))
        return self;
    
    return self;
}


-(void) start {
    
    running = true;
    [super start];
    
    [target do:[Repeat actionWithAction:[RotateBy actionWithDuration:1 angle:360] times:(int)duration + 1]];
    [target setVisible:true];
}


-(void) update: (ccTime) dt {

    if(!running)
        // We were stopped.
        return;
    
    // Calculate banana position.
    float g = [[GorillasConfig get] gravity];
    ccTime t = dt * duration;
    cpVect r = cpv(v.x * t + r0.x,
                   v.y * t - t * t * g / 2.0 + r0.y);
    
    [target setPosition:r];
    
    // Figure out whether banana went off screen or hit something.
    BuildingsLayer *buildingsLayer = [[[GorillasAppDelegate get] gameLayer] buildings];
    cpVect parent = [buildingsLayer position];
    CGSize screen = [[Director sharedDirector] winSize].size;
    cpVect onScreen = cpv(r.x + parent.x, r.y - parent.y);

    BOOL offScreen = onScreen.x < 0 || onScreen.x > screen.width;
    BOOL hitBuilding = [buildingsLayer hitsBuilding:r];
    
    // Hitting something causes an explosion.
    if(hitBuilding)
        [buildingsLayer explodeAt:r];
    
    // If it reached the floor, went off screen, or hit something; stop the banana.
    if([self isDone] || offScreen || hitBuilding) {

        // Update score on miss.
        if([target visible] && (hitBuilding || offScreen))
            [[[[GorillasAppDelegate get] gameLayer] buildings] miss];
        
        // Hide banana.
        [target stopAction:self];
        [target setVisible:false];
        [self stop];
                
        // Next Gorilla's turn.
        [buildingsLayer nextGorilla];
    }
}


-(void) stop {
    
    duration = 0;
    running = false;
}


-(BOOL) isDone {
    
    return [super isDone] || !running;
}


@end
