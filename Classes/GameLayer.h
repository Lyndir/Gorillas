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
#import "SkiesLayer.h"
#import "CityLayer.h"
#import "WindLayer.h"


@interface GameLayer : Layer <Resettable> {

    BOOL                                                paused;
    BOOL                                                running;
    GorillasMode                                        mode;
    NSUInteger                                          humans;
    NSUInteger                                          ais;
    
    NSMutableArray                                      *gorillas;
    GorillaLayer                                        *activeGorilla;

    SkiesLayer                                          *skiesLayer;
    PanningLayer                                        *panningLayer;
    CityLayer                                      *buildingsLayer;
    ParticleSystem                                      *weather;
    WindLayer                                           *windLayer;
    Action                                              *shakeAction;
    ScaleTime                                           *scaleTimeAction;
}

@property (nonatomic, readwrite) BOOL                   paused;
@property (nonatomic, readonly) BOOL                    singlePlayer;

@property (nonatomic, readonly) NSMutableArray          *gorillas;
@property (nonatomic, readwrite, retain) GorillaLayer   *activeGorilla;

@property (nonatomic, readonly) SkiesLayer              *skiesLayer;
@property (nonatomic, readonly) PanningLayer            *panningLayer;
@property (nonatomic, readonly) CityLayer          *buildingsLayer;
@property (nonatomic, readonly) ParticleSystem          *weather;
@property (nonatomic, readonly) WindLayer               *windLayer;

@property (nonatomic, readonly) ScaleTime               *scaleTimeAction;

-(void) shake;
-(BOOL) isEnabled:(GorillasFeature)feature;
-(void) configureGameWithMode:(GorillasMode)nMode humans:(NSUInteger)humans ais:(NSUInteger)ais;
- (void)scaleTimeTo:(float)aTimeScale duration:(ccTime)aDuration;

-(void) updateStateHitGorilla:(BOOL)hitGorilla hitBuilding:(BOOL)hitBuilding offScreen:(BOOL)offScreen throwSkill:(float)throwSkill;
-(BOOL) checkGameStillOn;
-(void) startGame;
-(void) stopGame;
-(void) endGame;

-(void) started;
-(void) stopped;

@end
