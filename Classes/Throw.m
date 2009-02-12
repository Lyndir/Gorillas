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
//  Throw.m
//  Gorillas
//
//  Created by Maarten Billemont on 22/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "Throw.h"
#import "GorillasConfig.h"
#import "GorillasAppDelegate.h"
#define gMaxDiff 4


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
    
    smoke = [[ParticleMeteor alloc] init];
    [smoke setGravity:cpvzero];
    [smoke setPosition:cpvzero];
    [smoke setSpeed:5];
    [smoke setAngle:-90];
    [smoke setAngleVar:10];
    [smoke setLife:3];
    [smoke setEmissionRate:0];
    ccColorF startColor;
	startColor.r = 0.1f;
	startColor.g = 0.2f;
	startColor.b = 0.3f;
    startColor.a = 0.5f;
    [smoke setStartColor:startColor];
    ccColorF endColor;
	endColor.r = 0.0f;
	endColor.g = 0.0f;
	endColor.b = 0.0f;
    endColor.a = 0.3f;
    [smoke setEndColor:endColor];
    
    return self;
}


-(void) start {
    
    if(running)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already started." userInfo:nil];
    
    running = true;
    [super start];
    
    [target do:[Repeat actionWithAction:[RotateBy actionWithDuration:1
                                                               angle:360]
                                  times:(int)duration + 1]];
    [target setVisible:true];
    
    
    [[[[GorillasAppDelegate get] gameLayer] windLayer] registerSystem:smoke affectAngle:false];
    
    if([[GorillasConfig get] visualFx]) {
        [smoke setEmissionRate:30];
        [smoke setSize:10.0f * [target scale]];
        [smoke setSizeVar:5.0f * [target scale]];
        [[target parent] add:smoke];
    }
}


-(void) update: (ccTime) dt {

    if(!running)
        // We were stopped.
        return;
    
    // Wind influence.
    float w = [[[[GorillasAppDelegate get] gameLayer] windLayer] wind];
    
    // Calculate banana position.
    float g = [[GorillasConfig get] gravity];
    ccTime t = dt * duration;
    cpVect r = cpv((v.x + w * t * [[GorillasConfig get] windModifier]) * t + r0.x,
                   v.y * t - t * t * g / 2 + r0.y);

    // Figure out whether banana went off screen or hit something.
    BuildingsLayer *buildingsLayer = [[[GorillasAppDelegate get] gameLayer] buildingsLayer];
    CGSize winSize = [[Director sharedDirector] winSize];

    // Calculate the step size.
    cpVect rTest = [target position];
    cpVect dr = cpvsub(r, rTest);
    float drLen = cpvlength(dr);
    int step = 0, stepCount = drLen <= gMaxDiff? 1: (int) (drLen / gMaxDiff) + 1;
    cpVect rStep = stepCount == 1? dr: cpvmult(dr, 1.0f / stepCount);

    while(true) {
        // Increment rTest toward r.
        rTest = cpvadd(rTest, rStep);

        BOOL offScreen   = rTest.x < winSize.width * -0.5f || rTest.x > winSize.width * 1.5f
                        || rTest.y < 0 || rTest.y > winSize.height * 1.5f;
        BOOL hitGorilla  = [buildingsLayer hitsGorilla:rTest];
        BOOL hitBuilding = [buildingsLayer hitsBuilding:rTest];
        
        // Hitting something causes an explosion.
        if(hitBuilding || hitGorilla)
            [buildingsLayer explodeAt:rTest isGorilla:hitGorilla];
        
        // If it reached the floor, went off screen, or hit something; stop the banana.
        if([self isDone] || offScreen || hitBuilding || hitGorilla) {
            
            // Update score on miss.
            if(hitBuilding || offScreen)
                [[[[GorillasAppDelegate get] gameLayer] buildingsLayer] miss];
            
            // Hide banana.
            [[[[GorillasAppDelegate get] gameLayer] windLayer] unregisterSystem:smoke];
            [smoke setEmissionRate:0];
            [target setVisible:false];
            running = false;

            break;
        }
        
        if(++step >= stepCount)
            break;
    }
    
    [self scrollToCenter:r];
    
    [target setPosition:r];
    if([[GorillasConfig get] visualFx]) {
        [smoke setAngle:atan2f([smoke source].y - r.y,
                               [smoke source].x - r.x)
                                / (float)M_PI * 180.0f];
        [smoke setSource:r];
    } else if([smoke emissionRate])
        [smoke setEmissionRate:0];
    
    // Update HUD progress indicator.
    if(running) {
        float min = [[[[GorillasAppDelegate get] gameLayer] buildingsLayer] left];
        float max = [[[[GorillasAppDelegate get] gameLayer] buildingsLayer] right];
        [[[GorillasAppDelegate get] hudLayer] setProgress:(r.x - min) / max];
    } else {
        [self scrollToCenter:cpvzero];
        
        // Reset HUD progress.
        [[[GorillasAppDelegate get] hudLayer] setProgress:0];
        
        // Next Gorilla's turn.
        [buildingsLayer nextGorilla];
    }
}


-(void) scrollToCenter:(cpVect)r {
    
    Layer *panningLayer = [[[GorillasAppDelegate get] gameLayer] panningLayer];
    
    // MoveTo cpvzero happens without the gameScrollElapsed logic.
    if(r.x == 0 && r.y == 0) {
        [panningLayer do:[MoveTo actionWithDuration:[[GorillasConfig get] gameScrollDuration]
                                        position:cpvzero]];
        return;
    }
    
    CGSize winSize = [[Director sharedDirector] winSize];
    r = cpv(fmaxf(fminf(r.x, winSize.width), 0),
            fmaxf(fminf(r.y, winSize.height), 0));
    
    // Scroll to current point should take initial duration minus what has already elapsed to scroll to approach previous points.
    ccTime gameScrollElapsed = [gameScrollAction elapsed];

    // Stop the current scroll.
    if(gameScrollAction)
        [panningLayer stopAction:gameScrollAction];
    [gameScrollAction release];
    
    // Start a new scroll with an updated destination point.
    cpVect g = cpv(winSize.width / 2 - r.x, winSize.height / 2 - r.y);
    if(gameScrollElapsed < [[GorillasConfig get] gameScrollDuration])
        [panningLayer do:(gameScrollAction = [[MoveTo alloc] initWithDuration:[[GorillasConfig get] gameScrollDuration] - gameScrollElapsed
                                                                       position:g])];
    else {
        gameScrollAction = nil;
        [panningLayer setPosition:g];
    }
}


-(void) stop {
    
    duration = 0;
    running = false;
}


-(BOOL) isDone {
    
    return [super isDone] || !running;
}


-(void) dealloc {
    
    [smoke release];
    smoke = nil;
    
    [super dealloc];
}


@end
