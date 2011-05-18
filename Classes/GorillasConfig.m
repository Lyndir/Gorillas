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
                           NSLocalizedString(@"menu.config.level.one",   @"Junior"),
                           NSLocalizedString(@"menu.config.level.two",   @"Trainee"),
                           NSLocalizedString(@"menu.config.level.three", @"Adept"),
                           NSLocalizedString(@"menu.config.level.four",  @"Skilled"),
                           NSLocalizedString(@"menu.config.level.five",  @"Masterful"),
                           NSLocalizedString(@"menu.config.level.six",   @"Sniper"),
                           NSLocalizedString(@"menu.config.level.seven", @"Deadly"),
                           NSLocalizedString(@"menu.config.level.eight", @"Impossible"),
                           nil];
    
    gameConfigurations  = [[NSArray alloc] initWithObjects:
                           [GameConfiguration configurationWithName:NSLocalizedString(@"menu.config.gametype.bootcamp", @"Boot Camp")
                                                        description:NSLocalizedString(@"menu.config.gametype.bootcamp.desc", @"Practice your aim with some helpful hints.")
                                                               mode:GorillasModeBootCamp
                                                singleplayerAICount:1 multiplayerAICount:0 multiplayerHumanCount:0],
                           [GameConfiguration configurationWithName:NSLocalizedString(@"menu.config.gametype.classic", @"Classic")
                                                        description:NSLocalizedString(@"menu.config.gametype.classic.desc", @"Quick and simple one-on-one battle.")
                                                               mode:GorillasModeClassic
                                                singleplayerAICount:1 multiplayerAICount:0 multiplayerHumanCount:4],
                           [GameConfiguration configurationWithName:NSLocalizedString(@"menu.config.gametype.dynamic", @"Dynamic")
                                                        description:NSLocalizedString(@"menu.config.gametype.dynamic.desc", @"One-on-one battle with adapting skill and difficulty.")
                                                               mode:GorillasModeDynamic
                                                singleplayerAICount:1 multiplayerAICount:0 multiplayerHumanCount:4],
                           [GameConfiguration configurationWithName:NSLocalizedString(@"menu.config.gametype.team", @"Team Battle")
                                                        description:NSLocalizedString(@"menu.config.gametype.team.desc", @"Face the AIs with a little help from your friends.")
                                                               mode:GorillasModeTeam
                                                singleplayerAICount:0 multiplayerAICount:2 multiplayerHumanCount:2],
                           [GameConfiguration configurationWithName:NSLocalizedString(@"menu.config.gametype.lms", @"Last Man Standing")
                                                        description:NSLocalizedString(@"menu.config.gametype.lms.desc", @"Gorillas have lives; be the last left standing!")
                                                               mode:GorillasModeLMS
                                                singleplayerAICount:3 multiplayerAICount:3 multiplayerHumanCount:3],
                           nil];
    
    offMessages         = [[NSArray alloc] initWithObjects:
                           NSLocalizedString(@"menu.config.message.off.1", @"Way out."),
                           NSLocalizedString(@"menu.config.message.off.2", @"Just a little too far."),
                           nil];
    
    hitMessages         = [[NSArray alloc] initWithObjects:
                           NSLocalizedString(@"menu.config.message.hit.1", @"%2$@ ate %1$@'s banana."),
                           NSLocalizedString(@"menu.config.message.hit.2", @"%2$@ didn't dodge %1$@'s banana."),
                           NSLocalizedString(@"menu.config.message.hit.3", @"%1$@ buried %2$@."),
                           NSLocalizedString(@"menu.config.message.hit.4", @"%1$@ incinerated %2$@."),
                           nil];
    
    NSDictionary *themes = [CityTheme getThemes];
    NSString *defaultThemeName = [CityTheme defaultThemeName];
    CityTheme *theme = [themes objectForKey:defaultThemeName];
    
    [self.defaults
     registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                       [CityTheme defaultThemeName],                               cCityTheme,
     
                       [NSNumber numberWithInteger:    [theme varFloors]],         cVarFloors,
                       [NSNumber numberWithInteger:    [theme fixedFloors]],       cFixedFloors,
                       [NSNumber numberWithInteger:    [theme buildingAmount]],    cBuildingAmount,
                       [NSNumber numberWithInteger:    1],                         cBuildingSpeed,
                       [theme buildingColors],                                     cBuildingColors,
     
                       [NSNumber numberWithInteger:    [theme windowAmount]],      cWindowAmount,
                       [NSNumber numberWithLong:       [theme windowColorOn]],     cWindowColorOn,
                       [NSNumber numberWithLong:       [theme windowColorOff]],    cWindowColorOff,
     
                       [NSNumber numberWithLong:       [theme skyColor]],          cSkyColor,
                       [NSNumber numberWithLong:       [theme starColor]],         cStarColor,
                       [NSNumber numberWithInteger:    10],                        cStarSpeed,
                       [NSNumber numberWithInteger:    [theme starAmount]],        cStarAmount,
                       
                       [NSNumber numberWithInteger:    3],                         cLives,
                       [NSNumber numberWithFloat:      [theme windModifier]],      cWindModifier,
                       [NSNumber numberWithInteger:    [theme gravity]],           cGravity,
                       [NSNumber numberWithInteger:    30],                        cMinGravity,
                       [NSNumber numberWithInteger:    150],                       cMaxGravity,
                       
                       [NSNumber numberWithFloat:      0.5f],                      cGameScrollDuration,
                       
                       [NSNumber numberWithBool:       YES],                       cReplay,
                       [NSNumber numberWithBool:       YES],                       cFollowThrow,
                       
                       [NSArray arrayWithObjects:
                        @"Fighting_Gorillas.mp3",
                        @"Flow_Square.mp3",
                        @"Happy_Fun_Ball.mp3",
                        @"Man_Or_Machine_Gorillas.mp3",
                        @"RC_Car.mp3",
                        @"sequential",
                        @"random",
                        @"",
                        nil],                                                      cTracks,
                       [NSArray arrayWithObjects:
                        l(@"menu.config.song.fighting_gorillas"),
                        l(@"menu.config.song.flow_square"),
                        l(@"menu.config.song.happy_fun_ball"),
                        l(@"menu.config.song.man_or_machine"),
                        l(@"menu.config.song.rc_car"),
                        l(@"menu.config.song.sequential"),
                        l(@"menu.config.song.random"),
                        l(@"menu.config.song.off"),
                        nil],                                                      cTrackNames,
                       
                       [NSNumber numberWithInteger:    1],                         cActiveGameConfigurationIndex,
                       [NSNumber numberWithUnsignedInt:GorillasModeBootCamp],      cMode,
                       [NSNumber numberWithInteger:    -5],                        cMissScore,
                       [NSNumber numberWithInteger:    50],                        cKillScore,
                       [NSNumber numberWithFloat:      2],                         cBonusOneShot,
                       [NSNumber numberWithFloat:      50],                        cBonusSkill,
                       [NSNumber numberWithInteger:    5],                         cDeathScoreRatio,
                       
                       [NSNumber numberWithUnsignedInt:GorillasPlayerModelGorilla],cPlayerModel,
                       [NSDictionary dictionary],                                  cScores,
                       [NSNumber numberWithInteger:    0],                         cSkill,
                       [NSNumber numberWithFloat:      0.3f],                      cLevel,
                       levelNames,                                                 cLevelNames,
                       [NSNumber numberWithFloat:      0.03f],                     cLevelProgress,
                       
                       nil]];
    
    updateTriggers  = [[NSArray alloc] initWithObjects:
                       cLargeFontSize,
                       cSmallFontSize,
                       cFontSize,
                       cFontName,
                       cFixedFontName,
                       cCityTheme,
                       cGravity,
                       cSoundFx,
                       cVoice,
                       cVibration,
                       cVisualFx,
                       cReplay,
                       cFollowThrow,
                       cTracks,
                       cTrackNames,
                       cCurrentTrack,
                       cLevel,
                       cLevelNames,
                       nil
                       ];
    [self.resetTriggers setObject:@"gameLayer.skyLayer" forKey:cVisualFx];
    [self.resetTriggers setObject:@"newGameLayer" forKey:cActiveGameConfigurationIndex];
    [self.resetTriggers setObject:@"customGameLayer" forKey:cMode];
    
    return self;
}


-(void) dealloc {
    
    [CityTheme forgetThemes];
    
    [super dealloc];
}


+(GorillasConfig *) get {
    
    return (GorillasConfig *)[super get];
}


-(NSString *) offMessage {

    return [offMessages objectAtIndex:gameRandom() % offMessages.count];
}
-(NSString *) hitMessage {
    
    return [hitMessages objectAtIndex:gameRandom() % hitMessages.count];
}


-(ccColor4B) buildingColor {
    
    return ccc4l([[self.buildingColors objectAtIndex:gameRandom() % [self.buildingColors count]] longValue]);
}


#pragma mark Game Configuration

+(NSString *)descriptionForMode:(GorillasMode)mode {

    switch (mode) {
        case GorillasModeBootCamp:
            return l(@"menu.config.gametype.bootcamp", @"Boot Camp");
        case GorillasModeClassic:
            return l(@"menu.config.gametype.classic", @"Classic Game");
        case GorillasModeDynamic:
            return l(@"menu.config.gametype.dynamic", @"Dynamic Game");
        case GorillasModeTeam:
            return l(@"menu.config.gametype.team", @"Teamed Game");
        case GorillasModeLMS:
            return l(@"menu.config.gametype.lms", @"Last Man Standing");
        case GorillasModeCount:
            break;
    }

    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Unsupported game mode." userInfo:nil];
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

    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Unsupported game mode." userInfo:nil];
}

+ (NSString *)nameForLevel:(NSNumber *)aLevel {
    
    int levelIndex = (int)([aLevel floatValue] * [[self get].levelNames count]);
    
    return [[self get].levelNames objectAtIndex:levelIndex];
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

-(void)recordScore:(long long)scoreValue forMode:(GorillasMode)mode {
    
    NSString *category = [NSString stringWithFormat:@"com.lyndir.lhunath.gorillas.%@", [GorillasConfig nameForMode:mode]];
    
    if(scoreValue < 0)
        scoreValue = 0;
    GKScore *score = [[GKScore alloc] initWithCategory:category];
    score.value = scoreValue;

    NSMutableDictionary *newScores = [self.scores mutableCopy];
    [newScores setObject:score forKey:category];
    self.scores = newScores;
    [newScores release];
    
    [score reportScoreWithCompletionHandler:^(NSError *error) {
        if (error)
            err(@"Error reporting score: %@", error);
    }];
}

-(long long)scoreForMode:(GorillasMode)mode {
    
    NSString *category = [GorillasConfig nameForMode:mode];

    return ((GKScore *)[self.scores objectForKey:category]).value;
}

-(void) levelUp {
    
    self.level = [NSNumber numberWithFloat:fminf(0.9f, fmaxf(0.1f, [self.level floatValue] + [self.levelProgress floatValue]))];
}
-(void) levelDown {
    
    self.level = [NSNumber numberWithFloat:fminf(0.9f, fmaxf(0.1f, [self.level floatValue] + [self.levelProgress floatValue]))];
}


@end
