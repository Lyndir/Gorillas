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
//  GorillaLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 07/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "BananaLayer.h"


@interface GorillaLayer : Sprite {

    NSString            *name;
    NSUInteger          teamIndex, globalIndex;
    
    int                 initialLives, lives;
    BOOL                active;
    NSUInteger          turns;
    float               zoom;
    
    Sprite              *bobber;
    
    GorillasPlayerModel model;
    GorillasPlayerType  type;
}

+(void) prepareCreation;
-(id) initWithName:(NSString *)_name type:(GorillasPlayerType)_type;

-(BOOL) hitsGorilla: (cpVect)pos;
-(void) cheer;
-(void) dance;
-(void) threw:(cpVect)aim;
-(void) kill;
-(void) killDead;
-(void) revive;

@property (nonatomic, readonly) NSString                *name;
@property (nonatomic, readonly) NSUInteger              teamIndex;
@property (nonatomic, readonly) NSUInteger              globalIndex;
@property (nonatomic, readonly) BOOL                    human;

@property (nonatomic, readonly) int                     lives;
@property (nonatomic, readonly) BOOL                    alive;
@property (nonatomic, readwrite) BOOL                   active;
@property (nonatomic, readwrite) NSUInteger             turns;
@property (nonatomic, readwrite) float                  zoom;
@property (nonatomic, readwrite) GorillasPlayerModel    model;
@property (nonatomic, readwrite) GorillasPlayerType     type;
@property (nonatomic, readonly) GorillasProjectileModel projectileModel;

@end
