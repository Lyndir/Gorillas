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
//  GorillasConfig.h
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#ifndef _GORILLACONFIG
#define _GORILLACONFIG

#import "GameConfiguration.h"


@interface GorillasConfig : NSObject {

    NSUserDefaults  *defaults;
    NSArray         *modes;
    NSArray         *gameConfigurations;
    NSArray         *offMessages, *hitMessages;
}


@property (readwrite) int                   fontSize;
@property (readwrite) int                   largeFontSize;
@property (readwrite) int                   smallFontSize;
@property (readwrite, assign) NSString      *fontName;
@property (readwrite, assign) NSString      *fixedFontName;

@property (readwrite, assign) NSString      *cityTheme;

@property (readwrite) NSUInteger            fixedFloors;
@property (readonly) float                  cityScale;
@property (readwrite) float                 buildingMax;
@property (readonly) float                  buildingWidth;
@property (readwrite) NSUInteger            buildingAmount;
@property (readwrite) int                   buildingSpeed;
@property (readwrite, assign) NSArray       *buildingColors;

@property (readonly) float                  windowWidth;
@property (readonly) float                  windowHeight;
@property (readwrite) NSUInteger            windowAmount;
@property (readonly) float                  windowPadding;
@property (readwrite) long                  windowColorOn;
@property (readwrite) long                  windowColorOff;

@property (readwrite) long                  skyColor;
@property (readwrite) long                  starColor;
@property (readwrite) int                   starSpeed;
@property (readwrite) NSUInteger            starAmount;

@property (readwrite) int                   lives;
@property (readwrite) float                 windModifier;
@property (readwrite) NSUInteger            gravity;
@property (readwrite) NSUInteger            minGravity;
@property (readwrite) NSUInteger            maxGravity;

@property (readwrite) long                  shadeColor;
@property (readwrite) ccTime                transitionDuration;
@property (readwrite) ccTime                gameScrollDuration;

@property (readwrite) float                 level;
@property (readonly) NSString               *levelName;
@property (readwrite, assign) NSArray       *levelNames;
@property (readwrite) float                 levelProgress;

@property (readonly) GameConfiguration      *gameConfiguration;
@property (readwrite) NSUInteger            activeGameConfigurationIndex;
@property (readwrite) NSUInteger            mode;
@property (readonly) NSArray                *modes;
@property (readonly) NSString               *modeString;
@property (readwrite) int                   score;
@property (readwrite) float                 skill;
@property (readwrite, assign) NSDictionary  *topScoreHistory;
@property (readwrite) int                   missScore;
@property (readwrite) int                   killScore;
@property (readwrite) float                 bonusOneShot;
@property (readwrite) float                 bonusSkill;
@property (readwrite) int                   deathScoreRatio;
@property (readonly) int                    deathScore;

@property (readwrite, assign) NSArray       *tracks;
@property (readwrite, assign) NSArray       *trackNames;
@property (readonly) NSString               *randomTrack;
@property (readwrite, assign) NSString      *currentTrack;
@property (readonly, assign) NSString       *currentTrackName;

@property (readwrite) BOOL                  weather;
@property (readwrite) BOOL                  soundFx;
@property (readwrite) BOOL                  vibration;
@property (readwrite) BOOL                  visualFx;

@property (readwrite) BOOL                  replay;
@property (readwrite) BOOL                  followThrow;

@property (readonly) NSString               *offMessage;
@property (readonly) NSString               *hitMessage;

-(long)                                     buildingColor;

-(void)                                     levelUp;
-(void)                                     levelDown;

+(GorillasConfig *)                         get;

@end


#endif
