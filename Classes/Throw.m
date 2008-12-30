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
    
    ccTime t = (v.y + (float) sqrt(v.y * v.y + 2.0f * g * r0.y)) / g;

    if(!(self = [super initWithDuration:t]))
        return self;
    
    return self;
}


-(void) start {
    
    running = true;
    [super start];
    
    [target do:[Repeat actionWithAction:[RotateBy actionWithDuration:1 angle:360] times:(int)duration + 1]];
    [target setVisible:true];
    
    [smoke release];
    smoke = [[ParticleMeteor alloc] initWithTotalParticles:100];
    [smoke setPosition:[target position]];
    [smoke setGravity:cpv(0,0)];
    [smoke setSize:15.0f];
    //[smoke setSpeed:50];
    [smoke setAngleVar:0];
    [smoke setLife:0.1f];
    ccColorF sCol = [smoke startColor];
    sCol.a = 0.05f;
    [smoke setStartColor:sCol];
    [[target parent] add:smoke];
}


-(void) update: (ccTime) dt {

    if(!running)
        // We were stopped.
        return;
    
    // Wind influence.
    float w = [[[[GorillasAppDelegate get] gameLayer] wind] wind];
    
    // Calculate banana position.
    float g = [[GorillasConfig get] gravity];
    ccTime t = dt * duration;
    cpVect r = cpv((v.x + w * t * [[GorillasConfig get] windModifier]) * t + r0.x,
                   v.y * t - t * t * g / 2.0f + r0.y);
    
    [smoke setGravity:cpv(([smoke position].x - r.x) * 50,
                          ([smoke position].y - r.y) * 50)];
    /*float m = 1.0f;
    if([smoke position].y > r.y)
        m = -1.0f;
    [smoke setAngle:(asinf(m * [smoke gravity].x / (sqrtf(powf([smoke gravity].x, 2) + powf([smoke gravity].y, 2)))) / (float) M_PI * 180.0f)];
    [smoke setGravity:cpv(0, 0)];*/
    [smoke setPosition:[target position]];
    [target setPosition:r];
    
    // Update HUD progress indicator.
    float min = [[[[GorillasAppDelegate get] gameLayer] buildings] left];
    float max = [[[[GorillasAppDelegate get] gameLayer] buildings] right];
    [[[GorillasAppDelegate get] hudLayer] setProgress:(r.x - min) / max];
    
    // Figure out whether banana went off screen or hit something.
    BuildingsLayer *buildingsLayer = [[[GorillasAppDelegate get] gameLayer] buildings];
    cpVect parent = [buildingsLayer position];
    CGSize screen = [[Director sharedDirector] winSize].size;
    cpVect onScreen = cpv(r.x + parent.x, r.y - parent.y);

    BOOL offScreen = onScreen.x < 0 || onScreen.x > screen.width;
    BOOL hitGorilla = [buildingsLayer hitsGorilla:r], hitBuilding = [buildingsLayer hitsBuilding:r];
    
    // Hitting something causes an explosion.
    if(hitBuilding || hitGorilla)
        [buildingsLayer explodeAt:r isGorilla:hitGorilla];
    
    // If it reached the floor, went off screen, or hit something; stop the banana.
    if([self isDone] || offScreen || hitBuilding || hitGorilla) {

        // Reset HUD progress.
        [[[GorillasAppDelegate get] hudLayer] setProgress: 0];
        
        // Update score on miss.
        if(hitBuilding || offScreen)
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
    [[smoke parent] remove:smoke];
    [smoke release];
    smoke = nil;
}


-(BOOL) isDone {
    
    return [super isDone] || !running;
}


@end
