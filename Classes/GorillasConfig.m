//
//  GorillasConfig.m
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "GorillasConfig.h"
#import "cocos2d.h"


@implementation GorillasConfig

@synthesize fontSize, fontName;
@synthesize fixedFloors, buildingMax, buildingAmount, buildingSpeed, buildingColors;
@synthesize windowAmount, windowColorOn, windowColorOff;
@synthesize starColor, starSpeed, starAmount;
@synthesize gravity, shadeColor, transitionDuration;
@synthesize level, levelNames, levelNameCount;


-(id) init {

    if(!(self = [super init]))
        return self;

    fontSize            = 30;
    fontName            = @"Arial Rounded MT Bold";

    fixedFloors         = 4;
    buildingMax         = 0.7f;
    buildingAmount      = 10;
    buildingSpeed       = 1;
    buildingColorCount  = 3;
    buildingColors      = malloc(sizeof(long) * buildingColorCount);
    buildingColors[0]   = 0xb70000ff;
    buildingColors[1]   = 0x00b7b7ff;
    buildingColors[2]   = 0xb7b7b7ff;

    windowAmount        = 6;
    windowColorOn       = 0xffffb7ff;
    windowColorOff      = 0x676767ff;

    starColor           = 0xb7b700ff;
    starSpeed           = 30;
    starAmount          = 100;

    gravity             = 100;
    shadeColor          = 0x000000cc;
    transitionDuration  = 0.5f;

    level               = 0.1f;
    levelNameCount      = 8;
    levelNames          = malloc(sizeof(NSString *) * levelNameCount);
    levelNames[0]       = @"Toddler";
    levelNames[1]       = @"Playground";
    levelNames[2]       = @"Training";
    levelNames[3]       = @"Graduate";
    levelNames[4]       = @"Tough";
    levelNames[5]       = @"Sniper";
    levelNames[6]       = @"Are You Kidding?";
    levelNames[7]       = @"Impossible";

    return self;
}


-(long) buildingColor {
    
    return buildingColors[random() % buildingColorCount];
}


-(float) buildingWidth {
    
	CGRect size = [[Director sharedDirector] winSize];
    return (size.size.width / [self buildingAmount] - 1);
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


-(void) levelUp {
    
    if(level < 1)
        level += 0.1;
    if(level > 1)
        level = 1;
}


-(void) levelDown {
    
    if(level > 0)
        level -= 0.1;
    if(level < 0)
        level = 0;
}


-(NSString *) levelName {

    int levelIndex = (int) ([self level] * [self levelNameCount]);
    if(levelIndex == [self levelNameCount])
        levelIndex = levelNameCount - 1;
    
    return [self levelNames][levelIndex];
}


+(GorillasConfig *) get {
    
    static GorillasConfig *instance;
    if(!instance)
        instance = [[GorillasConfig alloc] init];
    
    return instance;
}


@end
