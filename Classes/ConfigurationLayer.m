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
        readd = [menu parent] != nil;
        [self remove:menu];
        [menu release];
        menu = nil;
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
    
    if([[[GorillasAppDelegate get] gameLayer] running])
        [theme setIsEnabled:false];
    
    menu = [[Menu menuWithItems:theme, level, gravity, back, nil] retain];
    
    if(readd)
        [self add:menu];
}


-(void) reveal {
    
    [super reveal];
    
    [self reset];
    
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
    
    [[[GorillasAppDelegate get] gameLayer] reset];
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
