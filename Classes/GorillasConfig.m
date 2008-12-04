//
//  GorillasConfig.m
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "GorillasConfig.h"
#import "cocos2d.h"

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

#define dStarColor          @"starColor"
#define dStarSpeed          @"starSpeed"
#define dStarAmount         @"starAmount"

#define dGravity            @"gravity"
#define dShadeColor         @"shadeColor"
#define dTransitionDuration @"transitionDuration"

#define dLevel              @"level"
#define dLevelNameCount     @"levelNameCount"
#define dLevelNames         @"levelNames"


@implementation GorillasConfig

@dynamic fontSize, fontName;
@dynamic fixedFloors, buildingMax, buildingAmount, buildingSpeed, buildingColors;
@dynamic windowAmount, windowColorOn, windowColorOff;
@dynamic starColor, starSpeed, starAmount;
@dynamic gravity, shadeColor, transitionDuration;
@dynamic level, levelNames, levelNameCount;


-(id) init {

    if(!(self = [super init]))
        return self;

    defaults = [[NSUserDefaults standardUserDefaults] retain];
    
    NSArray *buildingColors = [NSArray arrayWithObjects:
                               [NSNumber numberWithLong:0xb70000ff],
                               [NSNumber numberWithLong:0x00b7b7ff],
                               [NSNumber numberWithLong:0xb7b7b7ff],
                               nil];
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

    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithInteger:    30],           dFontSize,
     @"Arial Rounded MT Bold",                      dFontName,
     
     [NSNumber numberWithInteger:    4],            dFixedFloors,
     [NSNumber numberWithFloat:      0.7f],         dBuildingMax,
     [NSNumber numberWithInteger:    10],           dBuildingAmount,
     [NSNumber numberWithInteger:    1],            dBuildingSpeed,
     [NSNumber numberWithInteger:    3],            dBuildingColorCount,
     [buildingColors retain],                       dBuildingColors,
     
     [NSNumber numberWithInteger:    6],            dWindowAmount,
     [NSNumber numberWithLong:       0xffffb7ff],   dWindowColorOn,
     [NSNumber numberWithLong:       0x676767ff],   dWindowColorOff,
     
     [NSNumber numberWithLong:       0xb7b700ff],   dStarColor,
     [NSNumber numberWithInteger:    30],           dStarSpeed,
     [NSNumber numberWithInteger:    100],          dStarAmount,
     
     [NSNumber numberWithInteger:    100],          dGravity,
     [NSNumber numberWithLong:       0x000000cc],   dShadeColor,
     [NSNumber numberWithFloat:      0.5f],         dTransitionDuration,
     
     [NSNumber numberWithFloat:      0.1f],         dLevel,
     [NSNumber numberWithInteger:    8],            dLevelNameCount,
     [levelNames retain],                           dLevelNames,
     nil]];

    return self;
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

    return [[NSUserDefaults standardUserDefaults] arrayForKey: dBuildingColors];
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

    return [defaults integerForKey: dWindowColorOn];
}
-(void) setWindowColorOn: (long)windowColorOn {

    [defaults setInteger:windowColorOn forKey: dWindowColorOn];
}
-(long) windowColorOff {

    return [defaults integerForKey: dWindowColorOff];
}
-(void) setWindowColorOff: (long)windowColorOff {

    [defaults setInteger:windowColorOff forKey: dWindowColorOff];
}


-(long) starColor {

    return [defaults integerForKey: dStarColor];
}
-(void) setStarColor: (long)starColor {

    [defaults setInteger:starColor forKey: dStarColor];
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

    return [defaults integerForKey: dShadeColor];
}
-(void) setShadeColor: (long)shadeColor {

    [defaults setInteger:shadeColor forKey: dShadeColor];
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


-(void) levelUp {
    
    if([self level] < 1)
        [self setLevel:[self level] + 0.1];
    if([self level] > 1)
        [self setLevel:1.0f];
}
-(void) levelDown {
    
    if([self level] > 0)
        [self setLevel:[self level] - 0.1];
    if([self level] < 0)
        [self setLevel:0.0f];
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
