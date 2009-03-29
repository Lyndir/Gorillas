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
        [self removeChild:menu cleanup:YES];
        [menu release];
        menu = nil;
        
        [self removeChild:backMenu cleanup:YES];
        [backMenu release];
        backMenu = nil;
    }
    
    
    // Audio Track.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *audioT    = [MenuItemFont itemFromString:@"Audio Track"];
    [audioT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *audioI    = [MenuItemFont itemFromString:[[GorillasConfig get] currentTrackName]
                                                target:self
                                              selector:@selector(audioTrack:)];
    
    
    // Sound Effects.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *soundFxT  = [MenuItemFont itemFromString:@"Sound Effects"];
    [soundFxT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *soundFxI  = [MenuItemFont itemFromString:[[GorillasConfig get] soundFx]? @"On": @"Off"
                                                target:self
                                              selector:@selector(soundFx:)];
    
    
    // Vibration.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *vibrationT  = [MenuItemFont itemFromString:@"Vibration"];
    [vibrationT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *vibrationI  = [MenuItemFont itemFromString:[[GorillasConfig get] vibration]? @"On": @"Off"
                                                target:self
                                              selector:@selector(vibration:)];
    
    
    // Visual Effects.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *visualFxT  = [MenuItemFont itemFromString:@"Visual Effects"];
    [visualFxT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *visualFxI  = [MenuItemFont itemFromString:[[GorillasConfig get] visualFx]? @"On": @"Off"
                                                 target:self

                                               selector:@selector(visualFx:)];
    // Weather.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *weatherT  = [MenuItemFont itemFromString:@"Weather"];
    [weatherT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *weatherI  = [MenuItemFont itemFromString:[[GorillasConfig get] weather]? @"On": @"Off"
                                                target:self
                                              selector:@selector(weather:)];
    
    
    menu = [[Menu menuWithItems:audioT, audioI, soundFxT, vibrationT, soundFxI, vibrationI, visualFxT, weatherT, visualFxI, weatherI, nil] retain];
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
                                                target: self
                                              selector: @selector(back:)];
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


-(void) audioTrack: (id) sender {

    [[GorillasAudioController get] clickEffect];

    NSArray *tracks = [GorillasConfig get].tracks;
    NSString *newTrack = [tracks objectAtIndex:0];
    
    BOOL found = NO;
    for(NSString *track in tracks) {
        if(found) {
            newTrack = track;
            break;
        }
        
        if([[[GorillasConfig get] currentTrack] isEqualToString:track])
            found = YES;
    }

    if(![newTrack length])
        newTrack = nil;
    
    [[GorillasAudioController get] playTrack:newTrack];
}


-(void) soundFx: (id) sender {
    
    [[GorillasConfig get] setSoundFx:![[GorillasConfig get] soundFx]];
    [[GorillasAudioController get] clickEffect];
}


-(void) vibration: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasConfig get] setVibration:![[GorillasConfig get] vibration]];
    if([[GorillasConfig get] vibration])
        [GorillasAudioController vibrate];
}


-(void) visualFx: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasConfig get] setVisualFx:![[GorillasConfig get] visualFx]];
}


-(void) weather: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasConfig get] setWeather:![[GorillasConfig get] weather]];
}


-(void) back: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
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
