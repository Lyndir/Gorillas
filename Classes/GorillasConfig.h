/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
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
//  GorillasConfig.h
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#ifndef _GORILLACONFIG
#define _GORILLACONFIG

#import "cocos2d.h"


@interface GorillasConfig : NSObject {

    NSUserDefaults *defaults;
}


@property (readwrite) int                   fontSize;
@property (readwrite, assign) NSString      *fontName;

@property (readwrite, assign) NSString      *cityTheme;

@property (readwrite) int                   fixedFloors;
@property (readwrite) float                 buildingMax;
@property (readonly) float                  buildingWidth;
@property (readwrite) int                   buildingAmount;
@property (readwrite) int                   buildingSpeed;
@property (readwrite, assign) NSArray       *buildingColors;

@property (readonly) float                  windowWidth;
@property (readonly) float                  windowHeight;
@property (readwrite) int                   windowAmount;
@property (readonly) float                  windowPadding;
@property (readwrite) long                  windowColorOn;
@property (readwrite) long                  windowColorOff;

@property (readwrite) long                  skyColor;
@property (readwrite) long                  starColor;
@property (readwrite) int                   starSpeed;
@property (readwrite) int                   starAmount;

@property (readwrite) int                   gravity;
@property (readwrite) long                  shadeColor;
@property (readwrite) ccTime                transitionDuration;

@property (readwrite) float                 level;
@property (readonly) NSString               *levelName;
@property (readwrite, assign) NSArray       *levelNames;
@property (readonly) int                    levelNameCount;

@property (readwrite) int                   score;
@property (readwrite) int                   missScore;
@property (readwrite) int                   killScore;
@property (readwrite) int                   deathScore;

-(long)                                     buildingColor;

-(void)                                     levelUp;
-(void)                                     levelDown;

+(GorillasConfig *)                         get;

@end


#endif
