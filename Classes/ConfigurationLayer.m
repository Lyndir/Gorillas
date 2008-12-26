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
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "ConfigurationLayer.h"
#import "GorillasAppDelegate.h"
#import "CityTheme.h"


@implementation ConfigurationLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    return self;
}


-(void) reset {
    
    BOOL readd = false;
    
    if(menu) {
        readd = [menu parent] != nil;
        
        [self remove:menu];
        [menu release];
        menu = nil;
        
        [self remove:backMenu];
        [backMenu release];
        backMenu = nil;
    }
    
    
    // Audio Track.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *audioT    = [MenuItemFont itemFromString:@"Audio Track"
                                                target: self
                                              selector: @selector(audioTrack:)];
    [audioT setIsEnabled:false];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *audioI    = [MenuItemFont itemFromString:[[GorillasConfig get] currentTrackName]
                                                target: self
                                              selector: @selector(audioTrack:)];

    
    // City Theme.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *themeT    = [MenuItemFont itemFromString:@"City Theme"
                                                target: self
                                              selector: @selector(cityTheme:)];
    [themeT setIsEnabled:false];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *themeI    = [MenuItemFont itemFromString:[[GorillasConfig get] cityTheme]
                                                target: self
                                              selector: @selector(cityTheme:)];
    [themeI setIsEnabled:![[[GorillasAppDelegate get] gameLayer] running]];
    
    
    // Difficulity Level.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *levelT    = [MenuItemFont itemFromString:@"Level"
                                                target: self
                                              selector: @selector(level:)];
    [levelT setIsEnabled:false];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *levelI    = [MenuItemFont itemFromString:[[GorillasConfig get] levelName]
                                                target: self
                                              selector: @selector(level:)];
    
    
    // Gravity.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *gravityT  = [MenuItemFont itemFromString:@"Gravity"
                                                target: self
                                              selector: @selector(gravity:)];
    [gravityT setIsEnabled:false];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *gravityI  = [MenuItemFont itemFromString:[NSString stringWithFormat:@"%d", [[GorillasConfig get] gravity]]
                                                target: self
                                              selector: @selector(gravity:)];
    
    menu = [[Menu menuWithItems:audioT, audioI, themeT, themeI, levelT, levelI, gravityT, gravityI, nil] retain];
    [menu alignItemsVertically];
    
    
    // Back.
    MenuItem *back     = [MenuItemFont itemFromString:@"<"
                                                target: self
                                              selector: @selector(mainMenu:)];
    
    backMenu = [[Menu menuWithItems:back, nil] retain];
    [backMenu setPosition:cpv([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [backMenu alignItemsHorizontally];

    if(readd) {
        [self add:menu];
        [self add:backMenu];
    }
}


-(void) reveal {
    
    [super reveal];
    
    [self reset];
    
    [menu do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    [self add:menu];
    [backMenu do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    [self add:backMenu];
}


-(void) level: (id) sender {
    
    NSString *curLevelName = [[GorillasConfig get] levelName];
    int curLevelInd;
    
    for(curLevelInd = 0; curLevelInd < [[GorillasConfig get] levelNameCount]; ++curLevelInd) {
        if([[[GorillasConfig get] levelNames] objectAtIndex:curLevelInd] == curLevelName)
            break;
    }

    [[GorillasConfig get] setLevel:(float) ((curLevelInd + 1) % [[GorillasConfig get] levelNameCount]) / [[GorillasConfig get] levelNameCount]];
}


-(void) gravity: (id) sender {
    
    [[GorillasConfig get] setGravity:([[GorillasConfig get] gravity] + 10) % ([[GorillasConfig get] maxGravity] + 1)];
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
}


-(void) audioTrack: (id) sender {
    
    NSArray *tracks = [[[GorillasConfig get] tracks] allKeys];
    NSString *newTrack = [tracks objectAtIndex:0];
    
    BOOL found = false;
    for(NSString *track in tracks) {
        if(found) {
            newTrack = track;
            break;
        }
        
        if([[[GorillasConfig get] currentTrack] isEqualToString:track])
            found = true;
    }

    if(![newTrack length])
        newTrack = nil;
    
    [[GorillasAppDelegate get] playTrack:newTrack];
}


-(void) mainMenu: (id) sender {
    
    [[GorillasAppDelegate get] showMainMenu];
}


-(void) dealloc {
    
    [menu release];
    [super dealloc];
}


@end
