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

#define dFontSize           @"v1.0.fontSize"
#define dLargeFontSize      @"v1.1.largeFontSize"
#define dSmallFontSize      @"v1.0.smallFontSize"
#define dFixedFontName      @"v1.0.fixedFontName"
#define dFontName           @"v1.0.fontName"

#define dCityTheme          @"v1.0.cityTheme"
#define dFixedFloors        @"v1.0.fixedFloors"
#define dBuildingMax        @"v1.0.buildingMax"
#define dBuildingAmount     @"v1.0.buildingAmount"
#define dBuildingSpeed      @"v1.0.buildingSpeed"
#define dBuildingColorCount @"v1.0.buildingColorCount"
#define dBuildingColors     @"v1.0.buildingColors"

#define dWindowAmount       @"v1.0.windowAmount"
#define dWindowColorOn      @"v1.0.windowColorOn"
#define dWindowColorOff     @"v1.0.windowColorOff"

#define dSkyColor           @"v1.0.skyColor"
#define dStarColor          @"v1.0.starColor"
#define dStarSpeed          @"v1.3.starSpeed"
#define dStarAmount         @"v1.0.starAmount"

#define dLives              @"v1.1.lives"
#define dWindModifier       @"v1.0.windModifier"
#define dGravity            @"v1.0.gravity"
#define dMinGravity         @"v1.0.minGravity"
#define dMaxGravity         @"v1.0.maxGravity"

#define dShadeColor         @"v1.0.shadeColor"
#define dTransitionDuration @"v1.0.transitionDuration"
#define dGameScrollDuration @"v1.1.gameScrollDuration"

#define dGameConfiguration  @"v1.1.gameConfiguration"
#define dMode               @"v1.1.mode"
#define dMissScore          @"v1.0.missScore"
#define dKillScore          @"v1.0.killScore"
#define dBonusOneShot       @"v1.1.bonusOneShot"
#define dBonusSkill         @"v1.1.bonusSkill"
#define dDeathScoreRatio    @"v1.0.deathScoreRatio"

#define dSoundFx            @"v1.1.soundFx"
#define dVoice              @"v1.3.voice"
#define dVibration          @"v1.1.vibration"
#define dVisualFx           @"v1.1.visualFx"

#define dReplay             @"v1.1.replay"
#define dFollowThrow        @"v1.1.followThrow"

#define dTracks             @"v1.1.tracks"
#define dTrackNames         @"v1.3.trackNames"
#define dCurrentTrack       @"v1.3.currentTrack"

#define dPlayerModel        @"v1.2.playerModel"
#define dScore              @"v1.0.score"
#define dSkill              @"v1.1.skill"
#define dTopScoreHistory    @"v1.0.topScoreHistory"
#define dLevel              @"v1.0.level"
#define dLevelNames         @"v1.0.levelNames"
#define dLevelProgress      @"v1.0.levelProgress"


@implementation GorillasConfig

@synthesize modes;


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
                                [NSNumber numberWithInteger:    150],                       dStarSpeed,
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
                                [NSNumber numberWithInteger:    GorillasModeBootCamp],      dMode,
                                [NSNumber numberWithInteger:    -5],                        dMissScore,
                                [NSNumber numberWithInteger:    50],                        dKillScore,
                                [NSNumber numberWithFloat:      2],                         dBonusOneShot,
                                [NSNumber numberWithFloat:      50],                        dBonusSkill,
                                [NSNumber numberWithInteger:    5],                         dDeathScoreRatio,
                                
                                [NSNumber numberWithUnsignedInt:GorillasPlayerModelGorilla],dPlayerModel,
                                [NSNumber numberWithInteger:    0],                         dScore,
                                [NSNumber numberWithInteger:    0],                         dSkill,
                                [NSMutableDictionary dictionary/*WithObjectsAndKeys:
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*1)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*2)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*3)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*4)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*5)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*6)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*7)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*8)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*9)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*10)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*11)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*12)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*13)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*14)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*15)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*16)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*17)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*18)] description],
                                 [NSNumber numberWithInteger:random() % 200], [[NSDate dateWithTimeIntervalSinceNow:-(3600*24*19)] description],
                                 nil//*/],                                                  dTopScoreHistory,
                                [NSNumber numberWithFloat:      0.4f],                      dLevel,
                                [levelNames retain],                                        dLevelNames,
                                [NSNumber numberWithFloat:      0.03f],                     dLevelProgress,
                                
                                nil]];

    return self;
}


-(void) dealloc {
    
    [[CityTheme getThemes] release];
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


#pragma mark Text

-(int) largeFontSize {
    
    return [defaults integerForKey:dLargeFontSize];
}
-(void) setLargeFontSize: (int)largeFontSize {
    
    [defaults setInteger:largeFontSize forKey: dLargeFontSize];
    [[GorillasAppDelegate get] updateConfig];
}
-(int) smallFontSize {
    
    return [defaults integerForKey: dSmallFontSize];
}
-(void) setSmallFontSize: (int)smallFontSize {
    
    [defaults setInteger:smallFontSize forKey: dSmallFontSize];
    [[GorillasAppDelegate get] updateConfig];
}
-(int) fontSize {
    
    return [defaults integerForKey: dFontSize];
}
-(void) setFontSize: (int)fontSize {

    [defaults setInteger:fontSize forKey: dFontSize];
    [[GorillasAppDelegate get] updateConfig];
}
-(NSString *) fontName {

    return [defaults stringForKey: dFontName];
}
-(void) setFontName: (NSString *)fontName {

    [defaults setObject:fontName forKey: dFontName];
    [[GorillasAppDelegate get] updateConfig];
}
-(NSString *) fixedFontName {
    
    return [defaults stringForKey: dFixedFontName];
}
-(void) setFixedFontName: (NSString *)fixedFontName {
    
    [defaults setObject:fixedFontName forKey: dFixedFontName];
    [[GorillasAppDelegate get] updateConfig];
}
-(NSString *) offMessage {

    return [offMessages objectAtIndex:random() % offMessages.count];
}
-(NSString *) hitMessage {
    
    return [hitMessages objectAtIndex:random() % hitMessages.count];
}


#pragma mark City

-(NSString *) cityTheme {
    
    return [defaults stringForKey: dCityTheme];
}
-(void) setCityTheme: (NSString *)cityTheme {
    
    [defaults setObject:cityTheme forKey: dCityTheme];
    [[GorillasAppDelegate get] updateConfig];
}
-(NSUInteger) fixedFloors {

    return [defaults integerForKey: dFixedFloors];
}
-(void) setFixedFloors: (NSUInteger)fixedFloors {

    [defaults setInteger:fixedFloors forKey: dFixedFloors];
}
-(float) cityScale {
    
    return [self buildingWidth] / 50;
}
-(float) buildingMax {

    return [defaults floatForKey: dBuildingMax];
}
-(void) setBuildingMax: (float)buildingMax {

    [defaults setFloat:buildingMax forKey: dBuildingMax];
}
-(float) buildingWidth {
    
	CGSize size = [[Director sharedDirector] winSize];
    return (size.width / [self buildingAmount] - 1);
}
-(NSUInteger) buildingAmount {

    return [defaults integerForKey: dBuildingAmount];
}
-(void) setBuildingAmount: (NSUInteger)buildingAmount {

    [defaults setInteger:buildingAmount forKey: dBuildingAmount];
}
-(int) buildingSpeed {

    return [defaults integerForKey: dBuildingSpeed];
}
-(void) setBuildingSpeed: (int)buildingSpeed {

    [defaults setInteger:buildingSpeed forKey: dBuildingSpeed];
}
-(long) buildingColor {
    
    return [[[self buildingColors] objectAtIndex:random() % [[self buildingColors] count]] longValue];
}
-(NSArray *) buildingColors {

    return [defaults arrayForKey: dBuildingColors];
}
-(void) setBuildingColors: (NSArray *)buildingColors {

    [defaults setObject:buildingColors forKey: dBuildingColors];
}


-(float) windowWidth {
    
	CGSize size = [[Director sharedDirector] winSize];
    return size.width / [self buildingAmount] / ([self windowAmount] * 2 + 1);
}
-(float) windowHeight {
    
    return [self windowWidth] * 2;
}
-(float) windowPadding {
    
    return [self windowWidth];
}
-(NSUInteger) windowAmount {

    return [defaults integerForKey: dWindowAmount];
}
-(void) setWindowAmount: (NSUInteger)windowAmount {

    [defaults setInteger:windowAmount forKey: dWindowAmount];
}
-(long) windowColorOn {

    return [(NSNumber *)[defaults objectForKey:dWindowColorOn] longValue];
}
-(void) setWindowColorOn: (long)windowColorOn {

    [defaults setObject:[NSNumber numberWithLong:windowColorOn] forKey: dWindowColorOn];
}
-(long) windowColorOff {

    return [(NSNumber *)[defaults objectForKey:dWindowColorOff] longValue];
}
-(void) setWindowColorOff: (long)windowColorOff {

    [defaults setObject:[NSNumber numberWithLong:windowColorOff] forKey: dWindowColorOff];
}


#pragma mark Environment

-(long) skyColor {

    return [(NSNumber *)[defaults objectForKey:dSkyColor] longValue];
}
-(void) setSkyColor: (long)skyColor {
    
    [defaults setObject:[NSNumber numberWithLong:skyColor] forKey: dSkyColor];
}
-(long) starColor {

    return [(NSNumber *)[defaults objectForKey:dStarColor] longValue];
}
-(void) setStarColor: (long)starColor {

    [defaults setObject:[NSNumber numberWithLong:starColor] forKey: dStarColor];
}
-(int) starSpeed {

    return [defaults integerForKey: dStarSpeed];
}
-(void) setStarSpeed: (int)starSpeed {

    [defaults setInteger:starSpeed forKey: dStarSpeed];
}
-(NSUInteger) starAmount {

    return [defaults integerForKey: dStarAmount];
}
-(void) setStarAmount: (NSUInteger)starAmount {

    [defaults setInteger:starAmount forKey: dStarAmount];
}


#pragma mark Gameplay

-(int) lives {
    
    return [defaults integerForKey:dLives];
}
-(void) setLives: (int)_lives {
    
    [defaults setInteger:_lives forKey: dLives];
}
-(float) windModifier {
    
    return [defaults floatForKey: dWindModifier];
}
-(void) setWindModifier:(float)windModifier {
    
    [defaults setFloat:windModifier forKey:dWindModifier];
}
-(NSUInteger) gravity {
    
    return [defaults integerForKey: dGravity];
}
-(void) setGravity: (NSUInteger)gravity {

    if(gravity > [self maxGravity])
        gravity = [self maxGravity];
    if(gravity < [self minGravity])
        gravity = [self minGravity];
    
    [defaults setInteger:gravity forKey: dGravity];
    [[GorillasAppDelegate get] updateConfig];
}
-(NSUInteger) minGravity {
    
    return [defaults integerForKey: dMinGravity];
}
-(void) setMinGravity: (NSUInteger)minGravity {
    
    [defaults setInteger:minGravity forKey: dMinGravity];
}
-(NSUInteger) maxGravity {
    
    return [defaults integerForKey: dMaxGravity];
}
-(void) setMaxGravity: (NSUInteger)maxGravity {
    
    [defaults setInteger:maxGravity forKey: dMaxGravity];
}


#pragma mark User Interface

-(long) shadeColor {

    return [(NSNumber *)[defaults objectForKey:dShadeColor] longValue];
}
-(void) setShadeColor: (long)shadeColor {

    [defaults setObject:[NSNumber numberWithLong:shadeColor] forKey: dShadeColor];
}
-(ccTime) transitionDuration {

    return [defaults floatForKey: dTransitionDuration];
}
-(void) setTransitionDuration: (ccTime)transitionDuration {

    [defaults setFloat:transitionDuration forKey: dTransitionDuration];
}
-(ccTime) gameScrollDuration {
    
    return [defaults floatForKey: dGameScrollDuration];
}
-(void) setGameScrollDuration: (ccTime)gameScrollDuration {
    
    [defaults setFloat:gameScrollDuration forKey: dGameScrollDuration];
}


#pragma mark Global Configuration

-(BOOL) soundFx {
    
    return [defaults boolForKey: dSoundFx];
}
-(void) setSoundFx: (BOOL)nSoundFx {
    
    [defaults setBool:nSoundFx forKey: dSoundFx];
    [[GorillasAppDelegate get] updateConfig];
}
-(BOOL) voice {
    
    return [defaults boolForKey: dVoice];
}
-(void) setVoice: (BOOL)nVoice {
    
    [defaults setBool:nVoice forKey: dVoice];
    [[GorillasAppDelegate get] updateConfig];
}
-(BOOL) vibration {
    
    return [defaults boolForKey: dVibration];
}
-(void) setVibration: (BOOL)nVibration {
    
    [defaults setBool:nVibration forKey: dVibration];
    [[GorillasAppDelegate get] updateConfig];
}
-(BOOL) visualFx {
    
    return [defaults boolForKey: dVisualFx];
}
-(void) setVisualFx: (BOOL)nVisualFx {
    
    [defaults setBool:nVisualFx forKey: dVisualFx];
    [[GorillasAppDelegate get] updateConfig];
    [[[[GorillasAppDelegate get] gameLayer] skiesLayer] reset];
}


-(BOOL) replay {
    
    return [defaults boolForKey: dReplay];
}
-(void) setReplay: (BOOL)nReplay {
    
    [defaults setBool:nReplay forKey: dReplay];
    [[GorillasAppDelegate get] updateConfig];
}
-(BOOL) followThrow {
    
    return [defaults boolForKey: dFollowThrow];
}
-(void) setFollowThrow: (BOOL)nFollowThrow {
    
    [defaults setBool:nFollowThrow forKey: dFollowThrow];
    [[GorillasAppDelegate get] updateConfig];
}


#pragma mark Audio

-(NSArray *) tracks {
    
    return [defaults arrayForKey: dTracks];
}
-(void) setTracks: (NSArray *)tracks {
    
    [defaults setObject:tracks forKey: dTracks];
    [[GorillasAppDelegate get] updateConfig];
}
-(NSArray *) trackNames {
    
    return [defaults arrayForKey: dTrackNames];
}
-(void) setTrackNames: (NSArray *)trackNames {
    
    [defaults setObject:trackNames forKey: dTrackNames];
    [[GorillasAppDelegate get] updateConfig];
}
-(NSString *) randomTrack {
    
    NSArray *tracks = self.tracks;
    return [tracks objectAtIndex:random() % ([tracks count] - 2)];
}
-(NSString *) currentTrack {
    
    return [defaults stringForKey: dCurrentTrack];
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
-(NSUInteger) activeGameConfigurationIndex {
    
    return [defaults integerForKey:dGameConfiguration];
}
-(void) setActiveGameConfigurationIndex:(NSUInteger)_activeGameConfigurationIndex {
    
    [defaults setInteger:_activeGameConfigurationIndex % [gameConfigurations count] forKey:dGameConfiguration];
    [[[GorillasAppDelegate get] newGameLayer] reset];
}
-(GameConfiguration *) gameConfiguration {
    
    return [gameConfigurations objectAtIndex:[self activeGameConfigurationIndex]];
}
-(NSUInteger) mode {
    
    return [defaults integerForKey: dMode];
}
-(void) setMode: (NSUInteger)_mode {
    
    [defaults setInteger:_mode forKey: dMode];
    [[[GorillasAppDelegate get] customGameLayer] reset];
}
-(NSString *) modeString {
    
    switch ([self mode]) {
        case GorillasModeBootCamp:
            return NSLocalizedString(@"config.gametype.bootcamp", @"Boot Camp");
            
        case GorillasModeClassic:
            return NSLocalizedString(@"config.gametype.classic", @"Classic Game");
            
        case GorillasModeDynamic:
            return NSLocalizedString(@"config.gametype.dynamic", @"Dynamic Game");
            
        case GorillasModeTeam:
            return NSLocalizedString(@"config.gametype.team", @"Teamed Game");
            
        case GorillasModeLMS:
            return NSLocalizedString(@"config.gametype.lms", @"Last Man Standing");
            
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Unsupported game mode." userInfo:nil];
    }
}
-(int) missScore {
    
    return [defaults integerForKey: dMissScore];
}
-(void) setMissScore: (int)nMissScore {
    
    [defaults setInteger:nMissScore forKey: dMissScore];
}
-(int) killScore {
    
    return [defaults integerForKey: dKillScore];
}
-(void) setKillScore: (int)nKillScore {
    
    [defaults setInteger:nKillScore forKey: dKillScore];
}
-(float) bonusOneShot {
    
    return [defaults floatForKey: dBonusOneShot];
}
-(void) setBonusOneShot: (float)nBonusOneShot {
    
    [defaults setFloat:nBonusOneShot forKey: dBonusOneShot];
}
-(float) bonusSkill {
    
    return [defaults floatForKey: dBonusSkill];
}
-(void) setBonusSkill: (float)nBonusSkill {
    
    [defaults setFloat:nBonusSkill forKey: dBonusSkill];
}
-(int) deathScoreRatio {
    
    return [defaults integerForKey: dDeathScoreRatio];
}
-(void) setDeathScoreRatio: (int)nDeathScoreRatio {
    
    [defaults setInteger:nDeathScoreRatio forKey: dDeathScoreRatio];
}
-(int) deathScore {
    
    // Some info on Death Score Ratios:
    // Death score balances with kill score when player makes [deathScoreRatio] amount of misses.
    // More misses -> score goes down faster.
    // Less misses -> score goes down slower.
    // As a result, when player A dies equally often as player B but misses less, his score will be higher.
    
    return -([self killScore] + [self deathScoreRatio] * [self missScore]);
}


#pragma mark User Status

-(NSUInteger) playerModel {
    
    return [defaults integerForKey: dPlayerModel];
}
-(void) setPlayerModel: (NSUInteger)nPlayerModel {
    
    [defaults setInteger:nPlayerModel forKey:dPlayerModel];
}
-(int) score {
    
    return [defaults integerForKey: dScore];
}
-(void) setScore: (int)nScore {
    
    if(nScore < 0)
        nScore = 0;    
    
    // Is this a new top score for today?
    NSDictionary *topScores = [self topScoreHistory];
    NSString *today = [[self today] description];
    NSNumber *topScoreToday = [topScores objectForKey:today];
    
    if(topScoreToday == nil || [topScoreToday intValue] < nScore) {
        // Record top score.
        NSMutableDictionary *newTopScores = [topScores mutableCopy];
        [newTopScores setObject:[NSNumber numberWithInt:nScore] forKey:today];
        [self setTopScoreHistory:newTopScores];
        [newTopScores release];
    }
    
    [defaults setInteger:nScore forKey: dScore];
}
-(float) skill {
    
    return [defaults floatForKey: dSkill];
}
-(void) setSkill: (float)nSkill {
    
    [defaults setFloat:nSkill forKey: dSkill];
}
-(NSDictionary *) topScoreHistory {
    
    return [defaults dictionaryForKey: dTopScoreHistory];
}
-(void) setTopScoreHistory: (NSDictionary *)nTopScoreHistory {
    
    [defaults setObject:nTopScoreHistory forKey: dTopScoreHistory];
}
-(float) level {

    return [defaults floatForKey: dLevel];
}
-(void) setLevel: (float)level {

    if(level < 0.1f)
        level = 0.1f;
    if(level > 0.9f)
        level = 0.9f;
    
    [defaults setFloat:level forKey: dLevel];
    [[GorillasAppDelegate get] updateConfig];
}
-(NSString *) levelName {

    int levelNameCount = [[self levelNames] count];
    int levelIndex = (int) ([self level] * levelNameCount);
    
    return [[self levelNames] objectAtIndex:levelIndex];
}
-(NSArray *) levelNames {

    return [defaults arrayForKey: dLevelNames];
}
-(void) setLevelNames: (NSArray *)levelNames {

    [defaults setObject:levelNames forKey: dLevelNames];
    [[GorillasAppDelegate get] updateConfig];
}
-(float) levelProgress {
    
    return [defaults floatForKey: dLevelProgress];
}
-(void) setLevelProgress: (float)levelProgress {
    
    [defaults setFloat:levelProgress forKey: dLevelProgress];
}


-(void) levelUp {
    
    [self setLevel:[self level] + [self levelProgress]];
}
-(void) levelDown {
    
    [self setLevel:[self level] - [self levelProgress]];
}


@end
