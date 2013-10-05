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
//  GorillaLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 07/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "PearlCCActivitySprite.h"
#import <GameKit/GameKit.h>
#import "PearlResettable.h"

@interface GorillaLayer : CCSprite<PearlResettable>

@property(nonatomic, readonly, copy) NSString *name;
@property(nonatomic, readonly, assign) NSUInteger teamIndex;
@property(nonatomic, readonly, assign) NSUInteger globalIndex;

@property(nonatomic, readonly, copy) NSString *playerID;
@property(nonatomic, readwrite, strong) GKPlayer *player;
@property(nonatomic, readwrite, assign) GKPlayerConnectionState connectionState;

@property(nonatomic, readonly, assign) int initialLives;
@property(nonatomic, readonly, assign) int lives;
@property(nonatomic, readwrite, assign) BOOL active;
@property(nonatomic, readwrite, assign) BOOL ready;
@property(nonatomic, readwrite, assign) NSUInteger turns;
@property(nonatomic, readwrite, assign) float zoom;

@property(nonatomic, readonly, strong) CCSprite *bobber;
@property(nonatomic, readwrite, assign) GorillasPlayerModel model;
@property(nonatomic, readwrite, assign) GorillasPlayerType type;

@property(nonatomic, readonly, assign) GorillasProjectileModel projectileModel;
@property(nonatomic, readonly, assign) BOOL alive;

+ (void)prepareCreation;
+ (GorillaLayer *)gorillaWithType:(GorillasPlayerType)aType playerID:(NSString *)aPlayerId;
- (id)initWithType:(GorillasPlayerType)aType playerID:(NSString *)aPlayerId;

- (BOOL)human;
- (BOOL)local;
- (BOOL)hitsGorilla:(CGPoint)pos;
- (void)danceHit;
- (void)danceKill;
- (void)danceVictory;
- (void)threw:(CGPoint)v;
- (void)applyZoom;
- (void)kill;
- (void)killDead;
- (void)revive;

@end
