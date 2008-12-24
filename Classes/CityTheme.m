/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
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
//  CityTheme.m
//  Gorillas
//
//  Created by Maarten Billemont on 05/12/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "CityTheme.h"
#import "GorillasConfig.h"


@implementation CityTheme

@synthesize fixedFloors, buildingMax, buildingAmount, buildingColors;
@synthesize windowAmount, windowColorOn, windowColorOff;
@synthesize skyColor, starColor, starAmount;
@synthesize windModifier, gravity;


-(id) initWithFixedFloors: (int) nFixedFloors
              buildingMax: (float) nBuildingMax
           buildingAmount: (int) nBuildingAmount
           buildingColors: (NSArray *) nBuildingColors

             windowAmount: (int) nWindowAmount
            windowColorOn: (long) nWindowColorOn
           windowColorOff: (long) nWindowColorOff

                 skyColor: (long) nSkyColor
                starColor: (long) nStarColor
               starAmount: (int) nStarAmount

             windModifier: (float) nWindModifier
                  gravity: (int) nGravity {
    
    if(!(self = [super init]))
        return self;
    
    fixedFloors     = nFixedFloors;
    buildingMax     = nBuildingMax;
    buildingAmount  = nBuildingAmount;
    buildingColors  = nBuildingColors;
    
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
    
    [config setFixedFloors:fixedFloors];
    [config setBuildingMax:buildingMax];
    [config setBuildingAmount:buildingAmount];
    [config setBuildingColors:buildingColors];
    
    [config setWindowAmount:windowAmount];
    [config setWindowColorOn:windowColorOn];
    [config setWindowColorOff:windowColorOff];
    
    [config setSkyColor:skyColor];
    [config setStarColor:starColor];
    [config setStarAmount:starAmount];
    
    [config setWindModifier:windModifier];
    [config setGravity:gravity];
}


+(NSDictionary *) getThemes {
    
    static NSDictionary *themes = nil;
    if(!themes) {
        themes = [[NSDictionary dictionaryWithObjectsAndKeys:
                   [[CityTheme alloc] initWithFixedFloors:4
                                              buildingMax:0.7f
                                           buildingAmount:10
                                           buildingColors:[[NSArray arrayWithObjects:
                                                           [NSNumber numberWithLong:0xb70000ff],
                                                           [NSNumber numberWithLong:0x00b7b7ff],
                                                           [NSNumber numberWithLong:0xb7b7b7ff],
                                                           nil] retain]
                    
                                             windowAmount:6
                                            windowColorOn:0xffffb7ff
                                           windowColorOff:0x676767ff
                    
                                                 skyColor:0x0000b7ff
                                                starColor:0xb7b700ff
                                               starAmount:30
                    
                                             windModifier:20
                                                  gravity:100
                   ], @"Classic",

                   [[CityTheme alloc] initWithFixedFloors:4
                                              buildingMax:0.5f
                                           buildingAmount:12
                                           buildingColors:[[NSArray arrayWithObjects:
                                                            [NSNumber numberWithLong:0x6EA665ff],
                                                            [NSNumber numberWithLong:0xD9961Aff],
                                                            [NSNumber numberWithLong:0x1DB6F2ff],
                                                            nil] retain]
                    
                                             windowAmount:6
                                            windowColorOn:0xF2D129ff
                                           windowColorOff:0xD98723ff
                    
                                                 skyColor:0x1E3615ff
                                                starColor:0xF2D129ff
                                               starAmount:100
                    
                                             windModifier:30
                                                  gravity:60
                    ], @"Alien Retro",
                   
                   [[CityTheme alloc] initWithFixedFloors:6
                                              buildingMax:0.8f
                                           buildingAmount:14
                                           buildingColors:[[NSArray arrayWithObjects:
                                                            [NSNumber numberWithLong:0x1B1F1Eff],
                                                            [NSNumber numberWithLong:0xCFB370ff],
                                                            [NSNumber numberWithLong:0xC4C7BCff],
                                                            nil] retain]
                    
                                             windowAmount:6
                                            windowColorOn:0xFFF1BFff
                                           windowColorOff:0x39464Aff
                    
                                                 skyColor:0x0B0F0Eff
                                                starColor:0xFFF1BFff
                                               starAmount:200
                    
                                             windModifier:10
                                                  gravity:40
                    ], @"Alien Skies",
                   
                   [[CityTheme alloc] initWithFixedFloors:3
                                              buildingMax:0.6f
                                           buildingAmount:10
                                           buildingColors:[[NSArray arrayWithObjects:
                                                            [NSNumber numberWithLong:0x465902ff],
                                                            [NSNumber numberWithLong:0xA9BF04ff],
                                                            [NSNumber numberWithLong:0xF29F05ff],
                                                            nil] retain]
                    
                                             windowAmount:6
                                            windowColorOn:0xF2E3B3ff
                                           windowColorOff:0xBF4904ff
                    
                                                 skyColor:0x021343ff
                                                starColor:0xF2E3B3ff
                                               starAmount:50
                    
                                             windModifier:15
                                                  gravity:80
                    ], @"Summer",
                   
                   nil
                   ] retain];
    }
    
    return themes;
}


+(NSString *) defaultThemeName {
    
    return @"Classic";
}


@end
