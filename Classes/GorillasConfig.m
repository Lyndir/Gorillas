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
//  GorillasConfig.m
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "GorillasConfig.h"
#import "CityTheme.h"
#import "cocos2d.h"
#import "GorillasAppDelegate.h"

#define dCityTheme          @"v1.cityTheme"

#define dFontSize           @"v1.fontSize"
#define dLargeFontSize      @"v1.largeFontSize"
#define dSmallFontSize      @"v1.smallFontSize"
#define dFixedFontName      @"v1.fixedFontName"
#define dFontName           @"v1.fontName"

#define dFixedFloors        @"v1.fixedFloors"
#define dBuildingMax        @"v1.buildingMax"
#define dBuildingAmount     @"v1.buildingAmount"
#define dBuildingSpeed      @"v1.buildingSpeed"
#define dBuildingColorCount @"v1.buildingColorCount"
#define dBuildingColors     @"v1.buildingColors"

#define dWindowAmount       @"v1.windowAmount"
#define dWindowColorOn      @"v1.windowColorOn"
#define dWindowColorOff     @"v1.windowColorOff"

#define dSkyColor           @"v1.skyColor"
#define dStarColor          @"v1.starColor"
#define dStarSpeed          @"v1.starSpeed"
#define dStarAmount         @"v1.starAmount"

#define dWindModifier       @"v1.windModifier"
#define dGravity            @"v1.gravity"
#define dMinGravity         @"v1.minGravity"
#define dMaxGravity         @"v1.maxGravity"
#define dShadeColor         @"v1.shadeColor"
#define dTransitionDuration @"v1.transitionDuration"
#define dGameScrollDuration @"v1.gameScrollDuration"

#define dLevel              @"v1.level"
#define dLevelNameCount     @"v1.levelNameCount"
#define dLevelNames         @"v1.levelNames"
#define dLevelProgress      @"v1.levelProgress"

#define dScore              @"v1.score"
#define dTopScoreHistory    @"v1.topScoreHistory"
#define dMissScore          @"v1.missScore"
#define dKillScore          @"v1.killScore"
#define dBonusOneShot       @"v1.bonusOneShot"
#define dBonusSkill         @"v1.bonusSkill"
#define dDeathScoreRatio    @"v1.deathScoreRatio"

#define dTracks             @"v1.tracks"
#define dCurrentTrack       @"v1.currentTrack"

#define dWeather            @"v1.weather"
#define dSoundFx            @"v1.soundFx"
#define dVibration          @"v1.vibration"
#define dVisualFx           @"v1.visualFx"

#define dFollowThrow        @"v1.followThrow"
#define dMultiplayerFlip    @"v1.multiplayerFlip"

#define dTraining           @"v1.training"
#define dThrowHint          @"v1.throwHint"
#define dThrowHistory       @"v1.throwHistory"


@implementation GorillasConfig


-(id) init {

    if(!(self = [super init]))
        return self;

    defaults = [[NSUserDefaults standardUserDefaults] retain];

    NSArray *levelNames     = [NSArray arrayWithObjects:
                               @"Junior",
                               @"Trainee",
                               @"Adept",
                               @"Skilled",
                               @"Masterful",
                               @"Sniper",
                               @"Deadly",
                               @"Impossible",
                               nil];

    NSDictionary *themes = [CityTheme getThemes];
    NSString *defaultThemeName = [CityTheme defaultThemeName];
    CityTheme *theme = [themes objectForKey:defaultThemeName];
    
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                [CityTheme defaultThemeName],                               dCityTheme,
                                [NSNumber numberWithInteger:    34],                        dFontSize,
                                [NSNumber numberWithInteger:    48],                        dLargeFontSize,
                                [NSNumber numberWithInteger:    18],                        dSmallFontSize,
                                @"Marker Felt",                                             dFontName,
                                @"American Typewriter",                                     dFixedFontName,
     
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
                                [NSNumber numberWithInteger:    30],                        dStarSpeed,
                                [NSNumber numberWithInteger:    [theme starAmount]],        dStarAmount,
                                
                                [NSNumber numberWithFloat:      [theme windModifier]],      dWindModifier,
                                [NSNumber numberWithInteger:    [theme gravity]],           dGravity,
                                [NSNumber numberWithInteger:    30],                        dMinGravity,
                                [NSNumber numberWithInteger:    150],                       dMaxGravity,
                                [NSNumber numberWithLong:       0x000000dd],                dShadeColor,
                                [NSNumber numberWithFloat:      0.5f],                      dTransitionDuration,
                                [NSNumber numberWithFloat:      0.5f],                      dGameScrollDuration,
     
                                [NSNumber numberWithFloat:      0.1f],                      dLevel,
                                [NSNumber numberWithInteger:    8],                         dLevelNameCount,
                                [levelNames retain],                                        dLevelNames,
                                [NSNumber numberWithFloat:      0.03f],                     dLevelProgress,
                                
                                [NSNumber numberWithInteger:    0],                         dScore,
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
                                 nil//*/
                                ],                           dTopScoreHistory,
                                [NSNumber numberWithInteger:    -5],                        dMissScore,
                                [NSNumber numberWithInteger:    50],                        dKillScore,
                                [NSNumber numberWithInteger:    100],                       dBonusOneShot,
                                [NSNumber numberWithInteger:    100],                       dBonusSkill,
                                [NSNumber numberWithInteger:    5],                         dDeathScoreRatio,
                                
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"Sky High",               @"blockdropper3.wav",
                                 @"Veritech",               @"veritech.wav",
                                 @"Fighting Gorillas",      @"fighting_gorillas.wav",
                                 @"Pride of the Pacific",   @"prideofthepacific.wav",
                                 @"Fork Bomb",              @"forkbomb.wav",
                                 @"Off",                    @"",
                                 nil],                                                      dTracks,
                                @"blockdropper3.wav",                                       dCurrentTrack,
                                
                                [NSNumber numberWithBool:    YES],                          dWeather,
                                [NSNumber numberWithBool:    YES],                          dSoundFx,
                                [NSNumber numberWithBool:    YES],                          dVibration,
                                [NSNumber numberWithBool:    YES],                          dVisualFx,
                                
                                [NSNumber numberWithBool:    YES],                          dFollowThrow,
                                [NSNumber numberWithBool:    NO],                           dMultiplayerFlip,
                                
                                [NSNumber numberWithBool:    NO],                           dTraining,
                                [NSNumber numberWithBool:    NO],                           dThrowHint,
                                [NSNumber numberWithBool:    YES],                          dThrowHistory,
                                
                                nil]];

    return self;
}


+(GorillasConfig *) get {
    
    static GorillasConfig *instance;
    if(!instance)
        instance = [[GorillasConfig alloc] init];
    
    return instance;
}


-(NSString *) cityTheme {
    
    return [defaults stringForKey: dCityTheme];
}
-(void) setCityTheme: (NSString *)cityTheme {
    
    [defaults setObject:cityTheme forKey: dCityTheme];
    [[GorillasAppDelegate get] updateConfig];
}
-(int) largeFontSize {
    
    return [defaults integerForKey: dLargeFontSize];
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


-(int) fixedFloors {

    return [defaults integerForKey: dFixedFloors];
}
-(void) setFixedFloors: (int)fixedFloors {

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
-(int) buildingAmount {

    return [defaults integerForKey: dBuildingAmount];
}
-(void) setBuildingAmount: (int)buildingAmount {

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
-(int) windowAmount {

    return [defaults integerForKey: dWindowAmount];
}
-(void) setWindowAmount: (int)windowAmount {

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


-(float) windModifier {
    
    return [defaults floatForKey: dWindModifier];
}
-(void) setWindModifier:(float)windModifier {
    
    [defaults setFloat:windModifier forKey:dWindModifier];
}
-(int) gravity {
    
    return [defaults integerForKey: dGravity];
}
-(void) setGravity: (int)gravity {

    if(gravity > [self maxGravity])
        gravity = [self maxGravity];
    if(gravity < [self minGravity])
        gravity = [self minGravity];
    
    [defaults setInteger:gravity forKey: dGravity];
    [[GorillasAppDelegate get] updateConfig];
}
-(int) minGravity {
    
    return [defaults integerForKey: dMinGravity];
}
-(void) setMinGravity: (int)minGravity {
    
    [defaults setInteger:minGravity forKey: dMinGravity];
}
-(int) maxGravity {
    
    return [defaults integerForKey: dMaxGravity];
}
-(void) setMaxGravity: (int)maxGravity {
    
    [defaults setInteger:maxGravity forKey: dMaxGravity];
}
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
-(int) levelNameCount {

    return [defaults integerForKey: dLevelNameCount];
}
-(void) setLevelNameCount: (int)levelNameCount {

    [defaults setInteger:levelNameCount forKey: dLevelNameCount];
}
-(float) levelProgress {
    
    return [defaults floatForKey: dLevelProgress];
}
-(void) setLevelProgress: (float)levelProgress {
    
    [defaults setFloat:levelProgress forKey: dLevelProgress];
}


-(NSDate *) today {
    
    long now = (long) [[NSDate date] timeIntervalSince1970];
    return [NSDate dateWithTimeIntervalSince1970:(now / (3600 * 24)) * (3600 * 24)];
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
-(NSDictionary *) topScoreHistory {
    
    return [defaults dictionaryForKey: dTopScoreHistory];
}
-(void) setTopScoreHistory: (NSDictionary *)nTopScoreHistory {
    
    [defaults setObject:nTopScoreHistory forKey: dTopScoreHistory];
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
-(int) bonusOneShot {
    
    return [defaults integerForKey: dBonusOneShot];
}
-(void) setBonusOneShot: (int)nBonusOneShot {
    
    [defaults setInteger:nBonusOneShot forKey: dBonusOneShot];
}
-(int) bonusSkill {
    
    return [defaults integerForKey: dBonusSkill];
}
-(void) setBonusSkill: (int)nBonusSkill {
    
    [defaults setInteger:nBonusSkill forKey: dBonusSkill];
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
    
    return -1 * ([self killScore] + [self deathScoreRatio] * [self missScore]);
}


-(NSDictionary *) tracks {
    
    return [defaults dictionaryForKey: dTracks];
}
-(void) setTracks: (NSDictionary *)tracks {
    
    [defaults setObject:tracks forKey: dTracks];
    [[GorillasAppDelegate get] updateConfig];
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
    
    return [[self tracks] objectForKey:currentTrack];
}


-(BOOL) weather {
    
    return [defaults boolForKey: dWeather];
}
-(void) setWeather: (BOOL)nWeather {
    
    [defaults setBool:nWeather forKey: dWeather];
    [[GorillasAppDelegate get] updateConfig];
}
-(BOOL) soundFx {
    
    return [defaults boolForKey: dSoundFx];
}
-(void) setSoundFx: (BOOL)nSoundFx {
    
    [defaults setBool:nSoundFx forKey: dSoundFx];
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


-(BOOL) followThrow {
    
    return [defaults boolForKey: dFollowThrow];
}
-(void) setFollowThrow: (BOOL)nFollowThrow {
    
    [defaults setBool:nFollowThrow forKey: dFollowThrow];
    [[GorillasAppDelegate get] updateConfig];
}
-(BOOL) multiplayerFlip {
    
    return [defaults boolForKey: dMultiplayerFlip];
}
-(void) setMultiplayerFlip: (BOOL)nMultiplayerFlip {
    
    [defaults setBool:nMultiplayerFlip forKey: dMultiplayerFlip];
    [[GorillasAppDelegate get] updateConfig];
}

-(BOOL) training {
    
    return [defaults boolForKey: dTraining];
}
-(void) setTraining: (BOOL)nTraining {
    
    [defaults setBool:nTraining forKey: dTraining];
    [[GorillasAppDelegate get] updateConfig];
}
-(BOOL) throwHint {
    
    return [defaults boolForKey: dThrowHint];
}
-(void) setThrowHint: (BOOL)nThrowHint {
    
    [defaults setBool:nThrowHint forKey: dThrowHint];
    [[GorillasAppDelegate get] updateConfig];
}
-(BOOL) throwHistory {
    
    return [defaults boolForKey: dThrowHistory];
}
-(void) setThrowHistory: (BOOL)nThrowHistory {
    
    [defaults setBool:nThrowHistory forKey: dThrowHistory];
    [[GorillasAppDelegate get] updateConfig];
}


-(void) levelUp {
    
    [self setLevel:[self level] + [self levelProgress]];
}
-(void) levelDown {
    
    [self setLevel:[self level] - [self levelProgress]];
}


-(void) dealloc {
    
    [[CityTheme getThemes] release];
    [defaults release];
    defaults = nil;
    
    [super dealloc];
}


@end
