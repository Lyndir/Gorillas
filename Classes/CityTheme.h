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
//  CityTheme.h
//  Gorillas
//
//  Created by Maarten Billemont on 05/12/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//



@interface CityTheme : NSObject {

    int     fixedFloors;
    float   buildingMax;
    int     buildingAmount;
    NSArray *buildingColors;
    
    int     windowAmount;
    long    windowColorOn;
    long    windowColorOff;
    
    long    skyColor;
    long    starColor;
    int     starAmount;
    
    float   windModifier;
    int     gravity;
}

@property (nonatomic, readonly) int                fixedFloors;
@property (nonatomic, readonly) float              buildingMax;
@property (nonatomic, readonly) int                buildingAmount;
@property (nonatomic, readonly, assign) NSArray    *buildingColors;

@property (nonatomic, readonly) int                windowAmount;
@property (nonatomic, readonly) long               windowColorOn;
@property (nonatomic, readonly) long               windowColorOff;

@property (nonatomic, readonly) long               skyColor;
@property (nonatomic, readonly) long               starColor;
@property (nonatomic, readonly) int                starAmount;

@property (nonatomic, readonly) float              windModifier;
@property (nonatomic, readonly) int                gravity;

-(void) apply;

+(CityTheme *) themeWithFixedFloors: (int) nFixedFloors
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
                            gravity: (int) nGravity;
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
                  gravity: (int) nGravity;

+(NSDictionary *)                       getThemes;
+(NSString *)                           defaultThemeName;

@end
