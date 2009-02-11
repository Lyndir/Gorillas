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
#import "GorillasConfig.h"
#import "SkiesLayer.h"
#import "BuildingsLayer.h"
#import "WindLayer.h"


@interface GameLayer : Layer <Resettable> {

    BOOL paused;
    BOOL running;
    BOOL singlePlayer;

    SkiesLayer *skiesLayer;
    BuildingsLayer *buildingsLayer;
    ParticleSystem *weather;
    WindLayer *windLayer;
    Label *msgLabel;
}

@property (readonly) SkiesLayer *skiesLayer;
@property (readonly) BuildingsLayer *buildingsLayer;
@property (readonly) ParticleSystem *weather;
@property (readonly) WindLayer *windLayer;
@property (readonly) BOOL singlePlayer;
@property (readonly) BOOL running;
@property (readonly) BOOL paused;

-(void) pause;
-(void) unpause;

-(void) message: (NSString *)msg;
-(void) resetMessage: (id) sender;

-(void) startSinglePlayer;
-(void) startMultiplayer;
-(void) started;

-(void) stopGame;
-(void) stopped;


@end
