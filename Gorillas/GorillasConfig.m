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

@interface GorillasConfig()

@property(nonatomic, readwrite, strong) NSArray *gameConfigurations;

@end

@implementation GorillasConfig {
    NSArray *offMessages, *hitMessages;
}

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

- (id)init {

    if (!(self = [super init]))
        return self;

    NSArray *levelNames = @[
            PearlLocalize( @"menu.config.level.one" ),
            PearlLocalize( @"menu.config.level.two" ),
            PearlLocalize( @"menu.config.level.three" ),
            PearlLocalize( @"menu.config.level.four" ),
            PearlLocalize( @"menu.config.level.five" ),
            PearlLocalize( @"menu.config.level.six" ),
            PearlLocalize( @"menu.config.level.seven" ),
            PearlLocalize( @"menu.config.level.eight" )
    ];

    [self initGameConfigurations];

    offMessages = @[
            @"menu.config.message.off.1",
            @"menu.config.message.off.2"
    ];

    hitMessages = @[
            @"menu.config.message.hit.1",
            @"menu.config.message.hit.2",
            @"menu.config.message.hit.3",
            @"menu.config.message.hit.4"
    ];

    NSDictionary *themes = [CityTheme getThemes];
    NSString *defaultThemeName = [CityTheme defaultThemeName];
    CityTheme *theme = themes[defaultThemeName];

    [self.defaults
            registerDefaults:@{
                    NSStringFromSelector( @selector(iTunesID) )                     : @"302275459",
                    NSStringFromSelector( @selector(askForReviews) )                : @YES,

                    NSStringFromSelector( @selector(cityTheme) )                    : [CityTheme defaultThemeName],

                    NSStringFromSelector( @selector(varFloors) )                    : @([theme varFloors]),
                    NSStringFromSelector( @selector(fixedFloors) )                  : @([theme fixedFloors]),
                    NSStringFromSelector( @selector(buildingAmount) )               : @([theme buildingAmount]),
                    NSStringFromSelector( @selector(buildingSpeed) )                : @1,
                    NSStringFromSelector( @selector(buildingColors) )               : [theme buildingColors],

                    NSStringFromSelector( @selector(windowAmount) )                 : @([theme windowAmount]),
                    NSStringFromSelector( @selector(windowColorOn) )                : @([theme windowColorOn]),
                    NSStringFromSelector( @selector(windowColorOff) )               : @([theme windowColorOff]),

                    NSStringFromSelector( @selector(skyColor) )                     : @([theme skyColor]),
                    NSStringFromSelector( @selector(starColor) )                    : @([theme starColor]),
                    NSStringFromSelector( @selector(starSpeed) )                    : @2,
                    NSStringFromSelector( @selector(starAmount) )                   : @([theme starAmount]),

                    NSStringFromSelector( @selector(lives) )                        : @3,
                    NSStringFromSelector( @selector(windModifier) )                 : @([theme windModifier]),
                    NSStringFromSelector( @selector(gravity) )                      : @([theme gravity]),
                    NSStringFromSelector( @selector(minGravity) )                   : @30,
                    NSStringFromSelector( @selector(maxGravity) )                   : @150,

                    NSStringFromSelector( @selector(gameScrollDuration) )           : @0.5f,

                    NSStringFromSelector( @selector(replay) )                       : @YES,
                    NSStringFromSelector( @selector(followThrow) )                  : @YES,

                    NSStringFromSelector( @selector(tracks) )                       : @[
                            @"Fighting_Gorillas.mp3",
                            @"Flow_Square.mp3",
                            @"Happy_Fun_Ball.mp3",
                            @"Man_Or_Machine_Gorillas.mp3",
                            @"RC_Car.mp3",
                            @"sequential",
                            @"random",
                            @""
                    ],
                    NSStringFromSelector( @selector(trackNames) )                   : @[
                            PearlLocalize( @"menu.config.song.fighting_gorillas" ),
                            PearlLocalize( @"menu.config.song.flow_square" ),
                            PearlLocalize( @"menu.config.song.happy_fun_ball" ),
                            PearlLocalize( @"menu.config.song.man_or_machine" ),
                            PearlLocalize( @"menu.config.song.rc_car" ),
                            PearlLocalize( @"menu.config.song.sequential" ),
                            PearlLocalize( @"menu.config.song.random" ),
                            PearlLocalize( @"menu.config.song.off" )
                    ],

                    NSStringFromSelector( @selector(activeGameConfigurationIndex) ) : @1,
                    NSStringFromSelector( @selector(mode) )                         : @(GorillasModeBootCamp),
                    NSStringFromSelector( @selector(missScore) )                    : @-5,
                    NSStringFromSelector( @selector(killScore) )                    : @50,
                    NSStringFromSelector( @selector(bonusOneShot) )                 : @2.0f,
                    NSStringFromSelector( @selector(bonusSkill) )                   : @50.0f,
                    NSStringFromSelector( @selector(deathScoreRatio) )              : @5,

                    NSStringFromSelector( @selector(playerModel) )                  : @(GorillasPlayerModelGorilla),
                    NSStringFromSelector( @selector(scores) )                       : @{ },
                    NSStringFromSelector( @selector(skill) )                        : @0,
                    NSStringFromSelector( @selector(level) )                        : @0.3f,
                    NSStringFromSelector( @selector(levelNames) )                   : levelNames,
                    NSStringFromSelector( @selector(levelProgress) )                : @0.03f
            }];

    (self.resetTriggers)[NSStringFromSelector( @selector(activeGameConfigurationIndex) )] = @"mainMenuLayer";
    (self.resetTriggers)[NSStringFromSelector( @selector(mode) )] = @"customGameLayer";

    return self;
}

- (void)initGameConfigurations {

    self.gameConfigurations = @[
            [GameConfiguration configurationWithName:PearlLocalize( @"menu.config.gametype.bootcamp" )
                                         description:PearlLocalize( @"menu.config.gametype.bootcamp.desc" )
                                                mode:GorillasModeBootCamp
                                 singleplayerAICount:1 multiplayerAICount:0 multiplayerHumanCount:0],
            [GameConfiguration configurationWithName:PearlLocalize( @"menu.config.gametype.classic" )
                                         description:PearlLocalize( @"menu.config.gametype.classic.desc" )
                                                mode:GorillasModeClassic
                                 singleplayerAICount:1 multiplayerAICount:0 multiplayerHumanCount:4],
            [GameConfiguration configurationWithName:PearlLocalize( @"menu.config.gametype.dynamic" )
                                         description:PearlLocalize( @"menu.config.gametype.dynamic.desc" )
                                                mode:GorillasModeDynamic
                                 singleplayerAICount:1 multiplayerAICount:0 multiplayerHumanCount:0],
            [GameConfiguration configurationWithName:PearlLocalize( @"menu.config.gametype.team" )
                                         description:PearlLocalize( @"menu.config.gametype.team.desc" )
                                                mode:GorillasModeTeam
                                 singleplayerAICount:0 multiplayerAICount:2 multiplayerHumanCount:2],
            [GameConfiguration configurationWithName:PearlLocalize( @"menu.config.gametype.lms" )
                                         description:PearlLocalize( @"menu.config.gametype.lms.desc" )
                                                mode:GorillasModeLMS
                                 singleplayerAICount:3 multiplayerAICount:3 multiplayerHumanCount:3],
    ];
}

- (void)dealloc {

    [CityTheme forgetThemes];
}

+ (GorillasConfig *)get {

    return (GorillasConfig *)[super get];
}

- (NSString *)messageForOff {

    return PearlLocalizeDyn( offMessages[(NSUInteger)((unsigned)PearlGameRandom() % offMessages.count)] );
}

- (NSString *)messageForHitBy:(GorillaLayer *)byGorilla on:(GorillaLayer *)onGorilla {

    return PearlLocalizeDyn( hitMessages[(unsigned)PearlGameRandom() % hitMessages.count], byGorilla.name, onGorilla.name );
}

- (ccColor4B)buildingColor {

    return ccc4l( [(self.buildingColors)[(NSUInteger)((unsigned)PearlGameRandom() % [self.buildingColors count])] unsignedLongValue] );
}


#pragma mark Game Configuration

+ (NSString *)descriptionForMode:(GorillasMode)mode {

    switch (mode) {
        case GorillasModeBootCamp:
            return PearlLocalize( @"menu.config.gametype.bootcamp" );
        case GorillasModeClassic:
            return PearlLocalize( @"menu.config.gametype.classic" );
        case GorillasModeDynamic:
            return PearlLocalize( @"menu.config.gametype.dynamic" );
        case GorillasModeTeam:
            return PearlLocalize( @"menu.config.gametype.team" );
        case GorillasModeLMS:
            return PearlLocalize( @"menu.config.gametype.lms" );
        case GorillasModeCount:
            break;
    }

    err(@"Unsupported game mode.");
    return nil;
}

+ (NSArray *)descriptionsForModes {

    NSMutableArray *descriptions = [NSMutableArray arrayWithCapacity:GorillasModeCount];
    for (NSUInteger mode = 0; mode < GorillasModeCount; ++mode)
        [descriptions addObject:[self descriptionForMode:mode]];

    return descriptions;
}

+ (NSString *)nameForMode:(GorillasMode)mode {

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

    return [NSString stringWithFormat:@"grp.com.lyndir.lhunath.gorillas.%@", [GorillasConfig nameForMode:mode]];
}

+ (NSString *)nameForLevel:(NSNumber *)aLevel {

    return ([self get].levelNames)[(NSUInteger)([aLevel floatValue] * [[self get].levelNames count])];
}

- (NSInteger)deathScore {

    // Some info on Death Score Ratios:
    // Death score balances with kill score when player makes [deathScoreRatio] amount of misses.
    // More misses -> score goes down faster.
    // Less misses -> score goes down slower.
    // As a result, when player A dies equally often as player B but misses less, his score will be higher.

    return -([self.killScore intValue] + [self.deathScoreRatio intValue] * [self.missScore intValue]);
}


#pragma mark User Status

static NSMutableDictionary *GorillasScores = nil;

- (int64_t)recordScoreDelta:(int64_t)scoreDelta forMode:(GorillasMode)mode {

    NSString *category = [GorillasConfig categoryForMode:mode];
    if (GorillasScores == nil) {
        NSData *scores = self.scores;
        if ([scores isKindOfClass:[NSData class]])
            GorillasScores = [NSKeyedUnarchiver unarchiveObjectWithData:scores];
        if (!NSNullToNil(GorillasScores))
            GorillasScores = [[NSMutableDictionary alloc] init];
    }

    GKScore *score = [[GKScore alloc] initWithCategory:category];
    score.value = MAX(0, ((GKScore *)[GorillasScores objectForKey:category]).value + scoreDelta);
    GorillasScores[category] = score;

    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0 ), ^{
        self.scores = [NSKeyedArchiver archivedDataWithRootObject:GorillasScores];

        [score reportScoreWithCompletionHandler:^(NSError *error) {
            if (error)
            wrn(@"Error reporting score: %@", error);
        }];
    } );

    return score.value;
}

- (int64_t)scoreForMode:(GorillasMode)mode {

    if (!mode)
        return 0;

    NSString *category = [GorillasConfig categoryForMode:mode];

    return ((GKScore *)GorillasScores[category]).value;
}

- (void)levelUp {

    self.level = @(fminf( 0.9f, fmaxf( 0.1f, [self.level floatValue] + [self.levelProgress floatValue] ) ));
}

- (void)levelDown {

    self.level = @(fminf( 0.9f, fmaxf( 0.1f, [self.level floatValue] - [self.levelProgress floatValue] ) ));
}

@end
