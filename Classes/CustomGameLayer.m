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
//  CustomGameLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/02/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "CustomGameLayer.h"
#import "GorillasAppDelegate.h"
#import "MenuItemSpacer.h"


@implementation CustomGameLayer


-(id) init {
    
    if (!(self = [super init]))
        return self;
    
    humans = 1;
    ais = 1;
    
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
    
    NSString *humansIString;
    switch (humans) {
        case 0:
            humansIString = NSLocalizedString(@"entries.player.count.0", @"None");
            break;
        case 1:
            humansIString = NSLocalizedString(@"entries.player.count.1", @"1 Player");
            break;
        case 2:
            humansIString = NSLocalizedString(@"entries.player.count.2", @"2 Players");
            break;
        default:
            humansIString = NSLocalizedString(@"entries.player.count.3+", @"%d Player");
            break;
    }
    NSString *aisIString;
    switch (ais) {
        case 0:
            aisIString = NSLocalizedString(@"entries.ai.count.0", @"None");
            break;
        case 1:
            aisIString = NSLocalizedString(@"entries.ai.count.1", @"1 Player");
            break;
        case 2:
            aisIString = NSLocalizedString(@"entries.ai.count.2", @"2 Players");
            break;
        default:
            aisIString = NSLocalizedString(@"entries.ai.count.3+", @"%d Player");
            break;
    }

    // Humans.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *humansT  = [MenuItemFont itemFromString:NSLocalizedString(@"entries.select.humans", @"Humans")];
    [humansT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *humansI  = [MenuItemFont itemFromString:[NSString stringWithFormat:humansIString, humans]
                                                   target:self
                                                 selector:@selector(humans:)];
    
    
    // Game Mode.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *gameModeT    = [MenuItemFont itemFromString:NSLocalizedString(@"entries.choose.mode", @"Game Mode")];
    [gameModeT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *gameModeI    = [MenuItemFont itemFromString:[[GorillasConfig get] modeString]
                                                   target:self
                                                 selector:@selector(gameMode:)];
    
    
    // Throw History.
    [MenuItemFont setFontSize:[[GorillasConfig get] smallFontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fixedFontName]];
    MenuItem *aisT  = [MenuItemFont itemFromString:NSLocalizedString(@"entries.select.ais", @"AIs")];
    [aisT setIsEnabled:NO];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *aisI  = [MenuItemFont itemFromString:[NSString stringWithFormat:aisIString, ais]
                                                     target:self
                                                   selector:@selector(ais:)];
    
    
    // Start Game.
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *startGameI  = [MenuItemFont itemFromString:NSLocalizedString(@"entries.start", @"Start!")
                                            target:self
                                          selector:@selector(startGame:)];

    // Disable start button when less than 2 gorillas chosen
    // or when multiple humans are chosen for Dynamic mode.
    [startGameI setIsEnabled:humans + ais > 1];
    if([[GorillasConfig get] mode] == GorillasModeDynamic && humans > 1)
        [startGameI setIsEnabled:NO];
    
    
    menu = [[Menu menuWithItems:
             humansT, aisT, humansI, aisI,
             gameModeT, gameModeI, [MenuItemSpacer small],
             startGameI,
             nil] retain];
    [menu alignItemsInColumns:
     [NSNumber numberWithUnsignedInteger:2],
     [NSNumber numberWithUnsignedInteger:2],
     [NSNumber numberWithUnsignedInteger:1],
     [NSNumber numberWithUnsignedInteger:1],
     [NSNumber numberWithUnsignedInteger:1],
     [NSNumber numberWithUnsignedInteger:1],
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


-(void) gameMode: (id) sender {
    
    [[GorillasAudioController get] clickEffect];

    NSArray *modes = [[GorillasConfig get] modes];
    NSUInteger curModeIndex = [modes indexOfObject:[NSNumber numberWithUnsignedInt:[[GorillasConfig get] mode]]];
    
    [GorillasConfig get].mode = [[modes objectAtIndex:(curModeIndex + 1) % [modes count]] unsignedIntegerValue];
}


-(void) humans: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    humans = (humans + 1) % 4;
    
    [self reset];
}


-(void) ais: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    ais = (ais + 1) % 4;

    [self reset];
}


-(void) startGame: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[[GorillasAppDelegate get] gameLayer] configureGameWithMode:[[GorillasConfig get] mode]
                                                          humans:humans ais:ais];
    [[[GorillasAppDelegate get] gameLayer] startGame];
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
