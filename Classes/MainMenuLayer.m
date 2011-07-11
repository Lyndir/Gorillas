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
//  MainMenuLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 28/02/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "MainMenuLayer.h"
#import "GorillasAppDelegate.h"
#import "MenuItemSpacer.h"
#import "MenuItemTitle.h"


@interface MainMenuLayer ()

- (void)startSingle:(id)sender;
- (void)startMulti:(id)sender;
- (void)startHotSeat:(id)sender;
- (void)gameConfiguration:(id)sender;
- (void)settings:(id)sender;
- (void)scores:(id)sender;
- (void)moreGames:(id)sender;
- (void)back:(id)selector;

@end

@implementation MainMenuLayer
@synthesize playersToInvite = _playersToInvite;

- (id) init {
    
    if (!(self = [super initWithDelegate:self logo:nil items:
                  [MenuItemSpacer spacerSmall],
                  [multiPlayerI     = [MenuItemBlock itemWithSize:100 target:self selector:@selector(startMulti:)] retain],
                  [singlePlayerI    = [MenuItemBlock itemWithSize:100 target:self selector:@selector(startSingle:)] retain],
                  [hotSeatI         = [MenuItemBlock itemWithSize:100 target:self selector:@selector(startHotSeat:)] retain],
                  [configurationI   = [CCMenuItemToggle itemWithTarget:self selector:@selector(gameConfiguration:)] retain],
                  [descriptionT     = [MenuItemTitle itemFromString:@"description"] retain],
                  [MenuItemSpacer spacerSmall],
                  [MenuItemBlock itemWithSize:50 target:self selector:@selector(settings:)],
                  [MenuItemBlock itemWithSize:50 target:self selector:@selector(scores:)],
                  [MenuItemBlock itemWithSize:50 target:self selector:@selector(moreGames:)],
                  nil]))
        return self;
    
    self.itemCounts = [NSArray arrayWithObjects:
                       [NSNumber numberWithInt:1],
                       [NSNumber numberWithInt:3],
                       [NSNumber numberWithInt:1],
                       [NSNumber numberWithInt:1],
                       [NSNumber numberWithInt:1],
                       [NSNumber numberWithInt:3], nil];
    self.layout = MenuLayoutCustomColumns;
    
    self.background = [CCSprite spriteWithFile:@"menu-main.png"];
    
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


-(void) startSingle: (id) sender {
    
    NSUInteger gameConfigurationIndex = [[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue];
    GameConfiguration *gameConfiguration = [[GorillasConfig get].gameConfigurations objectAtIndex:gameConfigurationIndex];
    
    [[GorillasAppDelegate get].gameLayer configureGameWithMode:gameConfiguration.mode randomCity:NO
                                                     playerIDs:nil localHumans:1 ais:gameConfiguration.singleplayerAICount];
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


-(void) startHotSeat: (id) sender {
    
    NSUInteger gameConfigurationIndex = [[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue];
    GameConfiguration *gameConfiguration = [[GorillasConfig get].gameConfigurations objectAtIndex:gameConfigurationIndex];
    
    [[GorillasAppDelegate get].gameLayer configureGameWithMode:gameConfiguration.mode randomCity:NO
                                                     playerIDs:nil localHumans:2 ais:gameConfiguration.singleplayerAICount];
    [[GorillasAppDelegate get].gameLayer startGame];
}


- (void)gameConfiguration:(id)sender {
    
    [GorillasConfig get].activeGameConfigurationIndex = [NSNumber numberWithUnsignedInt:
                                                         ([[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue] + 1)
                                                         % [[GorillasConfig get].gameConfigurations count]];
}


- (void)settings:(id)sender {
    
    [[GorillasAppDelegate get] showConfiguration];
}


- (void)scores:(id)sender {
    
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil) {
        leaderboardController.leaderboardDelegate = self;
        [[[UIApplication sharedApplication] keyWindow].rootViewController presentModalViewController:leaderboardController animated:YES];
        [leaderboardController release];
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    
    [[[UIApplication sharedApplication] keyWindow].rootViewController dismissModalViewControllerAnimated:YES];
}


- (void)moreGames:(id)sender {

    [[GorillasAppDelegate get] moreGames];
}


- (void)back:(id) sender {
    
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
