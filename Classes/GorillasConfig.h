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
//  GorillasConfig.h
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "GameConfiguration.h"


@interface GorillasConfig : NSObject {

@private
    NSUserDefaults                                      *defaults;
    
    NSArray                                             *updateTriggers;
    NSDictionary                                        *resetTriggers;
    
    NSDictionary                                        *modeStrings;
    NSArray                                             *modes;
    NSArray                                             *gameConfigurations;
    NSArray                                             *offMessages, *hitMessages;
}


@property (nonatomic, readwrite, retain) NSNumber       *fontSize;
@property (nonatomic, readwrite, retain) NSNumber       *largeFontSize;
@property (nonatomic, readwrite, retain) NSNumber       *smallFontSize;
@property (nonatomic, readwrite, retain) NSString       *fontName;
@property (nonatomic, readwrite, retain) NSString       *fixedFontName;

@property (nonatomic, readwrite, retain) NSString       *cityTheme;

@property (nonatomic, readwrite, retain) NSNumber       *fixedFloors;
@property (nonatomic, readonly) float                   cityScale;
@property (nonatomic, readwrite, retain) NSNumber       *buildingMax;
@property (nonatomic, readonly) float                   buildingWidth;
@property (nonatomic, readwrite, retain) NSNumber       *buildingAmount;
@property (nonatomic, readwrite, retain) NSNumber       *buildingSpeed;
@property (nonatomic, readwrite, retain) NSArray        *buildingColors;

@property (nonatomic, readonly) float                   windowWidth;
@property (nonatomic, readonly) float                   windowHeight;
@property (nonatomic, readwrite, retain) NSNumber       *windowAmount;
@property (nonatomic, readonly) float                   windowPadding;
@property (nonatomic, readwrite, retain) NSNumber       *windowColorOn;
@property (nonatomic, readwrite, retain) NSNumber       *windowColorOff;

@property (nonatomic, readwrite, retain) NSNumber       *skyColor;
@property (nonatomic, readwrite, retain) NSNumber       *starColor;
@property (nonatomic, readwrite, retain) NSNumber       *starSpeed;
@property (nonatomic, readwrite, retain) NSNumber       *starAmount;

@property (nonatomic, readwrite, retain) NSNumber       *lives;
@property (nonatomic, readwrite, retain) NSNumber       *windModifier;
@property (nonatomic, readwrite, retain) NSNumber       *gravity;
@property (nonatomic, readwrite, retain) NSNumber       *minGravity;
@property (nonatomic, readwrite, retain) NSNumber       *maxGravity;

@property (nonatomic, readwrite, retain) NSNumber       *shadeColor;
@property (nonatomic, readwrite, retain) NSNumber       *transitionDuration;
@property (nonatomic, readwrite, retain) NSNumber       *gameScrollDuration;

@property (nonatomic, readwrite, retain) NSNumber       *level;
@property (nonatomic, readonly) NSString                *levelName;
@property (nonatomic, readwrite, retain) NSArray        *levelNames;
@property (nonatomic, readwrite, retain) NSNumber       *levelProgress;

@property (nonatomic, readonly, retain) NSArray         *gameConfigurations;
@property (nonatomic, readwrite, retain) NSNumber       *activeGameConfigurationIndex;
@property (nonatomic, readwrite, retain) NSNumber       *mode;
@property (nonatomic, readonly) NSArray                 *modes;
@property (nonatomic, readonly) NSDictionary            *modeStrings;
@property (nonatomic, readonly) NSString                *modeString;
@property (nonatomic, readwrite, retain) NSNumber       *playerModel;
@property (nonatomic, readwrite, retain) NSNumber       *score;
@property (nonatomic, readwrite, retain) NSNumber       *skill;
@property (nonatomic, readwrite, retain) NSDictionary   *topScoreHistory;
@property (nonatomic, readwrite, retain) NSNumber       *missScore;
@property (nonatomic, readwrite, retain) NSNumber       *killScore;
@property (nonatomic, readwrite, retain) NSNumber       *bonusOneShot;
@property (nonatomic, readwrite, retain) NSNumber       *bonusSkill;
@property (nonatomic, readwrite, retain) NSNumber       *deathScoreRatio;
@property (nonatomic, readonly) NSInteger               deathScore;

@property (nonatomic, readwrite, retain) NSArray        *tracks;
@property (nonatomic, readwrite, retain) NSArray        *trackNames;
@property (nonatomic, readonly) NSString                *randomTrack;
@property (nonatomic, readwrite, retain) NSString       *currentTrack;
@property (nonatomic, readonly) NSString                *currentTrackName;

@property (nonatomic, readwrite, retain) NSNumber       *soundFx;
@property (nonatomic, readwrite, retain) NSNumber       *voice;
@property (nonatomic, readwrite, retain) NSNumber       *vibration;
@property (nonatomic, readwrite, retain) NSNumber       *visualFx;

@property (nonatomic, readwrite, retain) NSNumber       *replay;
@property (nonatomic, readwrite, retain) NSNumber       *followThrow;

@property (nonatomic, readonly) NSString                *offMessage;
@property (nonatomic, readonly) NSString                *hitMessage;

-(long)                                                 buildingColor;

-(void)                                                 levelUp;
-(void)                                                 levelDown;

-(void)                                                 recordScore:(NSInteger)score;

+(GorillasConfig *)                                     get;

@end
