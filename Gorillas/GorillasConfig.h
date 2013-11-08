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

@interface GorillasConfig : PearlConfig

@property(nonatomic, readwrite, strong) NSString *cityTheme;

@property(nonatomic, readwrite, strong) NSNumber *varFloors;
@property(nonatomic, readwrite, strong) NSNumber *fixedFloors;
@property(nonatomic, readwrite, strong) NSNumber *buildingAmount;
@property(nonatomic, readwrite, strong) NSNumber *buildingSpeed;
@property(nonatomic, readwrite, strong) NSArray *buildingColors;

@property(nonatomic, readwrite, strong) NSNumber *windowAmount;
@property(nonatomic, readwrite, strong) NSNumber *windowColorOn;
@property(nonatomic, readwrite, strong) NSNumber *windowColorOff;

@property(nonatomic, readwrite, strong) NSNumber *skyColor;
@property(nonatomic, readwrite, strong) NSNumber *starColor;
@property(nonatomic, readwrite, strong) NSNumber *starSpeed;
@property(nonatomic, readwrite, strong) NSNumber *starAmount;

@property(nonatomic, readwrite, strong) NSNumber *lives;
@property(nonatomic, readwrite, strong) NSNumber *windModifier;
@property(nonatomic, readwrite, strong) NSNumber *gravity;
@property(nonatomic, readwrite, strong) NSNumber *minGravity;
@property(nonatomic, readwrite, strong) NSNumber *maxGravity;

@property(nonatomic, readwrite, strong) NSNumber *gameScrollDuration;

@property(nonatomic, readwrite, strong) NSNumber *level;
@property(nonatomic, readwrite, strong) NSArray *levelNames;
@property(nonatomic, readwrite, strong) NSNumber *levelProgress;

@property(nonatomic, readonly, strong) NSArray *gameConfigurations;
@property(nonatomic, readwrite, strong) NSNumber *activeGameConfigurationIndex;
@property(nonatomic, readwrite, strong) NSNumber *mode;
@property(nonatomic, readwrite, strong) NSNumber *playerModel;
@property(nonatomic, readwrite, strong) NSData *scores;
@property(nonatomic, readwrite, strong) NSNumber *skill;
@property(nonatomic, readwrite, strong) NSNumber *missScore;
@property(nonatomic, readwrite, strong) NSNumber *killScore;
@property(nonatomic, readwrite, strong) NSNumber *bonusOneShot;
@property(nonatomic, readwrite, strong) NSNumber *bonusSkill;
@property(nonatomic, readwrite, strong) NSNumber *deathScoreRatio;
@property(nonatomic, readonly) NSInteger deathScore;

@property(nonatomic, readwrite, strong) NSNumber *replay;
@property(nonatomic, readwrite, strong) NSNumber *followThrow;

- (ccColor4B)buildingColor;

- (void)levelUp;
- (void)levelDown;

- (int64_t)recordScoreDelta:(int64_t)scoreDelta forMode:(GorillasMode)mode;
- (int64_t)scoreForMode:(GorillasMode)mode;

- (NSString *)messageForOff;
- (NSString *)messageForHitBy:(GorillaLayer *)byGorilla on:(GorillaLayer *)onGorilla;

+ (GorillasConfig *)get;

+ (NSString *)nameForLevel:(NSNumber *)aLevel;

+ (NSString *)descriptionForMode:(GorillasMode)mode;
+ (NSArray *)descriptionsForModes;
+ (NSString *)categoryForMode:(GorillasMode)mode;
+ (NSString *)nameForMode:(GorillasMode)mode;

@end

/**
 * Utility for scaling Gorillas models.
 */
static inline float GorillasModelScale(const float amountPerBuildingWidth, const float modelWide) {

    dbg(@"winWidthPx: %f, buildings: %f, amountPerBuildingWidth: %f, modelWide: %f => %f", [CCDirector sharedDirector].winSize.width, [[GorillasConfig get].buildingAmount floatValue], amountPerBuildingWidth, modelWide, [CCDirector sharedDirector].winSize.width / [[GorillasConfig get].buildingAmount floatValue]
                                                                                                                                                                                                                           / amountPerBuildingWidth / modelWide);
    return [CCDirector sharedDirector].winSize.width / [[GorillasConfig get].buildingAmount floatValue]
           / amountPerBuildingWidth / modelWide;
}
