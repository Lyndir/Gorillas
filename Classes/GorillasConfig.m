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

#define dFontSize           NSStringFromSelector(@selector(fontSize))
#define dLargeFontSize      NSStringFromSelector(@selector(largeFontSize))
#define dSmallFontSize      NSStringFromSelector(@selector(smallFontSize))
#define dFixedFontName      NSStringFromSelector(@selector(fixedFontName))
#define dFontName           NSStringFromSelector(@selector(fontName))

#define dCityTheme          NSStringFromSelector(@selector(cityTheme))
#define dFixedFloors        NSStringFromSelector(@selector(fixedFloors))
#define dBuildingMax        NSStringFromSelector(@selector(buildingMax))
#define dBuildingAmount     NSStringFromSelector(@selector(buildingAmount))
#define dBuildingSpeed      NSStringFromSelector(@selector(buildingSpeed))
#define dBuildingColorCount NSStringFromSelector(@selector(buildingColorCount))
#define dBuildingColors     NSStringFromSelector(@selector(buildingColors))

#define dWindowAmount       NSStringFromSelector(@selector(windowAmount))
#define dWindowColorOn      NSStringFromSelector(@selector(windowColorOn))
#define dWindowColorOff     NSStringFromSelector(@selector(windowColorOff))

#define dSkyColor           NSStringFromSelector(@selector(skyColor))
#define dStarColor          NSStringFromSelector(@selector(starColor))
#define dStarSpeed          NSStringFromSelector(@selector(starSpeed))
#define dStarAmount         NSStringFromSelector(@selector(starAmount))

#define dLives              NSStringFromSelector(@selector(lives))
#define dWindModifier       NSStringFromSelector(@selector(windModifier))
#define dGravity            NSStringFromSelector(@selector(gravity))
#define dMinGravity         NSStringFromSelector(@selector(minGravity))
#define dMaxGravity         NSStringFromSelector(@selector(maxGravity))

#define dShadeColor         NSStringFromSelector(@selector(shadeColor))
#define dTransitionDuration NSStringFromSelector(@selector(transitionDuration))
#define dGameScrollDuration NSStringFromSelector(@selector(gameScrollDuration))

#define dGameConfiguration  NSStringFromSelector(@selector(gameConfiguration))
#define dMode               NSStringFromSelector(@selector(mode))
#define dMissScore          NSStringFromSelector(@selector(missScore))
#define dKillScore          NSStringFromSelector(@selector(killScore))
#define dBonusOneShot       NSStringFromSelector(@selector(bonusOneShot))
#define dBonusSkill         NSStringFromSelector(@selector(bonusSkill))
#define dDeathScoreRatio    NSStringFromSelector(@selector(deathScoreRatio))

#define dSoundFx            NSStringFromSelector(@selector(soundFx))
#define dVoice              NSStringFromSelector(@selector(voice))
#define dVibration          NSStringFromSelector(@selector(vibration))
#define dVisualFx           NSStringFromSelector(@selector(visualFx))

#define dReplay             NSStringFromSelector(@selector(replay))
#define dFollowThrow        NSStringFromSelector(@selector(followThrow))

#define dTracks             NSStringFromSelector(@selector(tracks))
#define dTrackNames         NSStringFromSelector(@selector(trackNames))
#define dCurrentTrack       NSStringFromSelector(@selector(currentTrack))

#define dPlayerModel        NSStringFromSelector(@selector(playerModel))
#define dScore              NSStringFromSelector(@selector(score))
#define dSkill              NSStringFromSelector(@selector(skill))
#define dTopScoreHistory    NSStringFromSelector(@selector(topScoreHistory))
#define dLevel              NSStringFromSelector(@selector(level))
#define dLevelNames         NSStringFromSelector(@selector(levelNames))
#define dLevelProgress      NSStringFromSelector(@selector(levelProgress))


@implementation GorillasConfig

@synthesize modes, modeStrings, gameConfigurations;

@dynamic fontSize, largeFontSize, smallFontSize, fontName, fixedFontName;
@dynamic cityTheme;
@dynamic fixedFloors, buildingMax, buildingAmount, buildingSpeed, buildingColors;
@dynamic windowAmount, windowColorOn, windowColorOff;
@dynamic skyColor, starColor, starSpeed, starAmount;
@dynamic lives, windModifier, gravity, minGravity, maxGravity;
@dynamic shadeColor, transitionDuration, gameScrollDuration;
@dynamic level, levelNames, levelProgress;
@dynamic activeGameConfigurationIndex, mode, playerModel, score, skill, topScoreHistory, missScore, killScore, bonusOneShot, bonusSkill, deathScoreRatio;
@dynamic tracks, trackNames, currentTrack;
@dynamic soundFx, voice, vibration, visualFx;
@dynamic replay, followThrow;

#pragma mark Internal

-(id) init {

    if(!(self = [super init]))
        return self;

    defaults = [[NSUserDefaults standardUserDefaults] retain];

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
    
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                [CityTheme defaultThemeName],                               dCityTheme,
                                [NSNumber numberWithInteger:
                                 [NSLocalizedString(@"font.size.normal", @"34") intValue]], dFontSize,
                                [NSNumber numberWithInteger:
                                 [NSLocalizedString(@"font.size.large", @"48") intValue]],  dLargeFontSize,
                                [NSNumber numberWithInteger:
                                 [NSLocalizedString(@"font.size.small", @"18") intValue]],  dSmallFontSize,
                                NSLocalizedString(@"font.family.default",
                                                  @"Marker Felt"),                          dFontName,
                                NSLocalizedString(@"font.family.fixed",
                                                  @"American Typewriter"),                  dFixedFontName,
     
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
                                
                                [NSNumber numberWithLong:       0x332222cc],                dShadeColor,
                                [NSNumber numberWithFloat:      0.5f],                      dTransitionDuration,
                                [NSNumber numberWithFloat:      0.5f],                      dGameScrollDuration,
                                
                                [NSNumber numberWithBool:       YES],                       dSoundFx,
                                [NSNumber numberWithBool:       NO],                        dVoice,
                                [NSNumber numberWithBool:       YES],                       dVibration,
                                [NSNumber numberWithBool:       YES],                       dVisualFx,
                                
                                [NSNumber numberWithBool:       YES],                       dReplay,
                                [NSNumber numberWithBool:       YES],                       dFollowThrow,
                                
                                [NSArray arrayWithObjects:
                                 @"Fighting_Gorillas.mp3",
                                 @"Flow_Square.mp3",
                                 @"Happy_Fun_Ball.mp3",
                                 @"Man_Or_Machine_Gorillas.mp3",
                                 @"RC_Car.mp3",
                                 @"random",
                                 @"",
                                 nil],                                                      dTracks,
                                [NSArray arrayWithObjects:
                                 NSLocalizedString(@"config.song.fighting_gorillas", @"Fighting Gorillas"),
                                 NSLocalizedString(@"config.song.flow_square", @"Flow Square"),
                                 NSLocalizedString(@"config.song.happy_fun_ball", @"Happy Fun Ball"),
                                 NSLocalizedString(@"config.song.man_or_machine", @"Man Or Machine"),
                                 NSLocalizedString(@"config.song.rc_car", @"RC Car"),
                                 NSLocalizedString(@"config.song.random", @"Shuffle"),
                                 NSLocalizedString(@"config.song.off", @"Off"),
                                 nil],                                                      dTrackNames,
                                @"random",                                                  dCurrentTrack,
                                
                                [NSNumber numberWithInteger:    1],                         dGameConfiguration,
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
                       dLargeFontSize,
                       dSmallFontSize,
                       dFontSize,
                       dFontName,
                       dFixedFontName,
                       dCityTheme,
                       dGravity,
                       dSoundFx,
                       dVoice,
                       dVibration,
                       dVisualFx,
                       dReplay,
                       dFollowThrow,
                       dTracks,
                       dTrackNames,
                       dCurrentTrack,
                       dLevel,
                       dLevelNames,
                       nil
                       ];
    resetTriggers   = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @"gameLayer.skyLayer", dVisualFx,
                       @"newGameLayer", dGameConfiguration,
                       @"customGameLayer", dMode,
                       nil
                       ];
    
    return self;
}


-(void) dealloc {
    
    [CityTheme forgetThemes];
    [defaults release];
    defaults = nil;
    
    free(modes);
    modes = nil;
    
    [super dealloc];
}


+(GorillasConfig *) get {
    
    static GorillasConfig *instance;
    if(!instance)
        instance = [[GorillasConfig alloc] init];
    
    return instance;
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    if ([NSStringFromSelector(aSelector) hasPrefix:@"set"])
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    
    return [NSMethodSignature signatureWithObjCTypes:"@@:@"];
}


- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    NSString *selector = NSStringFromSelector(anInvocation.selector);
    if ([selector hasPrefix:@"set"]) {
        NSRange firstChar, rest;
        firstChar.location  = 3;
        firstChar.length    = 1;
        rest.location       = 4;
        rest.length         = selector.length - 5;
        
        selector = [NSString stringWithFormat:@"%@%@",
                    [[selector substringWithRange:firstChar] lowercaseString],
                    [selector substringWithRange:rest]];
        
        id value;
        [anInvocation getArgument:&value atIndex:2];
        
        [defaults setObject:value forKey:selector];
        
        if ([updateTriggers containsObject:selector])
            [[GorillasAppDelegate get] updateConfig];
        NSString *resetTriggerKey = [resetTriggers objectForKey:selector];
        if (resetTriggerKey)
            [[[GorillasAppDelegate get] valueForKey:resetTriggerKey] reset];
    }
    
    else {
        id value = [defaults objectForKey:selector];
        [anInvocation setReturnValue:&value];
    }
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
    
    return ([Director sharedDirector].winSize.width / [[self buildingAmount] unsignedIntValue] - 1);
}
-(long) buildingColor {
    
    return [[[self buildingColors] objectAtIndex:random() % [[self buildingColors] count]] longValue];
}


-(float) windowWidth {
    
    return [Director sharedDirector].winSize.width / [self.buildingAmount unsignedIntValue] / ([self.windowAmount unsignedIntValue] * 2 + 1);
}
-(float) windowHeight {
    
    return [self windowWidth] * 2;
}
-(float) windowPadding {
    
    return [self windowWidth];
}


#pragma mark Audio

-(NSString *) randomTrack {
    
    NSArray *tracks = self.tracks;
    return [tracks objectAtIndex:random() % ([tracks count] - 2)];
}
-(void) setCurrentTrack: (NSString *)currentTrack {
    
    if(currentTrack == nil)
        currentTrack = @"";
    
    [defaults setObject:currentTrack forKey: dCurrentTrack];
    [[GorillasAppDelegate get] updateConfig];
}
-(NSString *) currentTrackName {
    
    id currentTrack = [self currentTrack];
    if(!currentTrack)
        currentTrack = @"";
    
    NSUInteger currentTrackIndex = [[self tracks] indexOfObject:currentTrack];
    return [[self trackNames] objectAtIndex:currentTrackIndex];
}


#pragma mark Game Configuration

-(NSDate *) today {
    
    long now = (long) [[NSDate date] timeIntervalSince1970];
    return [NSDate dateWithTimeIntervalSince1970:(now / (3600 * 24)) * (3600 * 24)];
}
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
    
    self.score = scoreObject;
}
-(NSString *) levelName {

    int levelNameCount = [self.levelNames count];
    int levelIndex = (int) ([self.level floatValue] * levelNameCount);
    
    return [[self levelNames] objectAtIndex:levelIndex];
}


-(void) levelUp {
    
    self.level = [NSNumber numberWithFloat:fminf(1.0f, fmaxf(0.0f, [self.level floatValue] + [self.levelProgress floatValue]))];
}
-(void) levelDown {
    
    self.level = [NSNumber numberWithFloat:fminf(1.0f, fmaxf(0.0f, [self.level floatValue] + [self.levelProgress floatValue]))];
}


@end
