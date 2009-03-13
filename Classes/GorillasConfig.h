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


@property (nonatomic, readwrite) int                   fontSize;
@property (nonatomic, readwrite) int                   largeFontSize;
@property (nonatomic, readwrite) int                   smallFontSize;
@property (nonatomic, readwrite, assign) NSString      *fontName;
@property (nonatomic, readwrite, assign) NSString      *fixedFontName;

@property (nonatomic, readwrite, assign) NSString      *cityTheme;

@property (nonatomic, readwrite) NSUInteger            fixedFloors;
@property (nonatomic, readonly) float                  cityScale;
@property (nonatomic, readwrite) float                 buildingMax;
@property (nonatomic, readonly) float                  buildingWidth;
@property (nonatomic, readwrite) NSUInteger            buildingAmount;
@property (nonatomic, readwrite) int                   buildingSpeed;
@property (nonatomic, readwrite, assign) NSArray       *buildingColors;

@property (nonatomic, readonly) float                  windowWidth;
@property (nonatomic, readonly) float                  windowHeight;
@property (nonatomic, readwrite) NSUInteger            windowAmount;
@property (nonatomic, readonly) float                  windowPadding;
@property (nonatomic, readwrite) long                  windowColorOn;
@property (nonatomic, readwrite) long                  windowColorOff;

@property (nonatomic, readwrite) long                  skyColor;
@property (nonatomic, readwrite) long                  starColor;
@property (nonatomic, readwrite) int                   starSpeed;
@property (nonatomic, readwrite) NSUInteger            starAmount;

@property (nonatomic, readwrite) int                   lives;
@property (nonatomic, readwrite) float                 windModifier;
@property (nonatomic, readwrite) NSUInteger            gravity;
@property (nonatomic, readwrite) NSUInteger            minGravity;
@property (nonatomic, readwrite) NSUInteger            maxGravity;

@property (nonatomic, readwrite) long                  shadeColor;
@property (nonatomic, readwrite) ccTime                transitionDuration;
@property (nonatomic, readwrite) ccTime                gameScrollDuration;

@property (nonatomic, readwrite) float                 level;
@property (nonatomic, readonly) NSString               *levelName;
@property (nonatomic, readwrite, assign) NSArray       *levelNames;
@property (nonatomic, readwrite) float                 levelProgress;

@property (nonatomic, readonly) GameConfiguration      *gameConfiguration;
@property (nonatomic, readwrite) NSUInteger            activeGameConfigurationIndex;
@property (nonatomic, readwrite) NSUInteger            mode;
@property (nonatomic, readonly) NSArray                *modes;
@property (nonatomic, readonly) NSString               *modeString;
@property (nonatomic, readwrite) int                   score;
@property (nonatomic, readwrite) float                 skill;
@property (nonatomic, readwrite, assign) NSDictionary  *topScoreHistory;
@property (nonatomic, readwrite) int                   missScore;
@property (nonatomic, readwrite) int                   killScore;
@property (nonatomic, readwrite) float                 bonusOneShot;
@property (nonatomic, readwrite) float                 bonusSkill;
@property (nonatomic, readwrite) int                   deathScoreRatio;
@property (nonatomic, readonly) int                    deathScore;

@property (nonatomic, readwrite, assign) NSArray       *tracks;
@property (nonatomic, readwrite, assign) NSArray       *trackNames;
@property (nonatomic, readonly) NSString               *randomTrack;
@property (nonatomic, readwrite, assign) NSString      *currentTrack;
@property (nonatomic, readonly, assign) NSString       *currentTrackName;

@property (nonatomic, readwrite) BOOL                  weather;
@property (nonatomic, readwrite) BOOL                  soundFx;
@property (nonatomic, readwrite) BOOL                  vibration;
@property (nonatomic, readwrite) BOOL                  visualFx;

@property (nonatomic, readwrite) BOOL                  replay;
@property (nonatomic, readwrite) BOOL                  followThrow;

@property (nonatomic, readonly) NSString               *offMessage;
@property (nonatomic, readonly) NSString               *hitMessage;

-(long)                                     buildingColor;

-(void)                                     levelUp;
-(void)                                     levelDown;

+(GorillasConfig *)                         get;

@end


#endif
