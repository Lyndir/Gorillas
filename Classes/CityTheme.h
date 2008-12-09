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
//  CityTheme.h
//  Gorillas
//
//  Created by Maarten Billemont on 05/12/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import <UIKit/UIKit.h>


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
    
    int     gravity;
}

@property (readonly) int                fixedFloors;
@property (readonly) float              buildingMax;
@property (readonly) int                buildingAmount;
@property (readonly, assign) NSArray    *buildingColors;

@property (readonly) int                windowAmount;
@property (readonly) long               windowColorOn;
@property (readonly) long               windowColorOff;

@property (readonly) long               skyColor;
@property (readonly) long               starColor;
@property (readonly) int                starAmount;

@property (readonly) int                gravity;

-(void) apply;

+(NSDictionary *)                       getThemes;
+(NSString *)                           defaultThemeName;

@end
