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
#import "MenuItemTitle.h"


@interface CustomGameLayer ()

- (void)gameMode:(id)sender;
- (void)ais:(id)sender;
- (void)random:(id)sender;
- (void)startGame:(id)sender;
- (void)back:(id)selector;

@end


@implementation CustomGameLayer


-(id) init {
    
    if (!(self = [super initWithDelegate:self logo:nil items:
                  [MenuItemTitle itemFromString:l(@"menu.choose.mode")],
                  gameModeI     = [[CCMenuItemToggle alloc] initWithTarget:self selector:@selector(gameMode:)],
                  [MenuItemTitle itemFromString:l(@"menu.choose.ais")],
                  aisI    = [[CCMenuItemToggle alloc] initWithTarget:self selector:@selector(ais:)],
                  [MenuItemTitle itemFromString:l(@"menu.choose.randomCity")],
                  randomI    = [[CCMenuItemToggle alloc] initWithTarget:self selector:@selector(random:)],
                  nil]))
        return self;
    
    self.layout = MenuLayoutColumns;
    ais = 1;
    randomCity = YES;
    
    // Game Mode.
    NSMutableArray *modeMenuItems = [NSMutableArray arrayWithCapacity:4];
    for (NSString *modeString in [GorillasConfig descriptionsForModes])
        [modeMenuItems addObject:[CCMenuItemFont itemFromString:modeString]];
    gameModeI.subItems = modeMenuItems;
    [gameModeI setSelectedIndex:1];
    
    // AIs.
    NSMutableArray *aiMenuItems = [NSMutableArray arrayWithCapacity:4];
    [aiMenuItems addObject:[CCMenuItemFont itemFromString:l(@"menu.ai.count.0")]];
    [aiMenuItems addObject:[CCMenuItemFont itemFromString:l(@"menu.ai.count.1")]];
    [aiMenuItems addObject:[CCMenuItemFont itemFromString:l(@"menu.ai.count.2")]];
    [aiMenuItems addObject:[CCMenuItemFont itemFromString:l(@"menu.ai.count.3+")]];
    aisI.subItems = aiMenuItems;
    [aisI setSelectedIndex:1];

    // Random City.
    NSMutableArray *randomMenuItems = [NSMutableArray arrayWithCapacity:2];
    [randomMenuItems addObject:[CCMenuItemFont itemFromString:l(@"menu.config.off")]];
    [randomMenuItems addObject:[CCMenuItemFont itemFromString:l(@"menu.config.on")]];
    randomI.subItems = randomMenuItems;
    [randomI setSelectedIndex:1];
    
    [self setNextButton:[[CCMenuItemFont alloc] initFromString:l(@"menu.start")
                                                        target:self
                                                      selector:@selector(startGame:)]];
    
    return self;
}


- (void)reset {
    
    NSUInteger aiIndex = (NSUInteger)fminf(ais, 3);
    if ([[aisI subItems] count] > aiIndex) {
        [aisI setSelectedIndex:aiIndex];
        if (ais >= 3)
            [(CCMenuItemFont*)[aisI selectedItem] setString:[NSString stringWithFormat:
                                                             NSLocalizedString(@"menu.ai.count.3+", @"%d AIs"), ais]];
    }
    [gameModeI setSelectedIndex:[[GorillasConfig get].mode unsignedIntValue]];
    
    NSUInteger randomIndex = randomCity? 1: 0;
    if ([[randomI subItems] count] > randomIndex)
        [randomI setSelectedIndex:randomIndex];
}


-(void) onEnter {
    
    [self reset];
    
    [super onEnter];
}


-(void) gameMode: (id) sender {
    
    [GorillasConfig get].mode = [NSNumber numberWithUnsignedInt:([[GorillasConfig get].mode unsignedIntValue] + 1) % GorillasModeCount];
}


-(void) ais: (id) sender {
    
    ais = (ais + 1) % 4;
    
    [self reset];
}


-(void) random: (id) sender {
    
    randomCity = !randomCity;
    
    [self reset];
}


-(void) startGame: (id) sender {
    
    [[[GorillasAppDelegate get] gameLayer] configureGameWithMode:[[GorillasConfig get].mode unsignedIntValue] randomCity:randomCity
                                                       playerIDs:nil ais:ais];
    [[[GorillasAppDelegate get] gameLayer] startGame];
}


-(void) back: (id) sender {
    
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
