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

@interface ThrowController()

- (void)doThrowIsReplay:(BOOL)isReplay;
- (void)skipThrow:(id)sender;

@end

@implementation ThrowController

- (void)throwEnded {

    [[GorillasAppDelegate get].gameLayer scaleTimeTo:1.0f];
    [[GorillasAppDelegate get].gameLayer.panningLayer scrollToCenter:CGPointZero horizontal:YES];
    [[GorillasAppDelegate get].gameLayer.panningLayer scaleTo:1.0f limited:YES];

    self.banana.tag = GorillasTagBananaNotFlying;
    self.banana = nil;

    if (self.wasReplay)
        [[GorillasAppDelegate get].hudLayer dismissMessage];

    if (self.needReplay) {
        self.needReplay = NO;
        [self doThrowIsReplay:YES];
        return;
    }

    // If the throw ended with a hit, explode.
    if (self.throw.endCondition == ThrowEndHitGorilla)
        [[GorillasAppDelegate get].gameLayer.cityLayer explodeAt:self.throw.endPoint isGorilla:YES];
    else if (self.throw.endCondition == ThrowEndHitBuilding)
        [[GorillasAppDelegate get].gameLayer.cityLayer explodeAt:self.throw.endPoint isGorilla:NO];

    // Update game state.
    [[GorillasAppDelegate get].gameLayer updateStateForThrow:self.throw withSkill:self.throw.duration / 10];

    NSUInteger liveHumans = 0;
    for (GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
        if (gorilla.human && gorilla.alive)
            ++liveHumans;

    if ([GorillasAppDelegate get].gameLayer.activeGorilla.human && liveHumans > 1) {
        [[GorillasAppDelegate get].uiLayer message:PearlLocalize( @"message.nextplayer" )];

        if ([[GorillasConfig get].voice boolValue])
            [[GorillasAudioController get] playEffectNamed:@"Next_Player"];

        [self performSelector:@selector(nextTurn) withObject:nil afterDelay:2];
        return;
    }

    [self nextTurn];
}

- (void)nextTurn {

    [[GorillasAppDelegate get].gameLayer.cityLayer nextGorilla];
}

- (void)throwFrom:(GorillaLayer *)gorilla normalizedVelocity:(CGPoint)velocity {

    self.gorilla = gorilla;

    // De-normalize velocity.
    self.velocity = ccpCompMult( velocity, ccpFromSize( [CCDirector sharedDirector].winSize ) );

    // Determine projectile.
    [GorillasAppDelegate get].gameLayer.cityLayer.bananaLayer.clearedGorilla = NO;

    // Determine throw endpoint.
    self.duration = 0;
    while (!(self.throw = [ThrowController calculateThrowFrom:gorilla.position withVelocity:self.velocity
                                                    afterTime:self.duration]).endCondition)
        self.duration += 0.01f;
    if (self.throw.endCondition)
    dbg(@"Throw: %@ -> %@, v = %@ ends after t = %f, condition: %d",
    NSStringFromCGPoint( gorilla.position ), NSStringFromCGPoint( self.throw.endPoint ), NSStringFromCGPoint( self.velocity ),
    self.throw.duration, self.throw.endCondition);
    if (self.throw.endCondition == ThrowEndHitGorilla
        && [GorillasAppDelegate get].gameLayer.cityLayer.hitGorilla.lives == 1
        && [[GorillasConfig get].replay boolValue])
        self.needReplay = YES;

    [self doThrowIsReplay:NO];
}

- (void)doThrowIsReplay:(BOOL)isReplay {

    self.wasReplay = isReplay;

    // Begin throw.
    [GorillasAppDelegate get].gameLayer.cityLayer.bananaLayer.clearedGorilla = NO;
    [self.gorilla threw:self.velocity];
    self.banana = [[GorillasAppDelegate get].gameLayer.cityLayer.bananaLayer bananaForThrowFrom:self.gorilla];
    [self.banana runAction:[ThrowAction actionWithVelocity:self.velocity duration:self.duration needsReplay:self.needReplay]];

    if (isReplay) {
        [[GorillasAppDelegate get].gameLayer scaleTimeTo:0.5f];
        [[GorillasAppDelegate get].gameLayer.panningLayer scaleTo:1.5f limited:NO];
        [[GorillasAppDelegate get].hudLayer message:PearlLocalize( @"message.killreplay" ) isImportant:YES];
        [[GorillasAppDelegate get].hudLayer setButtonTitle:@"Skip" callback:self :@selector(skipThrow:)];
    }
    else
        [[GorillasAppDelegate get].gameLayer.cityLayer throwFrom:self.gorilla withVelocity:self.velocity];
}

- (void)skipThrow:(id)sender {

    if (!self.wasReplay) {
        [[GorillasAppDelegate get].hudLayer dismissMessage];
        return;
    }

    [self.banana stopAllActions];
    [self throwEnded];
}

+ (GThrow)calculateThrowFrom:(CGPoint)r0 withVelocity:(CGPoint)v afterTime:(ccTime)t {

    GameLayer *gameLayer = [GorillasAppDelegate get].gameLayer;
    CityLayer *cityLayer = gameLayer.cityLayer;

    // Wind influence.
    float w = gameLayer.windLayer.wind;

    // Calculate banana position.
    NSUInteger g = [[GorillasConfig get].gravity unsignedIntValue];
    CGPoint r = ccp( (v.x + w * t * [[GorillasConfig get].windModifier floatValue]) * t + r0.x,
            v.y * t - t * t * g / 2 + r0.y );

    // Check for events.
    CGRect field = [cityLayer fieldInSpaceOf:cityLayer];
    float min = field.origin.x;
    float max = field.origin.x + field.size.width;
    float top = field.origin.y + field.size.height;

    // Figure out whether banana went off screen or hit something.
    GThrowEnd endCondition = ThrowNotEnded;
    if ([cityLayer hitsBuilding:r])
        endCondition = ThrowEndHitBuilding;
    else if ([cityLayer hitsGorilla:r])
        endCondition = ThrowEndHitGorilla;
    else if (r.x < min || r.x > max || r.y < 0 || r.y > top)
        endCondition = ThrowEndOffScreen;

    return (GThrow){ r, endCondition, t };
}

+ (ThrowController *)get {

    static ThrowController *sharedThrowController = nil;
    if (sharedThrowController == nil)
        sharedThrowController = [[ThrowController alloc] init];

    return sharedThrowController;
}

@end
