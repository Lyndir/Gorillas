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
//  CityTheme.h
//  Gorillas
//
//  Created by Maarten Billemont on 05/12/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//



@interface CityTheme : NSObject

@property(nonatomic, readonly) NSUInteger varFloors;
@property(nonatomic, readonly) NSUInteger fixedFloors;
@property(nonatomic, readonly) NSUInteger buildingAmount;
@property(nonatomic, readonly) NSArray *buildingColors;

@property(nonatomic, readonly) NSUInteger windowAmount;
@property(nonatomic, readonly) unsigned long windowColorOn;
@property(nonatomic, readonly) unsigned long windowColorOff;

@property(nonatomic, readonly) unsigned long skyColor;
@property(nonatomic, readonly) unsigned long starColor;
@property(nonatomic, readonly) NSUInteger starAmount;

@property(nonatomic, readonly) float windModifier;
@property(nonatomic, readonly) NSUInteger gravity;

- (void)apply;

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
                          gravity:(NSUInteger)nGravity;
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
                gravity:(NSUInteger)nGravity;

+ (NSDictionary *)getThemes;
+ (NSArray *)getThemeNames;
+ (void)forgetThemes;
+ (NSString *)defaultThemeName;

@end
