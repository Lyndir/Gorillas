//
//  GorillasConfig.m
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "GorillasConfig.h"
#import "CityTheme.h"
#import "cocos2d.h"

#define dCityTheme          @"cityTheme"

#define dFontSize           @"fontSize"
#define dFontName           @"fontName"

#define dFixedFloors        @"fixedFloors"
#define dBuildingMax        @"buildingMax"
#define dBuildingAmount     @"buildingAmount"
#define dBuildingSpeed      @"buildingSpeed"
#define dBuildingColorCount @"buildingColorCount"
#define dBuildingColors     @"buildingColors"

#define dWindowAmount       @"windowAmount"
#define dWindowColorOn      @"windowColorOn"
#define dWindowColorOff     @"windowColorOff"

#define dSkyColor           @"skyColor"
#define dStarColor          @"starColor"
#define dStarSpeed          @"starSpeed"
#define dStarAmount         @"starAmount"

#define dGravity            @"gravity"
#define dShadeColor         @"shadeColor"
#define dTransitionDuration @"transitionDuration"

#define dLevel              @"level"
#define dLevelNameCount     @"levelNameCount"
#define dLevelNames         @"levelNames"

#define dScore              @"score"
#define dMissScore          @"missScore"
#define dKillScore          @"killScore"
#define dDeathScore         @"deathScore"


@implementation GorillasConfig


-(id) init {

    if(!(self = [super init]))
        return self;

    defaults = [[NSUserDefaults standardUserDefaults] retain];

    NSArray *levelNames     = [NSArray arrayWithObjects:
                               @"Toddler",
                               @"Playground",
                               @"Training",
                               @"Graduate",
                               @"Tough",
                               @"Sniper",
                               @"Are You Kidding?",
                               @"Impossible",
                               nil];

    NSDictionary *themes = [CityTheme getThemes];
    NSString *defaultThemeName = [CityTheme defaultThemeName];
    CityTheme *theme = [themes objectForKey:defaultThemeName];
    
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                [CityTheme defaultThemeName],                               dCityTheme,
                                [NSNumber numberWithInteger:    30],                        dFontSize,
                                @"Georgia",                                   dFontName,
     
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
                                
                                [NSNumber numberWithInteger:    [theme gravity]],           dGravity,
                                [NSNumber numberWithLong:       0x000000cc],                dShadeColor,
                                [NSNumber numberWithFloat:      0.5f],                      dTransitionDuration,
     
                                [NSNumber numberWithFloat:      0.1f],                      dLevel,
                                [NSNumber numberWithInteger:    8],                         dLevelNameCount,
                                [levelNames retain],                                        dLevelNames,
                                
                                [NSNumber numberWithInteger:    0],                         dScore,
                                [NSNumber numberWithInteger:    -5],                        dMissScore,
                                [NSNumber numberWithInteger:    50],                        dKillScore,
                                [NSNumber numberWithInteger:    -20],                       dDeathScore,
                                
                                nil]];

    return self;
}


-(NSString *) cityTheme {
    
    return [defaults stringForKey: dCityTheme];
}
-(void) setCityTheme: (NSString *)cityTheme {
    
    [defaults setObject:cityTheme forKey: dCityTheme];
}
-(int) fontSize {
    
    return [defaults integerForKey: dFontSize];
}
-(void) setFontSize: (int)fontSize {

    [defaults setInteger:fontSize forKey: dFontSize];
}
-(NSString *) fontName {

    return [defaults stringForKey: dFontName];
}
-(void) setFontName: (NSString *)fontName {

    [defaults setObject:fontName forKey: dFontName];
}


-(int) fixedFloors {

    return [defaults integerForKey: dFixedFloors];
}
-(void) setFixedFloors: (int)fixedFloors {

    [defaults setInteger:fixedFloors forKey: dFixedFloors];
}
-(float) buildingMax {

    return [defaults floatForKey: dBuildingMax];
}
-(void) setBuildingMax: (float)buildingMax {

    [defaults setFloat:buildingMax forKey: dBuildingMax];
}
-(float) buildingWidth {
    
	CGRect size = [[Director sharedDirector] winSize];
    return (size.size.width / [self buildingAmount] - 1);
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
    
	CGRect size = [[Director sharedDirector] winSize];
    return size.size.width / [self buildingAmount] / ([self windowAmount] * 2 + 1);
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
-(int) starAmount {

    return [defaults integerForKey: dStarAmount];
}
-(void) setStarAmount: (int)starAmount {

    [defaults setInteger:starAmount forKey: dStarAmount];
}


-(int) gravity {

    return [defaults integerForKey: dGravity];
}
-(void) setGravity: (int)gravity {

    [defaults setInteger:gravity forKey: dGravity];
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


-(float) level {

    return [defaults floatForKey: dLevel];
}
-(void) setLevel: (float)level {

    if(level < 0.0f)
        level = 0.0f;
    if(level > 1.0f)
        level = 1.0f;
    
    [defaults setFloat:level forKey: dLevel];
}
-(NSString *) levelName {

    int levelNameCount = [[self levelNames] count];
    int levelIndex = (int) ([self level] * levelNameCount);
    if(levelIndex == levelNameCount)
        levelIndex = levelNameCount - 1;
    
    return [[self levelNames] objectAtIndex:levelIndex];
}
-(NSArray *) levelNames {

    return [defaults arrayForKey: dLevelNames];
}
-(void) setLevelNames: (NSArray *)levelNames {

    [defaults setObject:levelNames forKey: dLevelNames];
}
-(int) levelNameCount {

    return [defaults integerForKey: dLevelNameCount];
}
-(void) setLevelNameCount: (int)levelNameCount {

    [defaults setInteger:levelNameCount forKey: dLevelNameCount];
}


-(int) score {
    
    return [defaults integerForKey: dScore];
}
-(void) setScore: (int)nScore {
    
    if(nScore < 0)
        nScore = 0;
    
    [defaults setInteger:nScore forKey: dScore];
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
-(int) deathScore {
    
    return [defaults integerForKey: dDeathScore];
}
-(void) setDeathScore: (int)nDeathScore {
    
    [defaults setInteger:nDeathScore forKey: dDeathScore];
}


-(void) levelUp {
    
    [self setLevel:[self level] + 0.1f];
}
-(void) levelDown {
    
    [self setLevel:[self level] - 0.1f];
}


-(void) dealloc {
    
    [super dealloc];
    
    [defaults release];
}


+(GorillasConfig *) get {
    
    static GorillasConfig *instance;
    if(!instance)
        instance = [[GorillasConfig alloc] init];
    
    return instance;
}


@end
