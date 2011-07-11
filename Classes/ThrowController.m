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
//  ThrowController.m
//  Gorillas
//
//  Created by Maarten Billemont on 02/04/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "ThrowController.h"
#import "GorillaLayer.h"
#import "GorillasAppDelegate.h"

#define minDiff 4


@implementation ThrowController
@synthesize throw = _throw, banana = _banana;

-(void) throwEnded {
    
    self.banana.tag = GorillasTagBananaNotFlying;
    self.banana     = nil;
    
    // If the throw ended with a hit, explode.
    if (self.throw.endCondition == ThrowEndHitGorilla)
        [[GorillasAppDelegate get].gameLayer.cityLayer explodeAt:self.throw.endPoint isGorilla:YES];
    else if (self.throw.endCondition == ThrowEndHitBuilding)
        [[GorillasAppDelegate get].gameLayer.cityLayer explodeAt:self.throw.endPoint isGorilla:NO];
    
    // Update game state.
    [[GorillasAppDelegate get].gameLayer updateStateForThrow:self.throw withSkill:self.throw.duration / 10];
    
    NSUInteger liveHumans = 0;
    for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
        if(gorilla.human && gorilla.alive)
            ++liveHumans;
    
    if([GorillasAppDelegate get].gameLayer.activeGorilla.human && liveHumans > 1) {
        [[GorillasAppDelegate get].uiLayer message:l(@"message.nextplayer", @"Next player ..")];
        
        if ([[GorillasConfig get].voice boolValue])
            [[GorillasAudioController get] playEffectNamed:@"Next_Player"];
        
        [self performSelector:@selector(nextTurn) withObject:nil afterDelay:2];
        return;
    }
    
    [self nextTurn];
}

-(void) nextTurn {
    
    [[GorillasAppDelegate get].hudLayer dismissMessage];
    
    [[GorillasAppDelegate get].gameLayer.cityLayer nextGorilla];
}

- (void)throwFrom:(GorillaLayer *)gorilla normalizedVelocity:(CGPoint)velocity {
    
    // De-normalize velocity.
    CGPoint v = ccpCompMult(velocity, ccpFromSize([CCDirector sharedDirector].winSize));

    // Determine projectile.
    self.banana = [[GorillasAppDelegate get].gameLayer.cityLayer.bananaLayer bananaForThrowFrom:gorilla];
    [GorillasAppDelegate get].gameLayer.cityLayer.bananaLayer.clearedGorilla = NO;

    // Determine throw endpoint.
    ccTime t = 0;
    while (! (self.throw = [ThrowController calculateThrowFrom:gorilla.position withVelocity:v afterTime:t]).endCondition)
        t += 0.01f;
    if (self.throw.endCondition)
        dbg(@"Throw: %@ -> %@, v = %@ ends after t = %f, condition: %d",
            NSStringFromCGPoint(gorilla.position), NSStringFromCGPoint(self.throw.endPoint), NSStringFromCGPoint(v),
            self.throw.duration, self.throw.endCondition);
    
    [GorillasAppDelegate get].gameLayer.cityLayer.bananaLayer.clearedGorilla = NO;
    
    // Begin throw.
    [gorilla threw:v];
    [self.banana runAction:[ThrowAction actionWithVelocity:v duration:t]];
    [[GorillasAppDelegate get].gameLayer.cityLayer throwFrom:gorilla withVelocity:v];
}

+ (Throw)calculateThrowFrom:(CGPoint)r0 withVelocity:(CGPoint)v afterTime:(ccTime)t {
    
    GameLayer *gameLayer = [GorillasAppDelegate get].gameLayer;
    CityLayer *cityLayer = gameLayer.cityLayer;
    
    // Wind influence.
    float w = gameLayer.windLayer.wind;
    
    // Calculate banana position.
    NSUInteger g = [[GorillasConfig get].gravity unsignedIntValue];
    CGPoint r = ccp((v.x + w * t * [[GorillasConfig get].windModifier floatValue]) * t + r0.x,
                    v.y * t - t * t * g / 2 + r0.y);
    
    // Check for events.
    CGRect field = [cityLayer fieldInSpaceOf:cityLayer];
    float min = field.origin.x;
    float max = field.origin.x + field.size.width;
    float top = field.origin.y + field.size.height;
    
    // Figure out whether banana went off screen or hit something.
    ThrowEnd endCondition = 0;
    if ([cityLayer hitsBuilding:r])
        endCondition = ThrowEndHitBuilding;
    else if ([cityLayer hitsGorilla:r])
        endCondition = ThrowEndHitGorilla;
    else if (r.x < min || r.x > max || r.y < 0   || r.y > top)
        endCondition = ThrowEndOffScreen;
    
    return (Throw){r, endCondition, t};
}


+(ThrowController *) get {
    
    static ThrowController *sharedThrowController = nil;
    if(sharedThrowController == nil)
        sharedThrowController = [[ThrowController alloc] init];
    
    return sharedThrowController;
}

@end
