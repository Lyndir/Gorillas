//
//  CityTheme.m
//  Gorillas
//
//  Created by Maarten Billemont on 05/12/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "CityTheme.h"
#import "GorillasConfig.h"


@implementation CityTheme

@synthesize fixedFloors, buildingMax, buildingAmount, buildingColors;
@synthesize windowAmount, windowColorOn, windowColorOff;
@synthesize starColor, starAmount;
@synthesize gravity;


-(id) initWithFixedFloors: (int) nFixedFloors
              BuildingMax: (float) nBuildingMax
           BuildingAmount: (int) nBuildingAmount
           BuildingColors: (NSArray *) nBuildingColors

             WindowAmount: (int) nWindowAmount
            WindowColorOn: (long) nWindowColorOn
           WindowColorOff: (long) nWindowColorOff

                StarColor: (long) nStarColor
               StarAmount: (int) nStarAmount

                  Gravity: (int)nGravity {
    
    if(!(self = [super init]))
        return self;
    
    fixedFloors     = nFixedFloors;
    buildingMax     = nBuildingMax;
    buildingAmount  = nBuildingAmount;
    buildingColors  = nBuildingColors;
    
    windowAmount    = nWindowAmount;
    windowColorOn   = nWindowColorOn;
    windowColorOff  = nWindowColorOff;
    
    starColor       = nStarColor;
    starAmount      = nStarAmount;
    
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
    
    [config setStarColor:starColor];
    [config setStarAmount:starAmount];
    
    [config setGravity:gravity];
}


+(NSDictionary *) getThemes {
    
    static NSDictionary *themes = nil;
    if(!themes) {
        themes = [[NSDictionary dictionaryWithObjectsAndKeys:
                   [[CityTheme alloc] initWithFixedFloors:4
                                              BuildingMax:0.7f
                                           BuildingAmount:10
                                           BuildingColors:[[NSArray arrayWithObjects:
                                                           [NSNumber numberWithLong:0xb70000ff],
                                                           [NSNumber numberWithLong:0x00b7b7ff],
                                                           [NSNumber numberWithLong:0xb7b7b7ff],
                                                           nil] retain]
                    
                                             WindowAmount:6
                                            WindowColorOn:0xffffb7ff
                                           WindowColorOff:0x676767ff
                    
                                                StarColor:0xb7b700ff
                                               StarAmount:100
                    
                                                  Gravity:90
                   ], @"Classic",

                   [[CityTheme alloc] initWithFixedFloors:4
                                              BuildingMax:0.5f
                                           BuildingAmount:15
                                           BuildingColors:[[NSArray arrayWithObjects:
                                                           [NSNumber numberWithLong:0xcc3333ff],
                                                           [NSNumber numberWithLong:0xcccc33ff],
                                                           [NSNumber numberWithLong:0x33cc33ff],
                                                           [NSNumber numberWithLong:0x3333ccff],
                                                           nil] retain]
                    
                                             WindowAmount:6
                                            WindowColorOn:0xffffccff
                                           WindowColorOff:0x333333ff
                    
                                                StarColor:0xeeee00ff
                                               StarAmount:200
                    
                                                  Gravity:60
                    ], @"Foo",
                   nil
                   ] retain];
    }
    
    return themes;
}


+(NSString *) defaultThemeName {
    
    return @"Foo";
}


@end
