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
#import "PearlConfig.h"
#import "PearlLogger.h"


@class GorillaLayer;

@interface GorillasConfig : PearlConfig {

@private
    NSArray                                             *updateTriggers;
    
    NSArray                                             *gameConfigurations;
    NSArray                                             *offMessages, *hitMessages;
}


@property (nonatomic, readwrite, retain) NSString       *cityTheme;

@property (nonatomic, readwrite, retain) NSNumber       *varFloors;
@property (nonatomic, readwrite, retain) NSNumber       *fixedFloors;
@property (nonatomic, readwrite, retain) NSNumber       *buildingAmount;
@property (nonatomic, readwrite, retain) NSNumber       *buildingSpeed;
@property (nonatomic, readwrite, retain) NSArray        *buildingColors;

@property (nonatomic, readwrite, retain) NSNumber       *windowAmount;
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

@property (nonatomic, readwrite, retain) NSNumber       *gameScrollDuration;

@property (nonatomic, readwrite, retain) NSNumber       *level;
@property (nonatomic, readwrite, retain) NSArray        *levelNames;
@property (nonatomic, readwrite, retain) NSNumber       *levelProgress;

@property (nonatomic, readonly, retain) NSArray         *gameConfigurations;
@property (nonatomic, readwrite, retain) NSNumber       *activeGameConfigurationIndex;
@property (nonatomic, readwrite, retain) NSNumber       *mode;
@property (nonatomic, readwrite, retain) NSNumber       *playerModel;
@property (nonatomic, readwrite, retain) NSData         *scores;
@property (nonatomic, readwrite, retain) NSNumber       *skill;
@property (nonatomic, readwrite, retain) NSNumber       *missScore;
@property (nonatomic, readwrite, retain) NSNumber       *killScore;
@property (nonatomic, readwrite, retain) NSNumber       *bonusOneShot;
@property (nonatomic, readwrite, retain) NSNumber       *bonusSkill;
@property (nonatomic, readwrite, retain) NSNumber       *deathScoreRatio;
@property (nonatomic, readonly) NSInteger               deathScore;

@property (nonatomic, readwrite, retain) NSNumber       *replay;
@property (nonatomic, readwrite, retain) NSNumber       *followThrow;

-(ccColor4B)                                            buildingColor;

-(void)                                                 levelUp;
-(void)                                                 levelDown;

-(int64_t)recordScoreDelta:(int64_t)scoreDelta forMode:(GorillasMode)mode;
-(int64_t)scoreForMode:(GorillasMode)mode;

-(NSString *) messageForOff;
-(NSString *) messageForHitBy:(GorillaLayer *)byGorilla on:(GorillaLayer *)onGorilla;

+(GorillasConfig *)                                     get;

+(NSString *)nameForLevel:(NSNumber *)aLevel;

+(NSString *)descriptionForMode:(GorillasMode)mode;
+(NSArray *)descriptionsForModes;
+(NSString *)categoryForMode:(GorillasMode)mode;
+(NSString *)nameForMode:(GorillasMode)mode;

@end

/**
 * Utility for scaling Gorillas models.
 */
static inline float GorillasModelScale(const float amountPerBuildingWidth, const float modelPixelsWide) {
    
    dbg(@"winWidthPx: %f, buildings: %f, amountPerBuildingWidth: %f, modelPixelsWide: %f => %f", [CCDirector sharedDirector].winSizeInPixels.width, [[GorillasConfig get].buildingAmount floatValue], amountPerBuildingWidth, modelPixelsWide, [CCDirector sharedDirector].winSizeInPixels.width / [[GorillasConfig get].buildingAmount floatValue]
        / amountPerBuildingWidth / modelPixelsWide);
    return [CCDirector sharedDirector].winSizeInPixels.width / [[GorillasConfig get].buildingAmount floatValue]
            / amountPerBuildingWidth / modelPixelsWide;
}
