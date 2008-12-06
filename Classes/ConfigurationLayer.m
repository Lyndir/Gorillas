//
//  ConfigurationLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "ConfigurationLayer.h"
#import "GorillasAppDelegate.h"
#import "CityTheme.h"


@implementation ConfigurationLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    [self reset];
    
    return self;
}


-(void) reset {
    
    BOOL readd = false;
    
    if(menu) {
        [self remove:menu];
        [menu release];
        menu = nil;
        readd = true;
    }
    
    MenuItem *theme     = [MenuItemFont itemFromString:
                           [NSString stringWithFormat:@"%@ : %@", @"City Theme", [[GorillasConfig get] cityTheme]]
                                                target: self
                                              selector: @selector(cityTheme:)];
    MenuItem *level     = [MenuItemFont itemFromString:
                           [NSString stringWithFormat:@"%@ : %@", @"Level", [[GorillasConfig get] levelName]]
                                                target: self
                                              selector: @selector(level:)];
    MenuItem *gravity   = [MenuItemFont itemFromString:
                           [NSString stringWithFormat:@"%@ : %d", @"Gravity", [[GorillasConfig get] gravity]]
                                                target: self
                                              selector: @selector(gravity:)];
    MenuItem *back      = [MenuItemFont itemFromString:@"Back"
                                                target: self
                                              selector: @selector(mainMenu:)];
    
    menu = [[Menu menuWithItems:theme, level, gravity, back, nil] retain];
    
    if(readd)
        [self add:menu];
}


-(void) reveal {
    
    [super reveal];
    
    [menu do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    [self add:menu];
}


-(void) level: (id) sender {
    
    NSString *curLevelName = [[GorillasConfig get] levelName];
    int curLevelInd;
    
    for(curLevelInd = 0; curLevelInd < [[GorillasConfig get] levelNameCount]; ++curLevelInd) {
        if([[[GorillasConfig get] levelNames] objectAtIndex:curLevelInd] == curLevelName)
            break;
    }

    [[GorillasConfig get] setLevel:(float) ((curLevelInd + 1) % [[GorillasConfig get] levelNameCount]) / [[GorillasConfig get] levelNameCount]];
    
    [self reset];
}


-(void) gravity: (id) sender {
    
    [[GorillasConfig get] setGravity:([[GorillasConfig get] gravity] + 10) % 100];
        
    [self reset];
}


-(void) cityTheme: (id) sender {
    
    NSArray *themes = [[CityTheme getThemes] allKeys];
    NSString *newTheme = [themes objectAtIndex:0];
    
    BOOL found = false;
    for(NSString *theme in themes) {
        if(found) {
            newTheme = theme;
            break;
        }
        
        if([[[GorillasConfig get] cityTheme] isEqualToString:theme])
            found = true;
    }
    
    [[[CityTheme getThemes] objectForKey:newTheme] apply];
    [[GorillasConfig get] setCityTheme:newTheme];
    
    [self reset];
}


-(void) mainMenu: (id) sender {
    
    [[GorillasAppDelegate get] showMainMenu];
}


-(void) dealloc {
    
    [menu release];
    [super dealloc];
}


@end
