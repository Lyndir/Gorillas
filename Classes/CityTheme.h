//
//  CityTheme.h
//  Gorillas
//
//  Created by Maarten Billemont on 05/12/08.
//  Copyright 2008 Lin.k. All rights reserved.
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
