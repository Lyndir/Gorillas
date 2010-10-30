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

#define dCityTheme                      NSStringFromSelector(@selector(cityTheme))
#define dFixedFloors                    NSStringFromSelector(@selector(fixedFloors))
#define dBuildingMax                    NSStringFromSelector(@selector(buildingMax))
#define dBuildingAmount                 NSStringFromSelector(@selector(buildingAmount))
#define dBuildingSpeed                  NSStringFromSelector(@selector(buildingSpeed))
#define dBuildingColorCount             NSStringFromSelector(@selector(buildingColorCount))
#define dBuildingColors                 NSStringFromSelector(@selector(buildingColors))

#define dWindowAmount                   NSStringFromSelector(@selector(windowAmount))
#define dWindowColorOn                  NSStringFromSelector(@selector(windowColorOn))
#define dWindowColorOff                 NSStringFromSelector(@selector(windowColorOff))

#define dSkyColor                       NSStringFromSelector(@selector(skyColor))
#define dStarColor                      NSStringFromSelector(@selector(starColor))
#define dStarSpeed                      NSStringFromSelector(@selector(starSpeed))
#define dStarAmount                     NSStringFromSelector(@selector(starAmount))

#define dLives                          NSStringFromSelector(@selector(lives))
#define dWindModifier                   NSStringFromSelector(@selector(windModifier))
#define dGravity                        NSStringFromSelector(@selector(gravity))
#define dMinGravity                     NSStringFromSelector(@selector(minGravity))
#define dMaxGravity                     NSStringFromSelector(@selector(maxGravity))

#define dGameScrollDuration             NSStringFromSelector(@selector(gameScrollDuration))

#define dActiveGameConfigurationIndex   NSStringFromSelector(@selector(activeGameConfigurationIndex))
#define dMode                           NSStringFromSelector(@selector(mode))
#define dMissScore                      NSStringFromSelector(@selector(missScore))
#define dKillScore                      NSStringFromSelector(@selector(killScore))
#define dBonusOneShot                   NSStringFromSelector(@selector(bonusOneShot))
#define dBonusSkill                     NSStringFromSelector(@selector(bonusSkill))
#define dDeathScoreRatio                NSStringFromSelector(@selector(deathScoreRatio))

#define dReplay                         NSStringFromSelector(@selector(replay))
#define dFollowThrow                    NSStringFromSelector(@selector(followThrow))

#define dPlayerModel                    NSStringFromSelector(@selector(playerModel))
#define dScore                          NSStringFromSelector(@selector(score))
#define dSkill                          NSStringFromSelector(@selector(skill))
#define dTopScoreHistory                NSStringFromSelector(@selector(topScoreHistory))
#define dLevel                          NSStringFromSelector(@selector(level))
#define dLevelNames                     NSStringFromSelector(@selector(levelNames))
#define dLevelProgress                  NSStringFromSelector(@selector(levelProgress))


@implementation GorillasConfig

@synthesize modes, modeStrings, gameConfigurations;

@dynamic cityTheme;
@dynamic fixedFloors, buildingMax, buildingAmount, buildingSpeed, buildingColors;
@dynamic windowAmount, windowColorOn, windowColorOff;
@dynamic skyColor, starColor, starSpeed, starAmount;
@dynamic lives, windModifier, gravity, minGravity, maxGravity;
@dynamic gameScrollDuration;
@dynamic level, levelNames, levelProgress;
@dynamic activeGameConfigurationIndex, mode, playerModel, score, skill, topScoreHistory, missScore, killScore, bonusOneShot, bonusSkill, deathScoreRatio;
@dynamic replay, followThrow;

#pragma mark Internal

-(id) init {

    if(!(self = [super init]))
        return self;

    NSArray *levelNames = [NSArray arrayWithObjects:
                           NSLocalizedString(@"config.level.one",   @"Junior"),
                           NSLocalizedString(@"config.level.two",   @"Trainee"),
                           NSLocalizedString(@"config.level.three", @"Adept"),
                           NSLocalizedString(@"config.level.four",  @"Skilled"),
                           NSLocalizedString(@"config.level.five",  @"Masterful"),
                           NSLocalizedString(@"config.level.six",   @"Sniper"),
                           NSLocalizedString(@"config.level.seven", @"Deadly"),
                           NSLocalizedString(@"config.level.eight", @"Impossible"),
                           nil];
    
    gameConfigurations  = [[NSArray alloc] initWithObjects:
                           [GameConfiguration configurationWithName:NSLocalizedString(@"config.gametype.bootcamp", @"Boot Camp")
                                                        description:NSLocalizedString(@"config.gametype.bootcamp.desc", @"Practice your aim with some helpful hints.")
                                                               mode:GorillasModeBootCamp
                                                            sHumans:1 mHumans:0
                                                               sAis:1    mAis:0],
                           [GameConfiguration configurationWithName:NSLocalizedString(@"config.gametype.classic", @"Classic")
                                                        description:NSLocalizedString(@"config.gametype.classic.desc", @"Quick and simple one-on-one battle.")
                                                               mode:GorillasModeClassic
                                                            sHumans:1 mHumans:2
                                                               sAis:1    mAis:0],
                           [GameConfiguration configurationWithName:NSLocalizedString(@"config.gametype.dynamic", @"Dynamic")
                                                        description:NSLocalizedString(@"config.gametype.dynamic.desc", @"One-on-one battle with adapting skill and difficulty.")
                                                               mode:GorillasModeDynamic
                                                            sHumans:1 mHumans:0
                                                               sAis:1    mAis:0],
                           [GameConfiguration configurationWithName:NSLocalizedString(@"config.gametype.team", @"Team Battle")
                                                        description:NSLocalizedString(@"config.gametype.team.desc", @"Face the AIs with a little help from your friends.")
                                                               mode:GorillasModeTeam
                                                            sHumans:0 mHumans:2
                                                               sAis:0    mAis:2],
                           [GameConfiguration configurationWithName:NSLocalizedString(@"config.gametype.lms", @"Last Man Standing")
                                                        description:NSLocalizedString(@"config.gametype.lms.desc", @"Gorillas have lives; be the last left standing!")
                                                               mode:GorillasModeLMS
                                                            sHumans:1 mHumans:2
                                                               sAis:3    mAis:3],
                           nil];
    
    modes               = [[NSArray alloc] initWithObjects:
                           [NSNumber numberWithUnsignedInt:GorillasModeBootCamp],
                           [NSNumber numberWithUnsignedInt:GorillasModeClassic],
                           [NSNumber numberWithUnsignedInt:GorillasModeDynamic],
                           [NSNumber numberWithUnsignedInt:GorillasModeTeam],
                           [NSNumber numberWithUnsignedInt:GorillasModeLMS],
                           nil];
    
    offMessages         = [[NSArray alloc] initWithObjects:
                           NSLocalizedString(@"config.message.off.1", @"Way out."),
                           NSLocalizedString(@"config.message.off.2", @"Just a little too far."),
                           nil];
    
    hitMessages         = [[NSArray alloc] initWithObjects:
                           NSLocalizedString(@"config.message.hit.1", @"%2$@ ate %1$@'s banana."),
                           NSLocalizedString(@"config.message.hit.2", @"%2$@ didn't dodge %1$@'s banana."),
                           NSLocalizedString(@"config.message.hit.3", @"%1$@ buried %2$@."),
                           NSLocalizedString(@"config.message.hit.4", @"%1$@ incinerated %2$@."),
                           nil];
    
    modeStrings         = [[NSDictionary alloc] initWithObjectsAndKeys:
                           NSLocalizedString(@"config.gametype.bootcamp", @"Boot Camp"),
                           [NSNumber numberWithUnsignedInt:GorillasModeBootCamp],
                           NSLocalizedString(@"config.gametype.classic", @"Classic Game"),
                           [NSNumber numberWithUnsignedInt:GorillasModeClassic],
                           NSLocalizedString(@"config.gametype.dynamic", @"Dynamic Game"),
                           [NSNumber numberWithUnsignedInt:GorillasModeDynamic],
                           NSLocalizedString(@"config.gametype.team", @"Teamed Game"),
                           [NSNumber numberWithUnsignedInt:GorillasModeTeam],
                           NSLocalizedString(@"config.gametype.lms", @"Last Man Standing"),
                           [NSNumber numberWithUnsignedInt:GorillasModeLMS],
                           nil
                           ];
    
    NSDictionary *themes = [CityTheme getThemes];
    NSString *defaultThemeName = [CityTheme defaultThemeName];
    CityTheme *theme = [themes objectForKey:defaultThemeName];
    
    [self.defaults
     registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                       [CityTheme defaultThemeName],                               dCityTheme,
     
                       [NSNumber numberWithInteger:    [theme fixedFloors]],       dFixedFloors,
                       [NSNumber numberWithFloat:      [theme buildingMax]],       dBuildingMax,
                       [NSNumber numberWithInteger:    [theme buildingAmount]],    dBuildingAmount,
                       [NSNumber numberWithInteger:    1],                         dBuildingSpeed,
                       [theme buildingColors],                                     dBuildingColors,
     
                       [NSNumber numberWithInteger:    [theme windowAmount]],      dWindowAmount,
                       [NSNumber numberWithLong:       [theme windowColorOn]],     dWindowColorOn,
                       [NSNumber numberWithLong:       [theme windowColorOff]],    dWindowColorOff,
     
                       [NSNumber numberWithLong:       [theme skyColor]],          dSkyColor,
                       [NSNumber numberWithLong:       [theme starColor]],         dStarColor,
                       [NSNumber numberWithInteger:    10],                        dStarSpeed,
                       [NSNumber numberWithInteger:    [theme starAmount]],        dStarAmount,
                       
                       [NSNumber numberWithInteger:    3],                         dLives,
                       [NSNumber numberWithFloat:      [theme windModifier]],      dWindModifier,
                       [NSNumber numberWithInteger:    [theme gravity]],           dGravity,
                       [NSNumber numberWithInteger:    30],                        dMinGravity,
                       [NSNumber numberWithInteger:    150],                       dMaxGravity,
                       
                       [NSNumber numberWithFloat:      0.5f],                      dGameScrollDuration,
                       
                       [NSNumber numberWithBool:       YES],                       dReplay,
                       [NSNumber numberWithBool:       YES],                       dFollowThrow,
                       
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
                       
                       [NSNumber numberWithInteger:    1],                         dActiveGameConfigurationIndex,
                       [NSNumber numberWithUnsignedInt:GorillasModeBootCamp],      dMode,
                       [NSNumber numberWithInteger:    -5],                        dMissScore,
                       [NSNumber numberWithInteger:    50],                        dKillScore,
                       [NSNumber numberWithFloat:      2],                         dBonusOneShot,
                       [NSNumber numberWithFloat:      50],                        dBonusSkill,
                       [NSNumber numberWithInteger:    5],                         dDeathScoreRatio,
                       
                       [NSNumber numberWithUnsignedInt:GorillasPlayerModelGorilla],dPlayerModel,
                       [NSNumber numberWithInteger:    0],                         dScore,
                       [NSNumber numberWithInteger:    0],                         dSkill,
                       [NSDictionary dictionary],                                  dTopScoreHistory,
                       [NSNumber numberWithFloat:      0.3f],                      dLevel,
                       levelNames,                                                 dLevelNames,
                       [NSNumber numberWithFloat:      0.03f],                     dLevelProgress,
                       
                       nil]];
    
    updateTriggers  = [[NSArray alloc] initWithObjects:
                       cLargeFontSize,
                       cSmallFontSize,
                       cFontSize,
                       cFontName,
                       cFixedFontName,
                       dCityTheme,
                       dGravity,
                       cSoundFx,
                       cVoice,
                       cVibration,
                       cVisualFx,
                       dReplay,
                       dFollowThrow,
                       cTracks,
                       cTrackNames,
                       cCurrentTrack,
                       dLevel,
                       dLevelNames,
                       nil
                       ];
    [self.resetTriggers setObject:@"gameLayer.skyLayer" forKey:cVisualFx];
    [self.resetTriggers setObject:@"newGameLayer" forKey:dActiveGameConfigurationIndex];
    [self.resetTriggers setObject:@"customGameLayer" forKey:dMode];
    
    /*[self setTopScoreHistory:[NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:random() % 10000] description],
                              nil
                              ]];
     //*/
    
    return self;
}


-(void) dealloc {
    
    [CityTheme forgetThemes];
    
    free(modes);
    modes = nil;
    
    [super dealloc];
}


+(GorillasConfig *) get {
    
    return (GorillasConfig *)[super get];
}


-(NSString *) offMessage {

    return [offMessages objectAtIndex:random() % offMessages.count];
}
-(NSString *) hitMessage {
    
    return [hitMessages objectAtIndex:random() % hitMessages.count];
}


-(float) cityScale {
    
    return [self buildingWidth] / 50;
}
-(float) buildingWidth {
    
    return ([CCDirector sharedDirector].winSize.width / [[self buildingAmount] unsignedIntValue] - 1);
}
-(long) buildingColor {
    
    return [[[self buildingColors] objectAtIndex:random() % [[self buildingColors] count]] longValue];
}


-(float) windowWidth {
    
    return [CCDirector sharedDirector].winSize.width / [self.buildingAmount unsignedIntValue] / ([self.windowAmount unsignedIntValue] * 2 + 1);
}
-(float) windowHeight {
    
    return [self windowWidth] * 2;
}
-(float) windowPadding {
    
    return [self windowWidth];
}


#pragma mark Game Configuration

-(NSString *) modeString {

    NSString *string = [modeStrings objectForKey:self.mode];
    if (string == nil)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Unsupported game mode." userInfo:nil];
    
    return string;
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

-(void) recordScore:(NSInteger)score {
    
    if(score < 0)
        score = 0;
    NSNumber *scoreObject = [NSNumber numberWithInteger:score];
    
    // Is this a new top score for today?
    NSDictionary *topScores = [self topScoreHistory];
    NSString *today = [[self today] description];
    NSNumber *topScoreToday = [topScores objectForKey:today];
    
    if(topScoreToday == nil || [topScoreToday integerValue] < score) {
        // Record top score.
        NSMutableDictionary *newTopScores = [topScores mutableCopy];
        [newTopScores setObject: scoreObject forKey:today];
        [self setTopScoreHistory:newTopScores];
        [newTopScores release];
    }
    
    NSLog(@"new score: %@", scoreObject);
    self.score = scoreObject;
}
-(NSString *) levelName {

    int levelNameCount = [self.levelNames count];
    int levelIndex = (int) ([self.level floatValue] * levelNameCount);
    
    return [[self levelNames] objectAtIndex:levelIndex];
}


-(void) levelUp {
    
    self.level = [NSNumber numberWithFloat:fminf(0.9f, fmaxf(0.1f, [self.level floatValue] + [self.levelProgress floatValue]))];
}
-(void) levelDown {
    
    self.level = [NSNumber numberWithFloat:fminf(0.9f, fmaxf(0.1f, [self.level floatValue] + [self.levelProgress floatValue]))];
}


@end
