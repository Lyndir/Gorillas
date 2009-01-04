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
    
    BOOL readd = false;
    
    if(menu) {
        readd = [menu parent] != nil;
        
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
    
    menu = [[Menu menuWithItems:audioT, audioI, nil] retain];
    [menu alignItemsVertically];

    
    // Back.
    MenuItem *back     = [MenuItemFont itemFromString:@"<"
                                                target: self
                                              selector: @selector(back:)];
    
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
