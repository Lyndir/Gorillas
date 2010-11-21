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
//  GameLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 19/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//


#import "PanningLayer.h"
#import "SkyLayer.h"
#import "CityLayer.h"
#import "WindLayer.h"
#import <GameKit/GameKit.h>


@interface GameLayer : CCLayer <Resettable> {

@private
    BOOL                                                    paused;
    BOOL                                                    running;
    BOOL                                                    hosted;
    GorillasMode                                            mode;
    NSUInteger                                              humans;
    NSUInteger                                              ais;
    
    NSMutableArray                                          *gorillas;
    GorillaLayer                                            *activeGorilla;

    SkyLayer                                                *skyLayer;
    PanningLayer                                            *panningLayer;
    CityLayer                                               *cityLayer;
    CCParticleSystem                                        *weather;
    WindLayer                                               *windLayer;
    CCAction                                                *shakeAction;
    //FIXME ScaleTime                                       *scaleTimeAction;
    
    NSArray                                                 *playerIDs;
}

@property (nonatomic, readwrite, getter=isPaused) BOOL      paused;
@property (nonatomic, readonly, getter=isSinglePlayer) BOOL singlePlayer;
@property (nonatomic, readonly, getter=isHosted) BOOL       hosted;

@property (nonatomic, readonly) NSMutableArray              *gorillas;
@property (nonatomic, readwrite, retain) GorillaLayer       *activeGorilla;

@property (nonatomic, readonly) SkyLayer                    *skyLayer;
@property (nonatomic, readonly) PanningLayer                *panningLayer;
@property (nonatomic, readonly) CityLayer                   *cityLayer;
@property (nonatomic, readonly) CCParticleSystem            *weather;
@property (nonatomic, readonly) WindLayer                   *windLayer;

//FIXME @property (nonatomic, readonly) ScaleTime           *scaleTimeAction;

@property (nonatomic, readonly, retain) NSArray             *playerIDs;

-(void) shake;
-(BOOL) isEnabled:(GorillasFeature)feature;
-(void) configureGameWithMode:(GorillasMode)nMode playerIDs:(NSArray *)playerIDs ais:(NSUInteger)ais;
- (void)scaleTimeTo:(float)aTimeScale duration:(ccTime)aDuration;

-(void) updateStateHitGorilla:(BOOL)hitGorilla hitBuilding:(BOOL)hitBuilding offScreen:(BOOL)offScreen throwSkill:(float)throwSkill;
-(BOOL) checkGameStillOn;
-(void) startGameHosted:(BOOL)isHosted;
/** Invoked when we want to stop playing. */
-(void) stopGame;
/** Invoked when the game ends and can be continued. */
-(void) endGame;

-(void) began;
-(void) ended;

@end
