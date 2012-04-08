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
//  CityTheme.m
//  Gorillas
//
//  Created by Maarten Billemont on 05/12/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "CityTheme.h"
#import "GorillasAppDelegate.h"


static NSDictionary *themes = nil;

@implementation CityTheme

@synthesize varFloors, fixedFloors, buildingAmount, buildingColors;
@synthesize windowAmount, windowColorOn, windowColorOff;
@synthesize skyColor, starColor, starAmount;
@synthesize windModifier, gravity;


+(CityTheme *) themeWithVarFloors:(NSUInteger) nVarFloors
                      fixedFloors:(NSUInteger) nFixedFloors
                   buildingAmount:(NSUInteger) nBuildingAmount
                   buildingColors:(NSArray *) nBuildingColors

                     windowAmount:(NSUInteger) nWindowAmount
                    windowColorOn:(unsigned long) nWindowColorOn
                   windowColorOff:(unsigned long) nWindowColorOff

                         skyColor:(unsigned long) nSkyColor
                        starColor:(unsigned long) nStarColor
                       starAmount:(NSUInteger) nStarAmount

                     windModifier:(float) nWindModifier
                          gravity:(NSUInteger) nGravity {
    
    return [[[CityTheme alloc] initWithVarFloors:(NSUInteger)nVarFloors
                                     fixedFloors:nFixedFloors
                                  buildingAmount:nBuildingAmount
                                  buildingColors:nBuildingColors
                                    windowAmount:nWindowAmount
                                   windowColorOn:nWindowColorOn
                                  windowColorOff:nWindowColorOff
                                        skyColor:nSkyColor
                                       starColor:nStarColor
                                      starAmount:nStarAmount
                                    windModifier:nWindModifier
                                         gravity:nGravity] autorelease];
}

-(id) initWithVarFloors:(NSUInteger) nVarFloors
            fixedFloors:(NSUInteger) nFixedFloors
         buildingAmount:(NSUInteger) nBuildingAmount
         buildingColors:(NSArray *) nBuildingColors

           windowAmount:(NSUInteger) nWindowAmount
          windowColorOn:(unsigned long) nWindowColorOn
         windowColorOff:(unsigned long) nWindowColorOff

               skyColor:(unsigned long) nSkyColor
              starColor:(unsigned long) nStarColor
             starAmount:(NSUInteger) nStarAmount

           windModifier:(float) nWindModifier
                gravity:(NSUInteger) nGravity {
    
    if(!(self = [super init]))
        return self;
    
    varFloors       = nVarFloors;
    fixedFloors     = nFixedFloors;
    buildingAmount  = nBuildingAmount;
    buildingColors  = [nBuildingColors retain];
    
    windowAmount    = nWindowAmount;
    windowColorOn   = nWindowColorOn;
    windowColorOff  = nWindowColorOff;
    
    skyColor        = nSkyColor;
    starColor       = nStarColor;
    starAmount      = nStarAmount;
    
    windModifier    = nWindModifier;
    gravity         = nGravity;
    
    return self;
}


-(void) apply {
    
    GorillasConfig *config = [GorillasConfig get];
    
    config.varFloors = [NSNumber numberWithUnsignedInt:varFloors];
    config.fixedFloors = [NSNumber numberWithUnsignedInt:fixedFloors];
    config.buildingAmount = [NSNumber numberWithUnsignedInt:buildingAmount];
    config.buildingColors = buildingColors;
    
    config.windowAmount = [NSNumber numberWithUnsignedInt:windowAmount];
    config.windowColorOn = [NSNumber numberWithUnsignedLong:windowColorOn];
    config.windowColorOff = [NSNumber numberWithUnsignedLong:windowColorOff];
    
    config.skyColor = [NSNumber numberWithUnsignedLong:skyColor];
    config.starColor = [NSNumber numberWithUnsignedLong:starColor];
    config.starAmount = [NSNumber numberWithUnsignedInt:starAmount];
    
    config.windModifier = [NSNumber numberWithFloat:windModifier];
    config.gravity = [NSNumber numberWithUnsignedInt:gravity];
    
    dbg(@"CityTheme applied");
    [[GorillasAppDelegate get].gameLayer reset];
}


+(NSDictionary *) getThemes {
    
    if(!themes) {
        themes = [[NSDictionary alloc] initWithObjectsAndKeys:
                  [CityTheme themeWithVarFloors:15
                                    fixedFloors:4
                                 buildingAmount:10
                                 buildingColors:[NSArray arrayWithObjects:
                                                 [NSNumber numberWithUnsignedLong:0xb70000ffUL],
                                                 [NSNumber numberWithUnsignedLong:0x00b7b7ffUL],
                                                 [NSNumber numberWithUnsignedLong:0xb7b7b7ffUL],
                                                 nil]
                   
                                   windowAmount:6
                                  windowColorOn:0xffffb7ffUL
                                 windowColorOff:0x676767ffUL
                   
                                       skyColor:0x0000b7ffUL
                                      starColor:0xb7b700ffUL
                                     starAmount:50
                   
                                   windModifier:20
                                        gravity:100
                   ], l(@"theme.classic"),
                  
                  [CityTheme themeWithVarFloors:12
                                    fixedFloors:4
                                 buildingAmount:12
                                 buildingColors:[NSArray arrayWithObjects:
                                                 [NSNumber numberWithUnsignedLong:0x6EA665ffUL],
                                                 [NSNumber numberWithUnsignedLong:0xD9961AffUL],
                                                 [NSNumber numberWithUnsignedLong:0x1DB6F2ffUL],
                                                 nil]
                   
                                   windowAmount:6
                                  windowColorOn:0xF2D129ffUL
                                 windowColorOff:0xD98723ffUL
                   
                                       skyColor:0x1E3615ffUL
                                      starColor:0xF2D129ffUL
                                     starAmount:150
                   
                                   windModifier:30
                                        gravity:60
                   ], l(@"theme.aliengreen"),
                  
                  [CityTheme themeWithVarFloors:28
                                    fixedFloors:6
                                 buildingAmount:14
                                 buildingColors:[NSArray arrayWithObjects:
                                                 [NSNumber numberWithUnsignedLong:0x1B1F1EffUL],
                                                 [NSNumber numberWithUnsignedLong:0xCFB370ffUL],
                                                 [NSNumber numberWithUnsignedLong:0xC4C7BCffUL],
                                                 nil]
                   
                                   windowAmount:6
                                  windowColorOn:0xFFF1BFffUL
                                 windowColorOff:0x39464AffUL
                   
                                       skyColor:0x0B0F0EffUL
                                      starColor:0xFFF1BFffUL
                                     starAmount:250
                   
                                   windModifier:10
                                        gravity:40
                   ], l(@"theme.classic.aliendark"),
                  
                  [CityTheme themeWithVarFloors:17
                                    fixedFloors:7
                                 buildingAmount:20
                                 buildingColors:[NSArray arrayWithObjects:
                                                 [NSNumber numberWithUnsignedLong:0xb70000ffUL],
                                                 [NSNumber numberWithUnsignedLong:0x00b7b7ffUL],
                                                 [NSNumber numberWithUnsignedLong:0xb7b7b7ffUL],
                                                 nil]
                   
                                   windowAmount:6
                                  windowColorOn:0xffffb7ffUL
                                 windowColorOff:0x676767ffUL
                   
                                       skyColor:0x0000b7ffUL
                                      starColor:0xb7b700ffUL
                                     starAmount:150
                   
                                   windModifier:40
                                        gravity:140
                   ], l(@"theme.classiclarge"),
                  
                  [CityTheme themeWithVarFloors:18
                                    fixedFloors:3
                                 buildingAmount:10
                                 buildingColors:[NSArray arrayWithObjects:
                                                 [NSNumber numberWithUnsignedLong:0x465902ffUL],
                                                 [NSNumber numberWithUnsignedLong:0xA9BF04ffUL],
                                                 [NSNumber numberWithUnsignedLong:0xF29F05ffUL],
                                                 nil]
                   
                                   windowAmount:6
                                  windowColorOn:0xF2E3B3ffUL
                                 windowColorOff:0xBF4904ffUL
                   
                                       skyColor:0x021343ffUL
                                      starColor:0xF2E3B3ffUL
                                     starAmount:100
                   
                                   windModifier:15
                                        gravity:80
                   ], l(@"theme.warm"),
                  
                  nil];
    }
    
    return themes;
}

+(NSArray *) getThemeNames {
    
    return [[[self getThemes] allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

+ (void)forgetThemes {
    
    [themes release];
    themes = nil;
}


-(void) dealloc {
    
    [buildingColors release];
    buildingColors = nil;
    
    [super dealloc];
}


+(NSString *) defaultThemeName {
    
    return l(@"theme.classic");
}


@end
