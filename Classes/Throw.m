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
//  Throw.m
//  Gorillas
//
//  Created by Maarten Billemont on 22/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "Throw.h"
#import "ThrowController.h"
#import "GorillasAppDelegate.h"
#define maxDiff 4
#define recapTime 3


@interface Throw (Private)

-(void) throwEnded;

@end


@implementation Throw

@synthesize recap;//, focussed;


+(Throw *) actionWithVelocity: (CGPoint)velocity startPos: (CGPoint)startPos {
    
    return [[[Throw alloc] initWithVelocity: velocity startPos: startPos] autorelease];
}


-(Throw *) initWithVelocity: (CGPoint)velocity startPos: (CGPoint)startPos {
    
    v = velocity;
    r0 = startPos;
    float g = [[GorillasConfig get] gravity];
    
    ccTime t = (v.y + (float) sqrt(v.y * v.y + 2.0f * g * r0.y)) / g;

    if(!(self = [super initWithDuration:t]))
        return self;
    
    recap = 0;
    
    smoke = [[ParticleMeteor alloc] init];
    [smoke setGravity:CGPointZero];
    [smoke setPosition:CGPointZero];
    [smoke setSpeed:5];
    [smoke setAngle:-90];
    [smoke setAngleVar:10];
    [smoke setLife:3];
    [smoke setEmissionRate:0];
    ccColor4F startColor;
	startColor.r = 0.1f;
	startColor.g = 0.2f;
	startColor.b = 0.3f;
    startColor.a = 0.5f;
    [smoke setStartColor:startColor];
    ccColor4F endColor;
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
    
    [target runAction:
     [spinAction = [Repeat actionWithAction:[RotateBy actionWithDuration:1
                                                                   angle:360]
                                      times:(int)duration + 1] retain]];
    [target setVisible:YES];
    [target setTag:GorillasTagBananaFlying];
    
    
    [[[[GorillasAppDelegate get] gameLayer] windLayer] registerSystem:smoke affectAngle:NO];
    
    if([[GorillasConfig get] visualFx]) {
        [smoke setEmissionRate:30];
        [smoke setStartSize:15.0f * target.scale];
        [smoke setStartSizeVar:5.0f * target.scale];
        if(![smoke parent])
            [target.parent addChild:smoke];
        else
            [smoke resetSystem];
    }
}


-(void) update: (ccTime) dt {

    if(!running)
        // We were stopped.
        return;

    GameLayer *gameLayer = [GorillasAppDelegate get].gameLayer;
    CityLayer *cityLayer = gameLayer.cityLayer;
    //CGSize winSize = [[Director sharedDirector] winSize];
    
    // Wind influence.
    float w = gameLayer.windLayer.wind;
    
    // Calculate banana position.
    float g = [GorillasConfig get].gravity;
    ccTime t = elapsed;
    CGPoint r = ccp((v.x + w * t * [GorillasConfig get].windModifier) * t + r0.x,
                   v.y * t - t * t * g / 2 + r0.y);

    // Calculate the step size.
    CGPoint rTest = target.position;
    CGPoint dr = ccpSub(r, rTest);
    float drLen = ccpLength(dr);
    int step = 0, stepCount = drLen <= maxDiff? 1: (int) (drLen / maxDiff) + 1;
    CGPoint rStep = stepCount == 1? dr: ccpMult(dr, 1.0f / stepCount);
    BOOL offScreen = NO, hitGorilla = NO, hitBuilding = NO;
    
    if(!recap)
        // Only calculate when not recapping.
        do {
            // Increment rTest toward r.
            rTest = ccpAdd(rTest, rStep);
            
            CGRect field = [cityLayer fieldInSpaceOf:cityLayer];
            float min = field.origin.x;
            float max = field.origin.x + field.size.width;
            float top = field.origin.y + field.size.height;
            
            // Figure out whether banana went off screen or hit something.
            offScreen   = rTest.x < min || rTest.x > max
                       || rTest.y < 0   || rTest.y > top;
            hitGorilla  = [cityLayer hitsGorilla:rTest];
            hitBuilding = [cityLayer hitsBuilding:rTest];
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
        
        if ([gameLayer checkGameStillOn] || recap || ![GorillasConfig get].replay || !gameLayer.activeGorilla.human /*|| !focussed*/) {
            
            // Hitting something causes an explosion.
            if(hitBuilding || hitGorilla)
                [cityLayer explodeAt:r isGorilla:hitGorilla];

            if(recap)
                // Gorilla was revived; kill it again.
                [gameLayer.cityLayer.hitGorilla killDead];
            [gameLayer.windLayer unregisterSystem:smoke];
            smoke.emissionRate  = 0;
            target.visible      = NO;
            running             = NO;
            
            // Update game state.
            [gameLayer updateStateHitGorilla:hitGorilla hitBuilding:hitBuilding offScreen:offScreen throwSkill:throwSkill];
            
            if(skipped)
                [self throwEnded];
            
            else
                [cityLayer runAction:[Sequence actions:
                                      [DelayTime actionWithDuration:1],
                                      [CallFunc actionWithTarget:self selector:@selector(throwEnded)],
                                      nil]];
        }
        
        else {
            // Game is over but no recap done yet, start a recap.
            [gameLayer.cityLayer.bananaLayer setClearedGorilla:NO];
            [gameLayer.cityLayer.hitGorilla revive];
            [[GorillasAppDelegate get].hudLayer message:NSLocalizedString(@"message.killreplay", @"Kill Shot Replay") isImportant:YES];
            [[GorillasAppDelegate get].hudLayer setButtonImage:@"skip.png" callback:self :@selector(skip:)];
            recapr = r;
            recap = elapsed - recapTime;
            r = r0;
            
            [self start];
        }
    }
    
    //if(focussed) {
        if(recap && elapsed > recap) {
            [[GorillasAppDelegate get].gameLayer scaleTimeTo:0.5f duration:0.5f];
            [gameLayer.panningLayer scaleTo:1.5f];
            [gameLayer.panningLayer scrollToCenter:r horizontal:YES];
        } else
            [gameLayer.panningLayer scrollToCenter:r horizontal:[GorillasConfig get].followThrow];
    //}

    [target setPosition:r];
    if([[GorillasConfig get] visualFx]) {
        smoke.angle             = atan2f(smoke.centerOfGravity.y - r.y,
                                         smoke.centerOfGravity.x - r.x)
                                / (float)M_PI * 180.0f;
        smoke.centerOfGravity   = r;
    } else if([smoke emissionRate])
        [smoke setEmissionRate:0];
    
    if(running) {
        if(gameLayer.singlePlayer && gameLayer.activeGorilla.human) {
            // Singleplayer game with human turn is still running; update the skill counter.
            throwSkill = elapsed / 10;
            [[[GorillasAppDelegate get] hudLayer] updateHudWithScore:0 skill:throwSkill];
        }
    }
}


-(void) throwEnded {
    
    [[[[GorillasAppDelegate get] gameLayer] windLayer] unregisterSystem:smoke];
    [target stopAction:spinAction];
    
    //if(focussed) {
        [[GorillasAppDelegate get].gameLayer.panningLayer scrollToCenter:CGPointZero horizontal:NO];
        [[GorillasAppDelegate get].gameLayer scaleTimeTo:1.0f duration:0.5f];
    //}

    [[ThrowController get] throwEnded];
}    


-(void) skip: (id) caller {
    
    elapsed = recap + recapTime;
    skipped = YES;
}


-(void) stop {

    duration = 0;
    running = NO;
    
    [[GorillasAppDelegate get].gameLayer.activeGorilla setActive:NO];
    [target setTag:GorillasTagBananaNotFlying];
}


-(BOOL) isDone {

    return [super isDone] || !running;
}


-(void) dealloc {
    
    [smoke release];
    smoke = nil;
    
    [spinAction release];
    spinAction = nil;
    
    [super dealloc];
}


@end
