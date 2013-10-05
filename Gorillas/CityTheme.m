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

+ (CityTheme *)themeWithVarFloors:(NSUInteger)nVarFloors
                      fixedFloors:(NSUInteger)nFixedFloors
                   buildingAmount:(NSUInteger)nBuildingAmount
                   buildingColors:(NSArray *)nBuildingColors

                     windowAmount:(NSUInteger)nWindowAmount
                    windowColorOn:(unsigned long)nWindowColorOn
                   windowColorOff:(unsigned long)nWindowColorOff

                         skyColor:(unsigned long)nSkyColor
                        starColor:(unsigned long)nStarColor
                       starAmount:(NSUInteger)nStarAmount

                     windModifier:(float)nWindModifier
                          gravity:(NSUInteger)nGravity {

    return [[CityTheme alloc] initWithVarFloors:(NSUInteger)nVarFloors
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
                                        gravity:nGravity];
}

- (id)initWithVarFloors:(NSUInteger)nVarFloors
            fixedFloors:(NSUInteger)nFixedFloors
         buildingAmount:(NSUInteger)nBuildingAmount
         buildingColors:(NSArray *)nBuildingColors

           windowAmount:(NSUInteger)nWindowAmount
          windowColorOn:(unsigned long)nWindowColorOn
         windowColorOff:(unsigned long)nWindowColorOff

               skyColor:(unsigned long)nSkyColor
              starColor:(unsigned long)nStarColor
             starAmount:(NSUInteger)nStarAmount

           windModifier:(float)nWindModifier
                gravity:(NSUInteger)nGravity {

    if (!(self = [super init]))
        return self;

    _varFloors = nVarFloors;
    _fixedFloors = nFixedFloors;
    _buildingAmount = nBuildingAmount;
    _buildingColors = nBuildingColors;

    _windowAmount = nWindowAmount;
    _windowColorOn = nWindowColorOn;
    _windowColorOff = nWindowColorOff;

    _skyColor = nSkyColor;
    _starColor = nStarColor;
    _starAmount = nStarAmount;

    _windModifier = nWindModifier;
    _gravity = nGravity;

    return self;
}

- (void)apply {

    GorillasConfig *config = [GorillasConfig get];

    config.varFloors = @(self.varFloors);
    config.fixedFloors = @(self.fixedFloors);
    config.buildingAmount = @(self.buildingAmount);
    config.buildingColors = self.buildingColors;

    config.windowAmount = @(self.windowAmount);
    config.windowColorOn = @(self.windowColorOn);
    config.windowColorOff = @(self.windowColorOff);

    config.skyColor = @(self.skyColor);
    config.starColor = @(self.starColor);
    config.starAmount = @(self.starAmount);

    config.windModifier = @(self.windModifier);
    config.gravity = @(self.gravity);

    dbg(@"CityTheme applied");
    [[GorillasAppDelegate get].gameLayer reset];
}

+ (NSDictionary *)getThemes {

    if (!themes) {
        themes = @{
                PearlLocalize( @"theme.classic" )           : [CityTheme themeWithVarFloors:15
                                                                                fixedFloors:4
                                                                             buildingAmount:10
                                                                             buildingColors:@[
                                                                                     @0xb70000ffUL,
                                                                                     @0x00b7b7ffUL,
                                                                                     @0xb7b7b7ffUL
                                                                             ]

                                                                               windowAmount:6
                                                                              windowColorOn:0xffffb7ffUL
                                                                             windowColorOff:0x676767ffUL

                                                                                   skyColor:0x0000b7ffUL
                                                                                  starColor:0xb7b700ffUL
                                                                                 starAmount:50

                                                                               windModifier:20
                                                                                    gravity:100
                ],

                PearlLocalize( @"theme.aliengreen" )        : [CityTheme themeWithVarFloors:12
                                                                                fixedFloors:4
                                                                             buildingAmount:12
                                                                             buildingColors:@[
                                                                                     @0x6EA665ffUL,
                                                                                     @0xD9961AffUL,
                                                                                     @0x1DB6F2ffUL
                                                                             ]

                                                                               windowAmount:6
                                                                              windowColorOn:0xF2D129ffUL
                                                                             windowColorOff:0xD98723ffUL

                                                                                   skyColor:0x1E3615ffUL
                                                                                  starColor:0xF2D129ffUL
                                                                                 starAmount:150

                                                                               windModifier:30
                                                                                    gravity:60
                ],

                PearlLocalize( @"theme.classic.aliendark" ) : [CityTheme themeWithVarFloors:28
                                                                                fixedFloors:6
                                                                             buildingAmount:14
                                                                             buildingColors:@[
                                                                                     @0x1B1F1EffUL,
                                                                                     @0xCFB370ffUL,
                                                                                     @0xC4C7BCffUL
                                                                             ]

                                                                               windowAmount:6
                                                                              windowColorOn:0xFFF1BFffUL
                                                                             windowColorOff:0x39464AffUL

                                                                                   skyColor:0x0B0F0EffUL
                                                                                  starColor:0xFFF1BFffUL
                                                                                 starAmount:250

                                                                               windModifier:10
                                                                                    gravity:40
                ],

                PearlLocalize( @"theme.classiclarge" )      : [CityTheme themeWithVarFloors:17
                                                                                fixedFloors:7
                                                                             buildingAmount:20
                                                                             buildingColors:@[
                                                                                     @0xb70000ffUL,
                                                                                     @0x00b7b7ffUL,
                                                                                     @0xb7b7b7ffUL
                                                                             ]

                                                                               windowAmount:6
                                                                              windowColorOn:0xffffb7ffUL
                                                                             windowColorOff:0x676767ffUL

                                                                                   skyColor:0x0000b7ffUL
                                                                                  starColor:0xb7b700ffUL
                                                                                 starAmount:150

                                                                               windModifier:40
                                                                                    gravity:140
                ],

                PearlLocalize( @"theme.warm" )              : [CityTheme themeWithVarFloors:18
                                                                                fixedFloors:3
                                                                             buildingAmount:10
                                                                             buildingColors:@[
                                                                                     @0x465902ffUL,
                                                                                     @0xA9BF04ffUL,
                                                                                     @0xF29F05ffUL
                                                                             ]

                                                                               windowAmount:6
                                                                              windowColorOn:0xF2E3B3ffUL
                                                                             windowColorOff:0xBF4904ffUL

                                                                                   skyColor:0x021343ffUL
                                                                                  starColor:0xF2E3B3ffUL
                                                                                 starAmount:100

                                                                               windModifier:15
                                                                                    gravity:80
                ]
        };
    }

    return themes;
}

+ (NSArray *)getThemeNames {

    return [[[self getThemes] allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

+ (void)forgetThemes {

    themes = nil;
}

+ (NSString *)defaultThemeName {

    return PearlLocalize( @"theme.classic" );
}

@end
