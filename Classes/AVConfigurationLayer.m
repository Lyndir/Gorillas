/*
 * This file is part of Gorillas.
 *
 *  Gorillas is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
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
#import "Utility.h"


@implementation AVConfigurationLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    // Audio Track.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *audioT    = [MenuItemFont itemFromString:NSLocalizedString(@"entries.choose.track", @"Audio Track")];
    [audioT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    audioI    = [MenuItemToggle itemWithTarget:self selector:@selector(audioTrack:)];
    NSMutableArray *trackMenuItems = [NSMutableArray arrayWithCapacity:[[GorillasConfig get].trackNames count]];
    for (NSString *trackName in [GorillasConfig get].trackNames)
        [trackMenuItems addObject:[MenuItemFont itemFromString:trackName]];
    audioI.subItems = trackMenuItems;
    [audioI setSelectedIndex:1];

    
    // Sound Effects.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *soundFxT  = [MenuItemFont itemFromString:NSLocalizedString(@"entries.choose.fx.sound", @"Sound Effects")];
    [soundFxT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    soundFxI = [MenuItemToggle itemWithTarget:self selector:@selector(soundFx:) items:
                [MenuItemFont itemFromString:NSLocalizedString(@"entries.off", @"Off")],
                [MenuItemFont itemFromString:NSLocalizedString(@"entries.on", @"On")],
                nil];
    
    // Voice.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *voiceT = [MenuItemFont itemFromString:NSLocalizedString(@"entries.choose.fx.voice", @"Voice Effects")];
    [voiceT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    voiceI = [MenuItemToggle itemWithTarget:self selector:@selector(voice:) items:
              [MenuItemFont itemFromString:NSLocalizedString(@"entries.off", @"Off")],
              [MenuItemFont itemFromString:NSLocalizedString(@"entries.on", @"On")],
              nil];
    
    
    // Visual Effects.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *visualFxT  = [MenuItemFont itemFromString:NSLocalizedString(@"entries.choose.fx.visual", @"Visual Effects")];
    [visualFxT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    visualFxI = [MenuItemToggle itemWithTarget:self selector:@selector(visualFx:) items:
                 [MenuItemFont itemFromString:NSLocalizedString(@"entries.off", @"Off")],
                 [MenuItemFont itemFromString:NSLocalizedString(@"entries.on", @"On")],
                 nil];
    
    
    // Vibration.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *vibrationT  = [MenuItemFont itemFromString:NSLocalizedString(@"entries.choose.fx.vibration", @"Vibration")];
    [vibrationT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    vibrationI = [MenuItemToggle itemWithTarget:self selector:@selector(vibration:) items:
                  [MenuItemFont itemFromString:NSLocalizedString(@"entries.off", @"Off")],
                  [MenuItemFont itemFromString:NSLocalizedString(@"entries.on", @"On")],
                  nil];
    
    
    menu = [[Menu menuWithItems:audioT, audioI, soundFxT, voiceT, soundFxI, voiceI, visualFxT, vibrationT, visualFxI, vibrationI, nil] retain];
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
    [backMenu setPosition:ccp([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [backMenu alignItemsHorizontally];
    [self addChild:backMenu];
    
    return self;
}


-(void) reset {

    [audioI setSelectedIndex:[[GorillasConfig get].trackNames indexOfObject:[GorillasConfig get].currentTrackName]];
    [soundFxI setSelectedIndex:[GorillasConfig get].soundFx? 1: 0];
    [voiceI setSelectedIndex:[GorillasConfig get].voice? 1: 0];
    [visualFxI setSelectedIndex:[GorillasConfig get].visualFx? 1: 0];
    [vibrationI setSelectedIndex:([GorillasConfig get].vibration && IsIPhone())? 1: 0];

    vibrationI.isEnabled = IsIPhone();
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
    [GorillasConfig get].vibration = ![GorillasConfig get].vibration;
    if([GorillasConfig get].vibration)
        [GorillasAudioController vibrate];
}


-(void) visualFx: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasConfig get] setVisualFx:![[GorillasConfig get] visualFx]];
}


-(void) voice: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasConfig get] setVoice:![[GorillasConfig get] voice]];
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
