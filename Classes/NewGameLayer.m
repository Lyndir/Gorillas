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
@synthesize playersToInvite = _playersToInvite;

- (id) init {
    
    if (!(self = [super initWithDelegate:self logo:nil items:
                  [MenuItemTitle itemFromString:l(@"menu.choose.style")],
                  configurationI    = [[CCMenuItemToggle alloc] initWithTarget:self selector:@selector(gameConfiguration:)],
                  descriptionT      = [MenuItemTitle itemFromString:@"description"],
                  [MenuItemSpacer spacerNormal],
                  singlePlayerI    = [[CCMenuItemFont alloc] initFromString:NSLocalizedString(@"menu.player.single", @"Single Player")
                                                                     target:self
                                                                   selector:@selector(startSingle:)],
                  multiPlayerI    = [[CCMenuItemFont alloc] initFromString:NSLocalizedString(@"menu.player.multi", @"Multi Player")
                                                                    target:self
                                                                  selector:@selector(startMulti:)],
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
    singlePlayerI.isEnabled = gameConfiguration.singleplayerAICount;
    multiPlayerI.isEnabled = gameConfiguration.multiplayerHumanCount && [GKLocalPlayer localPlayer].authenticated;
}


-(void) onEnter {
    
    [self reset];
    
    [super onEnter];
}


-(void) gameConfiguration:(id) sender {
    
    [GorillasConfig get].activeGameConfigurationIndex = [NSNumber numberWithUnsignedInt:
                                                         ([[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue] + 1)
                                                         % [[GorillasConfig get].gameConfigurations count]];
}


-(void) startSingle: (id) sender {
    
    NSUInteger gameConfigurationIndex = [[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue];
    GameConfiguration *gameConfiguration = [[GorillasConfig get].gameConfigurations objectAtIndex:gameConfigurationIndex];
    
    [[GorillasAppDelegate get].gameLayer configureGameWithMode:gameConfiguration.mode randomCity:NO
                                                     playerIDs:nil ais:gameConfiguration.singleplayerAICount];
    [[GorillasAppDelegate get].gameLayer startGame];
}


-(void) startMulti: (id) sender {
    
    NSUInteger gameConfigurationIndex = [[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue];
    GameConfiguration *gameConfiguration = [[GorillasConfig get].gameConfigurations objectAtIndex:gameConfigurationIndex];
    
    if (!gameConfiguration.multiplayerHumanCount || ![GKLocalPlayer localPlayer].authenticated)
        // Multiplayer is not supported or game center is unavailable.
        return;
    
    GKMatchRequest *matchRequest = [[GKMatchRequest new] autorelease];
    matchRequest.minPlayers = 2;
    matchRequest.maxPlayers = gameConfiguration.multiplayerHumanCount;
    matchRequest.playerGroup = gameConfiguration.mode;
    matchRequest.playersToInvite = self.playersToInvite;
    
    [[GorillasAppDelegate get].netController beginRequest:matchRequest];
}

-(void) custom: (id) sender {
    
    [[GorillasAppDelegate get] showCustomGame];
}


-(void) back: (id) sender {
    
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
