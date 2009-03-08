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
//  GameLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 19/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "PanningLayer.h"
#import "GorillasConfig.h"
#import "SkiesLayer.h"
#import "BuildingsLayer.h"
#import "WindLayer.h"


@interface GameLayer : Layer <Resettable> {

    BOOL                                    paused;
    BOOL                                    running;
    GorillasMode                            mode;
    NSUInteger                              humans;
    NSUInteger                              ais;
    
    NSMutableArray                          *gorillas;
    GorillaLayer                            *activeGorilla;

    SkiesLayer                              *skiesLayer;
    PanningLayer                            *panningLayer;
    BuildingsLayer                          *buildingsLayer;
    ParticleSystem                          *weather;
    WindLayer                               *windLayer;
    Action                                  *shakeAction;
}

@property (readwrite) BOOL                  paused;
@property (readonly) BOOL                   singlePlayer;

@property (readonly) NSMutableArray         *gorillas;
@property (readwrite, retain) GorillaLayer  *activeGorilla;

@property (readonly) SkiesLayer             *skiesLayer;
@property (readonly) PanningLayer           *panningLayer;
@property (readonly) BuildingsLayer         *buildingsLayer;
@property (readonly) ParticleSystem         *weather;
@property (readonly) WindLayer              *windLayer;

-(void) shake;
-(BOOL) isEnabled:(GorillasFeature)feature;
-(void) configureGameWithMode:(GorillasMode)nMode humans:(NSUInteger)humans ais:(NSUInteger)ais;

-(void) updateStateHitGorilla:(BOOL)hitGorilla hitBuilding:(BOOL)hitBuilding offScreen:(BOOL)offScreen throwSkill:(float)throwSkill;
-(BOOL) checkGameStillOn;
-(void) startGame;
-(void) stopGame;
-(void) endGame;

-(void) started;
-(void) stopped;

@end
