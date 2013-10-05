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

#import "ThrowAction.h"
#import "ThrowController.h"
#import "GorillasAppDelegate.h"
#define recapTime 3

@implementation ThrowAction

+ (ThrowAction *)actionWithVelocity:(CGPoint)velocity duration:(ccTime)aDuration needsReplay:(BOOL)aNeedsReplay {

    return [[ThrowAction alloc] initWithVelocity:velocity duration:aDuration needsReplay:aNeedsReplay];
}

- (ThrowAction *)initWithVelocity:(CGPoint)velocity duration:(ccTime)aDuration needsReplay:(BOOL)aNeedsReplay {

    // De-normalize the velocity back to our resolution.
    if (!(self = [super initWithDuration:aDuration]))
        return self;

    self.v = velocity;
    self.needsReplay = aNeedsReplay;

    self.smoke = [CCParticleMeteor node];
    self.smoke.positionType = kCCPositionTypeGrouped;
    self.smoke.gravity = CGPointZero;
    self.smoke.position = CGPointZero;
    self.smoke.speed = 5;
    self.smoke.angle = -90;
    self.smoke.angleVar = 10;
    self.smoke.life = 3;
    self.smoke.emissionRate = 0;
    self.smoke.startColor = (ccColor4F){ 0.1f, 0.2f, 0.3f, 0.5f };
    self.smoke.endColor = (ccColor4F){ 0.0f, 0.0f, 0.0f, 0.3f };

    return self;
}

- (void)startWithTarget:(id)aTarget {

    [super startWithTarget:aTarget];
    self.r0 = [(CCNode *)self.target position];

    [self.target setVisible:YES];
    [self.target setTag:GorillasTagBananaFlying];

    [[GorillasAppDelegate get].gameLayer.windLayer registerSystem:self.smoke affectAngle:NO];
    self.smoke.emissionRate = 30;
    self.smoke.startSize = 15.0f * [(CCNode *)self.target scale];
    self.smoke.startSizeVar = 5.0f * [(CCNode *)self.target scale];
    if (!self.smoke.parent)
        [[self.target parent] addChild:self.smoke];
    else
        [self.smoke resetSystem];
}

- (void)update:(ccTime)dt {

    [self.target setPosition:[ThrowController calculateThrowFrom:self.r0 withVelocity:self.v afterTime:self.elapsed].endPoint];

    // Pan the screen.
    GameLayer *gameLayer = [GorillasAppDelegate get].gameLayer;
    [gameLayer.panningLayer scrollToCenter:[(CCNode *)self.target position]
                                horizontal:[[GorillasConfig get].followThrow boolValue]];

    // Update smoke.
    self.smoke.angle = atan2f( self.smoke.sourcePosition.y - [(CCNode *)self.target position].y,
            self.smoke.sourcePosition.x - [(CCNode *)self.target position].x ) / (float)M_PI * 180.0f;
    self.smoke.sourcePosition = [(CCNode *)self.target position];

    if (gameLayer.singlePlayer && gameLayer.activeGorilla.human && [gameLayer isEnabled:GorillasFeatureSkill])
            // Singleplayer game with human turn is still running; update the skill counter.
        [GorillasAppDelegate get].hudLayer.throwSkill = self.elapsed / 10;
}

- (void)stop {

    [GorillasAppDelegate get].hudLayer.throwSkill = 0;

    // self.target.position = [guaranteed time-independant end point of the throw]
    [self.target setVisible:NO];

    if (self.needsReplay)
        [self.smoke resetSystem];
    self.smoke.emissionRate = 0;
    [[GorillasAppDelegate get].gameLayer.windLayer unregisterSystem:self.smoke];

    [super stop];

    [[ThrowController get] throwEnded];
}

@end
