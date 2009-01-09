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


@implementation AVConfigurationLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    return self;
}


-(void) reset {
    
    if(menu) {
        [self removeAndStop:menu];
        [menu release];
        menu = nil;
        
        [self removeAndStop:backMenu];
        [backMenu release];
        backMenu = nil;
    }
    
    
    // Audio Track.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *audioT    = [MenuItemFont itemFromString:@"Audio Track"];
    [audioT setIsEnabled:false];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *audioI    = [MenuItemFont itemFromString:[[GorillasConfig get] currentTrackName]
                                                target:self
                                              selector:@selector(audioTrack:)];
    
    
    // Weather.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *weatherT  = [MenuItemFont itemFromString:@"Weather"];
    [weatherT setIsEnabled:false];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *weatherI  = [MenuItemFont itemFromString:[[GorillasConfig get] weather]? @"On": @"Off"
                                                target:self
                                              selector:@selector(weather:)];
    
    
    // Effects.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *effectsT  = [MenuItemFont itemFromString:@"Special Effects"];
    [effectsT setIsEnabled:false];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *effectsI  = [MenuItemFont itemFromString:[[GorillasConfig get] effects]? @"On": @"Off"
                                                target:self
                                              selector:@selector(effects:)];
    
    menu = [[Menu menuWithItems:audioT, audioI, weatherT, weatherI, effectsT, effectsI, nil] retain];
    [menu alignItemsVertically];
    [self add:menu];

    
    // Back.
    MenuItem *back     = [MenuItemFont itemFromString:@"<"
                                                target: self
                                              selector: @selector(back:)];
    
    backMenu = [[Menu menuWithItems:back, nil] retain];
    [backMenu setPosition:cpv([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [backMenu alignItemsHorizontally];
    [self add:backMenu];
}


-(void) onEnter {
    
    [self reset];
    
    [super onEnter];
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


-(void) weather: (id) sender {
    
    [[GorillasConfig get] setWeather:![[GorillasConfig get] weather]];
}


-(void) effects: (id) sender {
    
    [[GorillasConfig get] setEffects:![[GorillasConfig get] effects]];
}


-(void) back: (id) sender {
    
    [[GorillasAppDelegate get] showConfiguration];
}


-(void) dealloc {
    
    [menu release];
    menu = nil;
    
    [backMenu release];
    backMenu = nil;
    
    [super dealloc];
}


@end
