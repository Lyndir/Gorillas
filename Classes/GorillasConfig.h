//
//  GorillasConfig.h
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#ifndef _GORILLACONFIG
#define _GORILLACONFIG

#import "cocos2d.h"


@interface GorillasConfig : NSObject {

    NSUserDefaults *defaults;
}


@property (readwrite) int                   fontSize;
@property (readwrite, assign) NSString      *fontName;

@property (readwrite, assign) NSString      *cityTheme;

@property (readwrite) int                   fixedFloors;
@property (readwrite) float                 buildingMax;
@property (readonly) float                  buildingWidth;
@property (readwrite) int                   buildingAmount;
@property (readwrite) int                   buildingSpeed;
@property (readwrite, assign) NSArray       *buildingColors;

@property (readonly) float                  windowWidth;
@property (readonly) float                  windowHeight;
@property (readwrite) int                   windowAmount;
@property (readonly) float                  windowPadding;
@property (readwrite) long                  windowColorOn;
@property (readwrite) long                  windowColorOff;

@property (readwrite) long                  skyColor;
@property (readwrite) long                  starColor;
@property (readwrite) int                   starSpeed;
@property (readwrite) int                   starAmount;

@property (readwrite) int                   gravity;
@property (readwrite) long                  shadeColor;
@property (readwrite) ccTime                transitionDuration;

@property (readwrite) float                 level;
@property (readonly) NSString               *levelName;
@property (readwrite, assign) NSArray       *levelNames;
@property (readonly) int                    levelNameCount;

-(long)                                     buildingColor;

-(void)                                     levelUp;
-(void)                                     levelDown;

+(GorillasConfig *)                         get;

@end


#endif
