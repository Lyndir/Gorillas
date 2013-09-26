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
//  GorillasConfig.m
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "CityTheme.h"
#import "GorillasAppDelegate.h"
#import "GorillaLayer.h"


@implementation GorillasConfig

@synthesize gameConfigurations;

@dynamic cityTheme;
@dynamic varFloors, fixedFloors, buildingAmount, buildingSpeed, buildingColors;
@dynamic windowAmount, windowColorOn, windowColorOff;
@dynamic skyColor, starColor, starSpeed, starAmount;
@dynamic lives, windModifier, gravity, minGravity, maxGravity;
@dynamic gameScrollDuration;
@dynamic level, levelNames, levelProgress;
@dynamic activeGameConfigurationIndex, mode, playerModel, scores, skill, missScore, killScore, bonusOneShot, bonusSkill, deathScoreRatio;
@dynamic replay, followThrow;

#pragma mark Internal

-(id) init {

    if(!(self = [super init]))
        return self;

    NSArray *levelNames = [NSArray arrayWithObjects:
                           PearlLocalize(@"menu.config.level.one"),
                           PearlLocalize(@"menu.config.level.two"),
                           PearlLocalize(@"menu.config.level.three"),
                           PearlLocalize(@"menu.config.level.four"),
                           PearlLocalize(@"menu.config.level.five"),
                           PearlLocalize(@"menu.config.level.six"),
                           PearlLocalize(@"menu.config.level.seven"),
                           PearlLocalize(@"menu.config.level.eight"),
                           nil];

    gameConfigurations  = [[NSArray alloc] initWithObjects:
                           [GameConfiguration configurationWithName:PearlLocalize(@"menu.config.gametype.bootcamp")
                                                        description:PearlLocalize(@"menu.config.gametype.bootcamp.desc")
                                                               mode:GorillasModeBootCamp
                                                singleplayerAICount:1 multiplayerAICount:0 multiplayerHumanCount:0],
                           [GameConfiguration configurationWithName:PearlLocalize(@"menu.config.gametype.classic")
                                                        description:PearlLocalize(@"menu.config.gametype.classic.desc")
                                                               mode:GorillasModeClassic
                                                singleplayerAICount:1 multiplayerAICount:0 multiplayerHumanCount:4],
#ifndef LITE
                           [GameConfiguration configurationWithName:PearlLocalize(@"menu.config.gametype.dynamic")
                                                        description:PearlLocalize(@"menu.config.gametype.dynamic.desc")
                                                               mode:GorillasModeDynamic
                                                singleplayerAICount:1 multiplayerAICount:0 multiplayerHumanCount:0],
                           [GameConfiguration configurationWithName:PearlLocalize(@"menu.config.gametype.team")
                                                        description:PearlLocalize(@"menu.config.gametype.team.desc")
                                                               mode:GorillasModeTeam
                                                singleplayerAICount:0 multiplayerAICount:2 multiplayerHumanCount:2],
                           [GameConfiguration configurationWithName:PearlLocalize(@"menu.config.gametype.lms")
                                                        description:PearlLocalize(@"menu.config.gametype.lms.desc")
                                                               mode:GorillasModeLMS
                                                singleplayerAICount:3 multiplayerAICount:3 multiplayerHumanCount:3],
#endif
                           nil];

    offMessages         = [[NSArray alloc] initWithObjects:
                           @"menu.config.message.off.1",
                           @"menu.config.message.off.2",
                           nil];

    hitMessages         = [[NSArray alloc] initWithObjects:
                           @"menu.config.message.hit.1",
                           @"menu.config.message.hit.2",
                           @"menu.config.message.hit.3",
                           @"menu.config.message.hit.4",
                           nil];

    NSDictionary *themes = [CityTheme getThemes];
    NSString *defaultThemeName = [CityTheme defaultThemeName];
    CityTheme *theme = [themes objectForKey:defaultThemeName];

    [self.defaults
     registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithBool:YES],                              NSStringFromSelector(@selector(askForReviews)),
                       
                       [CityTheme defaultThemeName],                               NSStringFromSelector(@selector(cityTheme)),

                       [NSNumber numberWithUnsignedInt:[theme varFloors]],         NSStringFromSelector(@selector(varFloors)),
                       [NSNumber numberWithUnsignedInt:[theme fixedFloors]],       NSStringFromSelector(@selector(fixedFloors)),
                       [NSNumber numberWithUnsignedInt:[theme buildingAmount]],    NSStringFromSelector(@selector(buildingAmount)),
                       [NSNumber numberWithInteger:    1],                         NSStringFromSelector(@selector(buildingSpeed)),
                       [theme buildingColors],                                     NSStringFromSelector(@selector(buildingColors)),

                       [NSNumber numberWithUnsignedInt:[theme windowAmount]],      NSStringFromSelector(@selector(windowAmount)),
                       [NSNumber numberWithUnsignedLong:[theme windowColorOn]],    NSStringFromSelector(@selector(windowColorOn)),
                       [NSNumber numberWithUnsignedLong:[theme windowColorOff]],   NSStringFromSelector(@selector(windowColorOff)),

                       [NSNumber numberWithUnsignedLong:[theme skyColor]],         NSStringFromSelector(@selector(skyColor)),
                       [NSNumber numberWithUnsignedLong:[theme starColor]],        NSStringFromSelector(@selector(starColor)),
                       [NSNumber numberWithInteger:     2],                        NSStringFromSelector(@selector(starSpeed)),
                       [NSNumber numberWithUnsignedInt:[theme starAmount]],        NSStringFromSelector(@selector(starAmount)),

                       [NSNumber numberWithInteger:    3],                         NSStringFromSelector(@selector(lives)),
                       [NSNumber numberWithFloat:      [theme windModifier]],      NSStringFromSelector(@selector(windModifier)),
                       [NSNumber numberWithUnsignedInt:[theme gravity]],           NSStringFromSelector(@selector(gravity)),
                       [NSNumber numberWithInteger:    30],                        NSStringFromSelector(@selector(minGravity)),
                       [NSNumber numberWithInteger:    150],                       NSStringFromSelector(@selector(maxGravity)),

                       [NSNumber numberWithFloat:      0.5f],                      NSStringFromSelector(@selector(gameScrollDuration)),

                       [NSNumber numberWithBool:       YES],                       NSStringFromSelector(@selector(replay)),
                       [NSNumber numberWithBool:       YES],                       NSStringFromSelector(@selector(followThrow)),

                       [NSArray arrayWithObjects:
                        @"Fighting_Gorillas.mp3",
                        @"Flow_Square.mp3",
                        @"Happy_Fun_Ball.mp3",
                        @"Man_Or_Machine_Gorillas.mp3",
                        @"RC_Car.mp3",
                        @"sequential",
                        @"random",
                        @"",
                        nil],                                                      NSStringFromSelector(@selector(tracks)),
                       [NSArray arrayWithObjects:
                        PearlLocalize(@"menu.config.song.fighting_gorillas"),
                        PearlLocalize(@"menu.config.song.flow_square"),
                        PearlLocalize(@"menu.config.song.happy_fun_ball"),
                        PearlLocalize(@"menu.config.song.man_or_machine"),
                        PearlLocalize(@"menu.config.song.rc_car"),
                        PearlLocalize(@"menu.config.song.sequential"),
                        PearlLocalize(@"menu.config.song.random"),
                        PearlLocalize(@"menu.config.song.off"),
                        nil],                                                      NSStringFromSelector(@selector(trackNames)),

                       [NSNumber numberWithInteger:    1],                         NSStringFromSelector(@selector(activeGameConfigurationIndex)),
                       [NSNumber numberWithUnsignedInt:GorillasModeBootCamp],      NSStringFromSelector(@selector(mode)),
                       [NSNumber numberWithInteger:    -5],                        NSStringFromSelector(@selector(missScore)),
                       [NSNumber numberWithInteger:    50],                        NSStringFromSelector(@selector(killScore)),
                       [NSNumber numberWithFloat:      2],                         NSStringFromSelector(@selector(bonusOneShot)),
                       [NSNumber numberWithFloat:      50],                        NSStringFromSelector(@selector(bonusSkill)),
                       [NSNumber numberWithInteger:    5],                         NSStringFromSelector(@selector(deathScoreRatio)),

                       [NSNumber numberWithUnsignedInt:GorillasPlayerModelGorilla],NSStringFromSelector(@selector(playerModel)),
                       [NSDictionary dictionary],                                  NSStringFromSelector(@selector(scores)),
                       [NSNumber numberWithInteger:    0],                         NSStringFromSelector(@selector(skill)),
                       [NSNumber numberWithFloat:      0.3f],                      NSStringFromSelector(@selector(level)),
                       levelNames,                                                 NSStringFromSelector(@selector(levelNames)),
                       [NSNumber numberWithFloat:      0.03f],                     NSStringFromSelector(@selector(levelProgress)),

                       nil]];

    updateTriggers  = [[NSArray alloc] initWithObjects:
                       NSStringFromSelector(@selector(largeFontSize)),
                       NSStringFromSelector(@selector(smallFontSize)),
                       NSStringFromSelector(@selector(fontSize)),
                       NSStringFromSelector(@selector(fontName)),
                       NSStringFromSelector(@selector(fixedFontName)),
                       NSStringFromSelector(@selector(cityTheme)),
                       NSStringFromSelector(@selector(gravity)),
                       NSStringFromSelector(@selector(soundFx)),
                       NSStringFromSelector(@selector(voice)),
                       NSStringFromSelector(@selector(vibration)),
                       NSStringFromSelector(@selector(replay)),
                       NSStringFromSelector(@selector(followThrow)),
                       NSStringFromSelector(@selector(tracks)),
                       NSStringFromSelector(@selector(trackNames)),
                       NSStringFromSelector(@selector(currentTrack)),
                       NSStringFromSelector(@selector(level)),
                       NSStringFromSelector(@selector(levelNames)),
                       nil
                       ];
    [self.resetTriggers setObject:@"mainMenuLayer"      forKey:NSStringFromSelector(@selector(activeGameConfigurationIndex))];
    [self.resetTriggers setObject:@"customGameLayer"    forKey:NSStringFromSelector(@selector(mode))];

    return self;
}


-(void) dealloc {

    [CityTheme forgetThemes];

    [super dealloc];
}


+(GorillasConfig *) get {

    return (GorillasConfig *)[super get];
}


-(NSString *) messageForOff {

    return PearlLocalizeDyn([offMessages objectAtIndex:(NSUInteger)((unsigned)PearlGameRandom() % offMessages.count)]);
}
-(NSString *) messageForHitBy:(GorillaLayer *)byGorilla on:(GorillaLayer *)onGorilla {

    return PearlLocalizeDyn([hitMessages objectAtIndex:(unsigned)PearlGameRandom() % hitMessages.count], byGorilla.name, onGorilla.name);
}


-(ccColor4B) buildingColor {

    return ccc4l([[self.buildingColors objectAtIndex:(NSUInteger)((unsigned)PearlGameRandom() % [self.buildingColors count])] unsignedLongValue]);
}


#pragma mark Game Configuration

+(NSString *)descriptionForMode:(GorillasMode)mode {

    switch (mode) {
        case GorillasModeBootCamp:
            return PearlLocalize(@"menu.config.gametype.bootcamp");
        case GorillasModeClassic:
            return PearlLocalize(@"menu.config.gametype.classic");
        case GorillasModeDynamic:
            return PearlLocalize(@"menu.config.gametype.dynamic");
        case GorillasModeTeam:
            return PearlLocalize(@"menu.config.gametype.team");
        case GorillasModeLMS:
            return PearlLocalize(@"menu.config.gametype.lms");
        case GorillasModeCount:
            break;
    }

    err(@"Unsupported game mode.");
    return nil;
}

+(NSArray *)descriptionsForModes {

    NSMutableArray *descriptions = [NSMutableArray arrayWithCapacity:GorillasModeCount];
    for (NSUInteger mode = 0; mode < GorillasModeCount; ++mode)
        [descriptions addObject:[self descriptionForMode:mode]];

    return descriptions;
}

+(NSString *)nameForMode:(GorillasMode)mode {

    switch (mode) {
        case GorillasModeBootCamp:
            return @"BootCamp";
        case GorillasModeClassic:
            return @"Classic";
        case GorillasModeDynamic:
            return @"Dynamic";
        case GorillasModeTeam:
            return @"Team";
        case GorillasModeLMS:
            return @"LastManStanding";
        case GorillasModeCount:
            break;
    }

    err(@"Unsupported game mode.");
    return nil;
}

+ (NSString *)categoryForMode:(GorillasMode)mode {

#ifdef LITE
    return @"grp.com.lyndir.lhunath.gorillas.Lite";
#else
    return [NSString stringWithFormat:@"grp.com.lyndir.lhunath.gorillas.%@", [GorillasConfig nameForMode:mode]];
#endif
}

+ (NSString *)nameForLevel:(NSNumber *)aLevel {

    return [[self get].levelNames objectAtIndex:(NSUInteger)([aLevel floatValue] * [[self get].levelNames count])];
}


-(NSInteger) deathScore {

    // Some info on Death Score Ratios:
    // Death score balances with kill score when player makes [deathScoreRatio] amount of misses.
    // More misses -> score goes down faster.
    // Less misses -> score goes down slower.
    // As a result, when player A dies equally often as player B but misses less, his score will be higher.

    return -([self.killScore intValue] + [self.deathScoreRatio intValue] * [self.missScore intValue]);
}


#pragma mark User Status

static NSMutableDictionary *GorillasScores = nil;

-(int64_t)recordScoreDelta:(int64_t)scoreDelta forMode:(GorillasMode)mode {

    NSString *category = [GorillasConfig categoryForMode:mode];
    if (GorillasScores == nil) {
        NSData *scores = self.scores;
        if ([scores isKindOfClass:[NSData class]])
            GorillasScores = [[NSKeyedUnarchiver unarchiveObjectWithData:scores] retain];
        if (!NSNullToNil(GorillasScores))
            GorillasScores = [[NSMutableDictionary alloc] init];
    }

    GKScore *score = [[[GKScore alloc] initWithCategory:category] autorelease];
    score.value = MAX(0, ((GKScore *)[GorillasScores objectForKey:category]).value + scoreDelta);
    [GorillasScores setObject:score forKey:category];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.scores = [NSKeyedArchiver archivedDataWithRootObject:GorillasScores];

        [score reportScoreWithCompletionHandler:^(NSError *error) {
            if (error)
                wrn(@"Error reporting score: %@", error);
        }];
    });

    return score.value;
}

-(int64_t)scoreForMode:(GorillasMode)mode {
    
    if (!mode)
        return 0;

    NSString *category = [GorillasConfig categoryForMode:mode];

    return ((GKScore *)[GorillasScores objectForKey:category]).value;
}

-(void) levelUp {

    self.level = [NSNumber numberWithFloat:fminf(0.9f, fmaxf(0.1f, [self.level floatValue] + [self.levelProgress floatValue]))];
}
-(void) levelDown {

    self.level = [NSNumber numberWithFloat:fminf(0.9f, fmaxf(0.1f, [self.level floatValue] - [self.levelProgress floatValue]))];
}


@end
