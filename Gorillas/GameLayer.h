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


@interface GameLayer : CCLayer <PearlResettable, CCTimeScalable> {

@private
    BOOL                                                    paused;
    BOOL                                                    configuring;
    BOOL                                                    started;
    BOOL                                                    running;
    GorillasMode                                            mode;
    BOOL                                                    randomCity;
    NSUInteger                                              humans;
    NSUInteger                                              ais;
    
    NSMutableArray                                          *gorillas;
    GorillaLayer                                            *activeGorilla;

    SkyLayer                                                *skyLayer;
    PanningLayer                                            *panningLayer;
    CityLayer                                               *cityLayer;
    CCParticleSystem                                        *backWeather, *frontWeather;
    WindLayer                                               *windLayer;
    CCAction                                                *shakeAction;
    PearlCCAutoTween                                        *scaleTimeAction;
    float                                                   timeScale;
}

@property (nonatomic, readwrite, getter=isPaused) BOOL      paused;
@property (nonatomic, readwrite) BOOL                       configuring;
@property (nonatomic, readwrite) BOOL                       started;
@property (nonatomic, readwrite) BOOL                       running;
@property (nonatomic, readonly) GorillasMode                mode;
@property (nonatomic, readonly, getter=isSinglePlayer) BOOL singlePlayer;

@property (nonatomic, readonly) NSMutableArray              *gorillas;
@property (nonatomic, readwrite, retain) GorillaLayer       *activeGorilla;

@property (nonatomic, readonly) SkyLayer                    *skyLayer;
@property (nonatomic, readonly) PanningLayer                *panningLayer;
@property (nonatomic, readonly) CityLayer                   *cityLayer;
@property (nonatomic, readonly) CCParticleSystem            *backWeather;
@property (nonatomic, readonly) CCParticleSystem            *frontWeather;
@property (nonatomic, readonly) WindLayer                   *windLayer;

@property (nonatomic, readonly) PearlCCAutoTween            *scaleTimeAction;
@property (nonatomic, readwrite) float                      timeScale;

-(void) shake;
-(BOOL) isEnabled:(GorillasFeature)feature;
-(void) configureGameWithMode:(GorillasMode)nMode randomCity:(BOOL)aRandomCity
                    playerIDs:(NSArray *)playerIDs localHumans:(NSUInteger)localHumans ais:(NSUInteger)ais;
-(void) scaleTimeTo:(float)aTimeScale;

-(void) updateStateForThrow:(Throw)throw withSkill:(float)throwSkill;
-(BOOL) checkGameStillOn;
-(void) startGame;
/** Invoked when we want to stop playing. */
-(void) stopGame;
/** Invoked when the game ends and can be continued. */
-(void) endGame;

-(void) began;
-(void) ended;

@end
