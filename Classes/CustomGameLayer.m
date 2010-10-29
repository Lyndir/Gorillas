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


@interface CustomGameLayer ()

- (void)humans:(id)sender;
- (void)gameMode:(id)sender;
- (void)ais:(id)sender;
- (void)startGame:(id)sender;
- (void)back:(id)selector;

@end


@implementation CustomGameLayer


-(id) init {
    
    if (!(self = [super init]))
        return self;
    
    humans = 1;
    ais = 1;
    
    // Humans.
    [CCMenuItemFont setFontSize:[[GorillasConfig get].smallFontSize intValue]];
    [CCMenuItemFont setFontName:[GorillasConfig get].fixedFontName];
    CCMenuItem *humansT  = [CCMenuItemFont itemFromString:NSLocalizedString(@"entries.select.humans", @"Humans")];
    [humansT setIsEnabled:NO];
    [CCMenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    [CCMenuItemFont setFontName:[GorillasConfig get].fontName];
    humansI    = [[CCMenuItemToggle alloc] initWithTarget:self selector:@selector(humans:)];
    NSMutableArray *humanMenuItems = [NSMutableArray arrayWithCapacity:4];
    [humanMenuItems addObject:[CCMenuItemFont itemFromString:NSLocalizedString(@"entries.player.count.0", @"None")]];
    [humanMenuItems addObject:[CCMenuItemFont itemFromString:NSLocalizedString(@"entries.player.count.1", @"1 Player")]];
    [humanMenuItems addObject:[CCMenuItemFont itemFromString:NSLocalizedString(@"entries.player.count.2", @"2 Players")]];
    [humanMenuItems addObject:[CCMenuItemFont itemFromString:NSLocalizedString(@"entries.player.count.3+", @"%d Players")]];
    humansI.subItems = humanMenuItems;
    [humansI setSelectedIndex:1];
    
    
    // Game Mode.
    [CCMenuItemFont setFontSize:[[GorillasConfig get].smallFontSize intValue]];
    [CCMenuItemFont setFontName:[GorillasConfig get].fixedFontName];
    CCMenuItem *gameModeT    = [CCMenuItemFont itemFromString:NSLocalizedString(@"entries.choose.mode", @"Game Mode")];
    [gameModeT setIsEnabled:NO];
    [CCMenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    [CCMenuItemFont setFontName:[GorillasConfig get].fontName];
    gameModeI    = [[CCMenuItemToggle alloc] initWithTarget:self selector:@selector(gameMode:)];
    NSMutableArray *modeMenuItems = [NSMutableArray arrayWithCapacity:4];
    for (NSString *modeString in [[GorillasConfig get].modeStrings allValues])
        [modeMenuItems addObject:[CCMenuItemFont itemFromString:modeString]];
    gameModeI.subItems = modeMenuItems;
    [gameModeI setSelectedIndex:1];
    
    
    // AIs.
    [CCMenuItemFont setFontSize:[[GorillasConfig get].smallFontSize intValue]];
    [CCMenuItemFont setFontName:[GorillasConfig get].fixedFontName];
    CCMenuItem *aisT  = [CCMenuItemFont itemFromString:NSLocalizedString(@"entries.select.ais", @"AIs")];
    [aisT setIsEnabled:NO];
    [CCMenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    [CCMenuItemFont setFontName:[GorillasConfig get].fontName];
    aisI    = [[CCMenuItemToggle alloc] initWithTarget:self selector:@selector(ais:)];
    NSMutableArray *aiMenuItems = [NSMutableArray arrayWithCapacity:4];
    [aiMenuItems addObject:[CCMenuItemFont itemFromString:NSLocalizedString(@"entries.ai.count.0", @"None")]];
    [aiMenuItems addObject:[CCMenuItemFont itemFromString:NSLocalizedString(@"entries.ai.count.1", @"1 AI")]];
    [aiMenuItems addObject:[CCMenuItemFont itemFromString:NSLocalizedString(@"entries.ai.count.2", @"2 AIs")]];
    [aiMenuItems addObject:[CCMenuItemFont itemFromString:NSLocalizedString(@"entries.ai.count.3+", @"%d AIs")]];
    aisI.subItems = aiMenuItems;
    [aisI setSelectedIndex:1];
    
    
    // Start Game.
    [CCMenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    [CCMenuItemFont setFontName:[GorillasConfig get].fontName];
    startGameI  = [[CCMenuItemFont alloc] initFromString:NSLocalizedString(@"entries.start", @"Start!")
                                                target:self
                                              selector:@selector(startGame:)];

    
    CCMenu *menu = [CCMenu menuWithItems:
                  humansT, aisT, humansI, aisI,
                  gameModeT, gameModeI, [MenuItemSpacer small],
                  startGameI,
                  nil];
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
    [CCMenuItemFont setFontSize:[[GorillasConfig get].largeFontSize intValue]];
    CCMenuItem *back     = [CCMenuItemFont itemFromString:@"   <   "
                                               target: self
                                             selector: @selector(back:)];
    [CCMenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    
    CCMenu *backMenu = [CCMenu menuWithItems:back, nil];
    [backMenu setPosition:ccp([[GorillasConfig get].fontSize intValue], [[GorillasConfig get].fontSize intValue])];
    [backMenu alignItemsHorizontally];
    [self addChild:backMenu];

    return self;
}


- (void)reset {

    [humansI setSelectedIndex:(NSUInteger)fminf(humans, 3)];
    if (humans >= 3)
        [(CCMenuItemFont*)[humansI selectedItem] setString:[NSString stringWithFormat:
                                                          NSLocalizedString(@"entries.player.count.3+", @"%d Players"), humans]];
    [aisI setSelectedIndex:(NSUInteger)fminf(ais, 3)];
    if (ais >= 3)
        [(CCMenuItemFont*)[aisI selectedItem] setString:[NSString stringWithFormat:
                                                       NSLocalizedString(@"entries.ai.count.3+", @"%d AIs"), ais]];
    NSArray *modeKeys = [[GorillasConfig get].modeStrings allKeys];
    [gameModeI setSelectedIndex:[modeKeys indexOfObject:[GorillasConfig get].mode]];
    
    // Disable start button when less than 2 gorillas chosen
    // or when multiple humans are chosen for Dynamic mode.
    startGameI.isEnabled        = humans + ais > 1;
    if([[GorillasConfig get].mode unsignedIntValue] == GorillasModeDynamic && humans > 1)
        startGameI.isEnabled    = NO;
}


-(void) onEnter {
    
    [self reset];
    
    [super onEnter];
}


-(void) gameMode: (id) sender {
    
    [[GorillasAudioController get] clickEffect];

    NSArray *modes = [GorillasConfig get].modes;
    NSUInteger curModeIndex = [modes indexOfObject:[GorillasConfig get].mode];
    
    [GorillasConfig get].mode = [modes objectAtIndex:(curModeIndex + 1) % [modes count]];
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
    [[[GorillasAppDelegate get] gameLayer] configureGameWithMode:[[GorillasConfig get].mode unsignedIntValue]
                                                          humans:humans ais:ais];
    [[[GorillasAppDelegate get] gameLayer] startGame];
}


-(void) back: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {

    [super dealloc];
}


@end
