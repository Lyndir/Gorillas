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
//  NewGameLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 28/02/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "NewGameLayer.h"
#import "GorillasAppDelegate.h"
#import "MenuItemSpacer.h"
#import "MenuItemTitle.h"


@interface NewGameLayer ()

- (void)gameConfiguration:(id)sender;
- (void)startSingle:(id)sender;
- (void)startMulti:(id)sender;
- (void)custom:(id)sender;
- (void)back:(id)selector;

@end

@implementation NewGameLayer


- (id) init {
    
    if (!(self = [super initWithDelegate:self logo:nil items:
                  [MenuItemTitle itemFromString:l(@"menu.choose.style")],
                  configurationI    = [[CCMenuItemToggle alloc] initWithTarget:self selector:@selector(gameConfiguration:)],
                  descriptionT      = [MenuItemTitle itemFromString:@"description"],
                  singlePlayerI    = [[CCMenuItemFont alloc] initFromString:NSLocalizedString(@"menu.player.single", @"Single Player")
                                                                     target:self
                                                                   selector:@selector(startSingle:)],
                  multiPlayerI    = [[CCMenuItemFont alloc] initFromString:NSLocalizedString(@"menu.player.multi", @"Multi Player")
                                                                    target:self
                                                                  selector:@selector(startMulti:)],
                  [MenuItemSpacer spacerNormal],
                  [CCMenuItemFont itemFromString:NSLocalizedString(@"menu.choose.custom", @"Custom Game...")
                                                                   target:self
                                                                 selector:@selector(custom:)],
                  nil]))
        return self;
    
    // Game Configuration.
    NSMutableArray * configurationMenuItems = [NSMutableArray arrayWithCapacity:4];
    for (GameConfiguration *configuration in [GorillasConfig get].gameConfigurations)
        [configurationMenuItems addObject:[CCMenuItemFont itemFromString:configuration.name]];
    configurationI.subItems = configurationMenuItems;
    [configurationI setSelectedIndex:1];
    
    return self;
}


- (void)reset {
    
    NSUInteger gameConfigurationIndex = [[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue];
    GameConfiguration *gameConfiguration = [[GorillasConfig get].gameConfigurations objectAtIndex:gameConfigurationIndex];
    
    if ([[configurationI subItems] count] > gameConfigurationIndex)
        [configurationI setSelectedIndex:gameConfigurationIndex];
    [descriptionT setString:gameConfiguration.description];
    singlePlayerI.isEnabled = gameConfiguration.sHumans + gameConfiguration.sAis > 0;
    multiPlayerI.isEnabled = gameConfiguration.mHumans + gameConfiguration.mAis > 0;
}


-(void) onEnter {
    
    [self reset];
    
    [super onEnter];
}


-(void) gameConfiguration:(id) sender {
    
    [[GorillasAudioController get] clickEffect];
    
    [GorillasConfig get].activeGameConfigurationIndex = [NSNumber numberWithUnsignedInt:
                                                         ([[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue] + 1)
                                                         % [[GorillasConfig get].gameConfigurations count]];
}


-(void) startSingle: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    
    NSUInteger gameConfigurationIndex = [[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue];
    GameConfiguration *gameConfiguration = [[GorillasConfig get].gameConfigurations objectAtIndex:gameConfigurationIndex];

    [[[GorillasAppDelegate get] gameLayer] configureGameWithMode:gameConfiguration.mode
                                                          humans:gameConfiguration.sHumans
                                                             ais:gameConfiguration.sAis];
    [[[GorillasAppDelegate get] gameLayer] startGame];
}


-(void) startMulti: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    
    NSUInteger gameConfigurationIndex = [[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue];
    GameConfiguration *gameConfiguration = [[GorillasConfig get].gameConfigurations objectAtIndex:gameConfigurationIndex];

    [[[GorillasAppDelegate get] gameLayer] configureGameWithMode:gameConfiguration.mode
                                                          humans:gameConfiguration.mHumans
                                                             ais:gameConfiguration.mAis];
    [[[GorillasAppDelegate get] gameLayer] startGame];
}


-(void) custom: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showCustomGame];
}


-(void) back: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
