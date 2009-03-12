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
//  ConfigurationLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "GameConfigurationLayer.h"
#import "GorillasAppDelegate.h"
#import "CityTheme.h"


@implementation GameConfigurationLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    return self;
}


-(void) reset {
    
    if(menu) {
        [self removeChild:menu cleanup:YES];
        [menu release];
        menu = nil;
        
        [self removeChild:backMenu cleanup:YES];
        [backMenu release];
        backMenu = nil;
    }
    
    
    // City Theme.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *themeT    = [MenuItemFont itemFromString:@"City Theme"];
    [themeT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *themeI    = [MenuItemFont itemFromString:[[GorillasConfig get] cityTheme]
                                                target:self
                                              selector:@selector(cityTheme:)];
    [themeI setIsEnabled:![[[GorillasAppDelegate get] gameLayer] checkGameStillOn]];
    
    
    // Gravity.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *gravityT  = [MenuItemFont itemFromString:@"Gravity"];
    [gravityT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *gravityI  = [MenuItemFont itemFromString:[NSString stringWithFormat:@"%d", [[GorillasConfig get] gravity]]
                                                target:self
                                              selector:@selector(gravity:)];
    
    
    // Difficulity Level.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *levelT    = [MenuItemFont itemFromString:@"Level"];
    [levelT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *levelI    = [MenuItemFont itemFromString:[[GorillasConfig get] levelName]
                                                target:self
                                              selector:@selector(level:)];
    
    
    // Killshot Replays.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *replayT  = [MenuItemFont itemFromString:@"Replays"];
    [replayT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *replayI  = [MenuItemFont itemFromString:[NSString stringWithFormat:@"%@", [[GorillasConfig get] replay]? @"On": @"Off"]
                                               target:self
                                             selector:@selector(replay:)];
    
    
    // Follow Throw.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *followT  = [MenuItemFont itemFromString:@"Follow Throw"];
    [followT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *followI  = [MenuItemFont itemFromString:[NSString stringWithFormat:@"%@", [[GorillasConfig get] followThrow]? @"On": @"Off"]
                                               target:self
                                             selector:@selector(followThrow:)];
    
    
    menu = [[Menu menuWithItems:themeT, themeI, gravityT, levelT, gravityI, levelI, replayT, followT, replayI, followI, nil] retain];
    [menu alignItemsInColumns:
     [NSNumber numberWithUnsignedInteger:1],
     [NSNumber numberWithUnsignedInteger:1],
     [NSNumber numberWithUnsignedInteger:2],
     [NSNumber numberWithUnsignedInteger:2],
     [NSNumber numberWithUnsignedInteger:2],
     [NSNumber numberWithUnsignedInteger:2],
     nil];
    [self addChild:menu];
    
    
    // Back.
    [MenuItemFont setFontSize:[[GorillasConfig get] largeFontSize]];
    MenuItem *back     = [MenuItemFont itemFromString:@"   <   "
                                                target:self
                                              selector:@selector(back:)];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    
    backMenu = [[Menu menuWithItems:back, nil] retain];
    [backMenu setPosition:cpv([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [backMenu alignItemsHorizontally];
    [self addChild:backMenu];
}


-(void) onEnter {
    
    [self reset];
    
    [super onEnter];
}


-(void) level: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];

    NSUInteger curLevelInd = [[[GorillasConfig get] levelNames] indexOfObject:[[GorillasConfig get] levelName]];
    [[GorillasConfig get] setLevel:(float) ((curLevelInd + 1) % [[[GorillasConfig get] levelNames] count]) / [[[GorillasConfig get] levelNames] count]];
}


-(void) gravity: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    [[GorillasConfig get] setGravity:([[GorillasConfig get] gravity] + 10) % ([[GorillasConfig get] maxGravity] + 1)];
}


-(void) cityTheme: (id) sender {

    [[GorillasAppDelegate get] clickEffect];

    NSArray *themes = [[CityTheme getThemes] allKeys];
    NSString *newTheme = [themes objectAtIndex:0];
    
    BOOL found = NO;
    for(NSString *theme in themes) {
        if(found) {
            newTheme = theme;
            break;
        }
        
        if([[[GorillasConfig get] cityTheme] isEqualToString:theme])
            found = YES;
    }
    
    [[[CityTheme getThemes] objectForKey:newTheme] apply];
    [[GorillasConfig get] setCityTheme:newTheme];
    
    [[[GorillasAppDelegate get] gameLayer] reset];
}


-(void) replay: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    [[GorillasConfig get] setReplay:![[GorillasConfig get] replay]];
}


-(void) followThrow: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    [[GorillasConfig get] setFollowThrow:![[GorillasConfig get] followThrow]];
}


-(void) back: (id) sender {
    
    [[GorillasAppDelegate get] clickEffect];
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {
    
    [menu release];
    menu = nil;
    
    [backMenu release];
    backMenu = nil;
    
    [super dealloc];
}


@end
