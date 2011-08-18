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
                      fixedFloors: (NSUInteger) nFixedFloors
                   buildingAmount: (NSUInteger) nBuildingAmount
                   buildingColors: (NSArray *) nBuildingColors

                     windowAmount: (NSUInteger) nWindowAmount
                    windowColorOn: (long) nWindowColorOn
                   windowColorOff: (long) nWindowColorOff

                         skyColor: (long) nSkyColor
                        starColor: (long) nStarColor
                       starAmount: (NSUInteger) nStarAmount

                     windModifier: (float) nWindModifier
                          gravity: (NSUInteger) nGravity {
    
    return [[[CityTheme alloc] initWithVarFloors:(NSUInteger) nVarFloors
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
          windowColorOn:(long) nWindowColorOn
         windowColorOff:(long) nWindowColorOff

               skyColor:(long) nSkyColor
              starColor:(long) nStarColor
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
    config.windowColorOn = [NSNumber numberWithLong:windowColorOn];
    config.windowColorOff = [NSNumber numberWithLong:windowColorOff];
    
    config.skyColor = [NSNumber numberWithLong:skyColor];
    config.starColor = [NSNumber numberWithLong:starColor];
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
                                                 [NSNumber numberWithLong:0xb70000ff],
                                                 [NSNumber numberWithLong:0x00b7b7ff],
                                                 [NSNumber numberWithLong:0xb7b7b7ff],
                                                 nil]
                   
                                   windowAmount:6
                                  windowColorOn:0xffffb7ff
                                 windowColorOff:0x676767ff
                   
                                       skyColor:0x0000b7ff
                                      starColor:0xb7b700ff
                                     starAmount:50
                   
                                   windModifier:20
                                        gravity:100
                   ], l(@"theme.classic"),
                  
                  [CityTheme themeWithVarFloors:12
                                    fixedFloors:4
                                 buildingAmount:12
                                 buildingColors:[NSArray arrayWithObjects:
                                                 [NSNumber numberWithLong:0x6EA665ff],
                                                 [NSNumber numberWithLong:0xD9961Aff],
                                                 [NSNumber numberWithLong:0x1DB6F2ff],
                                                 nil]
                   
                                   windowAmount:6
                                  windowColorOn:0xF2D129ff
                                 windowColorOff:0xD98723ff
                   
                                       skyColor:0x1E3615ff
                                      starColor:0xF2D129ff
                                     starAmount:150
                   
                                   windModifier:30
                                        gravity:60
                   ], l(@"theme.aliengreen"),
                  
                  [CityTheme themeWithVarFloors:28
                                    fixedFloors:6
                                 buildingAmount:14
                                 buildingColors:[NSArray arrayWithObjects:
                                                 [NSNumber numberWithLong:0x1B1F1Eff],
                                                 [NSNumber numberWithLong:0xCFB370ff],
                                                 [NSNumber numberWithLong:0xC4C7BCff],
                                                 nil]
                   
                                   windowAmount:6
                                  windowColorOn:0xFFF1BFff
                                 windowColorOff:0x39464Aff
                   
                                       skyColor:0x0B0F0Eff
                                      starColor:0xFFF1BFff
                                     starAmount:250
                   
                                   windModifier:10
                                        gravity:40
                   ], l(@"theme.classic.aliendark"),
                  
                  [CityTheme themeWithVarFloors:17
                                    fixedFloors:7
                                 buildingAmount:20
                                 buildingColors:[NSArray arrayWithObjects:
                                                 [NSNumber numberWithLong:0xb70000ff],
                                                 [NSNumber numberWithLong:0x00b7b7ff],
                                                 [NSNumber numberWithLong:0xb7b7b7ff],
                                                 nil]
                   
                                   windowAmount:6
                                  windowColorOn:0xffffb7ff
                                 windowColorOff:0x676767ff
                   
                                       skyColor:0x0000b7ff
                                      starColor:0xb7b700ff
                                     starAmount:150
                   
                                   windModifier:40
                                        gravity:140
                   ], l(@"theme.classiclarge"),
                  
                  [CityTheme themeWithVarFloors:18
                                    fixedFloors:3
                                 buildingAmount:10
                                 buildingColors:[NSArray arrayWithObjects:
                                                 [NSNumber numberWithLong:0x465902ff],
                                                 [NSNumber numberWithLong:0xA9BF04ff],
                                                 [NSNumber numberWithLong:0xF29F05ff],
                                                 nil]
                   
                                   windowAmount:6
                                  windowColorOn:0xF2E3B3ff
                                 windowColorOff:0xBF4904ff
                   
                                       skyColor:0x021343ff
                                      starColor:0xF2E3B3ff
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
