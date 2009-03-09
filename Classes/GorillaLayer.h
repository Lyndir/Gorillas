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

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface GorillaLayer : Sprite {

    NSString            *name;
    NSUInteger          teamIndex, globalIndex;
    BOOL                human;
    
    int                 initialLives, lives;
    BOOL                active;
    NSUInteger          turns;
    float               zoom;
    
    Sprite              *bobber;
    NSString            *type;
    Texture2D           *dd, *ud, *du, *uu;
}

+(void) prepareCreation;
-(id) initWithName:(NSString *)name isHuman:(BOOL)_human;

-(BOOL) hitsGorilla: (cpVect)pos;
-(void) cheer;
-(void) dance;
-(void) threw:(cpVect)aim;
-(void) kill;
-(void) killDead;
-(void) revive;

@property (readonly) NSString           *name;
@property (readonly) NSUInteger         teamIndex;
@property (readonly) NSUInteger         globalIndex;
@property (readonly) BOOL               human;

@property (readonly) int                lives;
@property (readonly) BOOL               alive;
@property (readwrite) BOOL              active;
@property (readwrite) NSUInteger        turns;
@property (readwrite) float             zoom;

@end
