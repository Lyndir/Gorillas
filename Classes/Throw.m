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
#define maxDiff 4
#define recapTime 3


@interface Throw (Private)

-(void) nextTurn;
-(void) throwEnded;

@end

@implementation Throw

@synthesize recap;


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
    
    endCount = [[[GorillasAppDelegate get] gameLayer] singlePlayer]? -1: 3;
    
    recap = 0;
    
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
    
    running = YES;
    skipped = NO;
    [super start];
    
    if(spinAction) {
        [target stopAction:spinAction];
        [spinAction release];
    }
    
    [target do:
     [spinAction = [Repeat actionWithAction:[RotateBy actionWithDuration:1
                                                                   angle:360]
                                      times:(int)duration + 1] retain]];
    [target setVisible:YES];
    [target setTag:GorillasTagBananaFlying];
    
    
    [[[[GorillasAppDelegate get] gameLayer] windLayer] registerSystem:smoke affectAngle:NO];
    
    if([[GorillasConfig get] visualFx]) {
        [smoke setEmissionRate:30];
        [smoke setSize:15.0f * [target scale]];
        [smoke setSizeVar:10.0f * [target scale]];
        if(![smoke parent])
            [[GorillasAppDelegate get].gameLayer.buildingsLayer add:smoke];
        else
            [smoke resetSystem];
    }
}


-(void) update: (ccTime) dt {

    if(!running)
        // We were stopped.
        return;

    GameLayer *gameLayer = [[GorillasAppDelegate get] gameLayer];
    BuildingsLayer *buildingsLayer = [gameLayer buildingsLayer];
    CGSize winSize = [[Director sharedDirector] winSize];
    
    // Wind influence.
    float w = [[gameLayer windLayer] wind];
    
    // Calculate banana position.
    float g = [[GorillasConfig get] gravity];
    ccTime t = elapsed;
    cpVect r = cpv((v.x + w * t * [[GorillasConfig get] windModifier]) * t + r0.x,
                   v.y * t - t * t * g / 2 + r0.y);

    // Calculate the step size.
    cpVect rTest = [target position];
    cpVect dr = cpvsub(r, rTest);
    float drLen = cpvlength(dr);
    int step = 0, stepCount = drLen <= maxDiff? 1: (int) (drLen / maxDiff) + 1;
    cpVect rStep = stepCount == 1? dr: cpvmult(dr, 1.0f / stepCount);
    BOOL offScreen = NO, hitGorilla = NO, hitBuilding = NO;
    
    if(!recap)
        // Only calculate when not recapping.
        do {
            // Increment rTest toward r.
            rTest = cpvadd(rTest, rStep);
            
            float min = [buildingsLayer left];
            float max = [buildingsLayer right];
            float top = winSize.height * 2;
            if([gameLayer.panningLayer position].x == 0) {
                cpFloat scale = [gameLayer.panningLayer scale];
                min = 0;
                max = winSize.width / scale;
            }
            
            // Figure out whether banana went off screen or hit something.
            offScreen   = rTest.x < min || rTest.x > max
            || rTest.y < 0 || rTest.y > top;
            hitGorilla  = [buildingsLayer hitsGorilla:rTest];
            hitBuilding = [buildingsLayer hitsBuilding:rTest];
        } while(++step < stepCount && !(hitBuilding || hitGorilla || offScreen));

    else
        // Stop recapping when reached recap r.
        if(elapsed >= recap + recapTime) {
            hitGorilla = YES;
            rTest = recapr;
        }
    
    // If it reached the floor, went off screen, or hit something; stop the banana.
    if([self isDone] || offScreen || hitBuilding || hitGorilla) {
        r = rTest;
        
        if ([gameLayer checkGameStillOn] || recap || ![GorillasConfig get].replay) {
            
            // Hitting something causes an explosion.
            if(hitBuilding || hitGorilla)
                [buildingsLayer explodeAt:r isGorilla:hitGorilla];

            if(recap)
                // Gorilla was revived; kill it again.
                [gameLayer.buildingsLayer.hitGorilla killDead];
            [[gameLayer windLayer] unregisterSystem:smoke];
            [smoke setEmissionRate:0];
            [target setVisible:NO];
            running = NO;
            
            // Update game state.
            [gameLayer updateStateHitGorilla:hitGorilla hitBuilding:hitBuilding offScreen:offScreen throwSkill:throwSkill];
        }
        
        else {
            // Game is over but no recap done yet, start a recap.
            [gameLayer.buildingsLayer.bananaLayer setClearedGorilla:NO];
            [gameLayer.buildingsLayer.hitGorilla revive];
            [[GorillasAppDelegate get].hudLayer message:@"Kill Shot Replay" isImportant:YES];
            [[GorillasAppDelegate get].hudLayer setButtonString:@"Skip" callback:self :@selector(skip:)];
            recapr = r;
            recap = elapsed - recapTime;
            r = r0;
            
            [self start];
        }
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
    
    if(running) {
        if(gameLayer.singlePlayer && gameLayer.activeGorilla.human) {
            // Singleplayer game with human turn is still running; update the skill counter.
            throwSkill = elapsed / 10;
            [[[GorillasAppDelegate get] hudLayer] updateHudWithScore:0 skill:throwSkill];
        }
    } else {
        if(skipped)
            [self throwEnded];

        else
            [buildingsLayer do:[Sequence actions:
                                [DelayTime actionWithDuration:1.5f],
                                [CallFunc actionWithTarget:self selector:@selector(throwEnded)],
                                nil]];
    }
}


-(void) throwEnded {
    
    GameLayer *gameLayer = [[GorillasAppDelegate get] gameLayer];
    [[[[GorillasAppDelegate get] gameLayer] windLayer] unregisterSystem:smoke];
    [target stopAction:spinAction];
    
    // End of the throw.
    [self scrollToCenter:cpvzero];
    [[GorillasAppDelegate get].gameLayer scaleTimeTo:1 duration:0.5f];

    NSUInteger liveHumans = 0;
    for(GorillaLayer *gorilla in gameLayer.gorillas)
        if([gorilla human] && [gorilla alive])
            ++liveHumans;
    
    if(gameLayer.activeGorilla.human && liveHumans > 1) {
        if([[GorillasConfig get] multiplayerFlip])
            [gameLayer do:[RotateTo actionWithDuration:[[GorillasConfig get] transitionDuration]
                                                 angle:((int) [gameLayer rotation] + 180) % 360]];
        
        if(endCount) {
            for(int count = endCount; count > 0; --count)
                [gameLayer message:[NSString stringWithFormat:@"%d ..", count]];

            [gameLayer message:@"Go .." callback:self :@selector(nextTurn)];
            return;
        }
    }
    
    [self nextTurn];
}


-(void) nextTurn {

    if(recap)
        [[GorillasAppDelegate get].hudLayer dismissMessage];
    
    [target setTag:GorillasTagBananaNotFlying];
    [[GorillasAppDelegate get].gameLayer.buildingsLayer nextGorilla];
}


-(void) scrollToCenter:(cpVect)r {
    
    CGSize winSize = [[Director sharedDirector] winSize];
    PanningLayer *panningLayer = [[[GorillasAppDelegate get] gameLayer] panningLayer];
    
    // MoveTo cpvzero happens without the gameScrollElapsed logic.
    if(r.x == 0 && r.y == 0) {
        if([panningLayer position].x != 0 || [panningLayer position].y != 0)
            [panningLayer do:[MoveTo actionWithDuration:[[GorillasConfig get] gameScrollDuration]
                                               position:cpvzero]];
        
        return;
    }
    
    // Figure out where the buildings start and end.
    // Use that for camera limits, take scaling into account.
    float min = [[[[GorillasAppDelegate get] gameLayer] buildingsLayer] left];
    float max = [[[[GorillasAppDelegate get] gameLayer] buildingsLayer] right];
    float top = winSize.height * 2;
    cpFloat scale = [panningLayer scale];
    r = cpvmult(r, scale);
    min *= scale;
    max *= scale;
    top *= scale;
    
    if(recap && elapsed > recap) {
        [panningLayer scaleTo:1.5f];
        [[GorillasAppDelegate get].gameLayer scaleTimeTo:0.5f duration:0.5f];
    }
    
    if([[GorillasConfig get] followThrow]
       || (recap && elapsed > recap)) {
        r = cpv(fmaxf(fminf(r.x, max - winSize.width / 2), min + winSize.width / 2),
                fmaxf(fminf(r.y, top - winSize.height / 2), winSize.height / 2));
    }
    
    else {
        r.x = winSize.width / 2;
        if(r.y < winSize.height * 0.8f)
            r.y = winSize.height / 2;
    }
    
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


-(void) skip: (id) caller {
    
    elapsed = recap + recapTime;
    skipped = YES;
}


-(void) stop {

    duration = 0;
    running = NO;
}


-(BOOL) isDone {

    return [super isDone] || !running;
}


-(void) dealloc {
    
    [smoke release];
    smoke = nil;
    
    [spinAction release];
    spinAction = nil;
    
    [gameScrollAction release];
    gameScrollAction = nil;
    
    [super dealloc];
}


@end
