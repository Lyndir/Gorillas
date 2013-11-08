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
#import "LLButtonView.h"

@interface MainMenuLayer()

@property(nonatomic, strong) CCMenu *appMenu;

@end

@implementation MainMenuLayer {
    CCMenuItemToggle *configurationI;
    CCMenuItemLabel *descriptionT;
    CCMenuItem *multiPlayerI, *singlePlayerI, *hotSeatI, *upgradeI;
    LLButtonView *loveButton;
}

- (id)init {

    if (!(self = [super initWithDelegate:self logo:nil items:nil]))
        return self;

    self.layout = PearlCCMenuLayoutCustomColumns;

    loveButton = [LLButtonView new];
    loveButton.alpha = 0;

    return self;
}

- (void)doLoad {

    self.background = [CCSprite spriteWithFile:@"menu-main.png"];
    self.itemCounts = @[ @1, @3, @1, @1, @1, @2 ];
    self.items = @[
            [PearlCCMenuItemSpacer spacerSmall],
            multiPlayerI = [PearlCCMenuItemBlock itemWithSize:(NSUInteger)(100.0f * [PearlDeviceUtils uiScale]) target:self
                                                     selector:@selector(startMulti:)],
            singlePlayerI = [PearlCCMenuItemBlock itemWithSize:(NSUInteger)(100.0f * [PearlDeviceUtils uiScale]) target:self
                                                      selector:@selector(startSingle:)],
            hotSeatI = [PearlCCMenuItemBlock itemWithSize:(NSUInteger)(100.0f * [PearlDeviceUtils uiScale]) target:self
                                                 selector:@selector(startHotSeat:)],
            configurationI = [CCMenuItemToggle itemWithTarget:self selector:@selector(gameConfiguration:)],
            descriptionT = [PearlCCMenuItemTitle itemWithString:@"description"],
            [PearlCCMenuItemSpacer spacerNormal],
            [PearlCCMenuItemBlock itemWithSize:(NSUInteger)(50.0f * [PearlDeviceUtils uiScale]) target:self
                                      selector:@selector(settings:)],
            [PearlCCMenuItemBlock itemWithSize:(NSUInteger)(50.0f * [PearlDeviceUtils uiScale]) target:self
                                      selector:@selector(scores:)],
    ];

    if (self.appMenu) {
        [self.appMenu removeAllChildrenWithCleanup:YES];
        self.appMenu = nil;
    }

    // Game Configuration.
    NSMutableArray *configurationMenuItems = [NSMutableArray arrayWithCapacity:4];
    for (GameConfiguration *configuration in [GorillasConfig get].gameConfigurations)
        [configurationMenuItems addObject:[CCMenuItemFont itemWithString:configuration.name]];
    configurationI.subItems = configurationMenuItems;
    [configurationI setSelectedIndex:1];

    [super doLoad];
}

- (void)reset {

    [super reset];

    NSUInteger gameConfigurationIndex = [[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue];
    if (gameConfigurationIndex >= [[GorillasConfig get].gameConfigurations count]) {
        [GorillasConfig get].activeGameConfigurationIndex = @1;
        return;
    }

    if ([GorillasAppDelegate get].gameLayer.running)
        [self setBackButtonTarget:self selector:@selector(back)];
    else
        [self setBackButtonTarget:nil selector:nil];

    if ([[configurationI subItems] count] > gameConfigurationIndex)
        [configurationI setSelectedIndex:gameConfigurationIndex];

    GameConfiguration *gameConfiguration = ([GorillasConfig get].gameConfigurations)[gameConfigurationIndex];
    [descriptionT setString:gameConfiguration.description];
    singlePlayerI.isEnabled = gameConfiguration.singleplayerAICount > 0;
    multiPlayerI.isEnabled = gameConfiguration.multiplayerHumanCount && [GKLocalPlayer localPlayer].authenticated;
    hotSeatI.isEnabled = gameConfiguration.multiplayerHumanCount > 0;
}

- (void)onEnter {

    [self reset];

    [super onEnter];

    if (self.appMenu && !self.appMenu.parent)
        [self.parent addChild:self.appMenu];

    if (!loveButton.superview)
        [[CCDirector sharedDirector].view addSubview:loveButton];
    [loveButton setFrameFromCurrentSizeAndParentPaddingTop:CGFLOAT_MAX right:CGFLOAT_MAX bottom:20 left:CGFLOAT_MAX];
    [UIView animateWithDuration:1 animations:^{
        loveButton.alpha = 1;
    }];
}

- (void)onExit {

    [super onExit];

    [self.appMenu removeFromParentAndCleanup:NO];

    [UIView animateWithDuration:1 animations:^{
        loveButton.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished)
            [loveButton removeFromSuperview];
    }];
}

- (void)startSingle:(id)sender {

    NSUInteger gameConfigurationIndex = [[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue];
    GameConfiguration *gameConfiguration = ([GorillasConfig get].gameConfigurations)[gameConfigurationIndex];

    [[GorillasAppDelegate get].gameLayer configureGameWithMode:gameConfiguration.mode randomCity:NO
                                                     playerIDs:nil localHumans:1 ais:gameConfiguration.singleplayerAICount];
    [[GorillasAppDelegate get].gameLayer startGame];
}

- (void)startMulti:(id)sender {

    NSUInteger gameConfigurationIndex = [[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue];
    GameConfiguration *gameConfiguration = ([GorillasConfig get].gameConfigurations)[gameConfigurationIndex];

    if (!gameConfiguration.multiplayerHumanCount || ![GKLocalPlayer localPlayer].authenticated)
            // Multiplayer is not supported or game center is unavailable.
        return;

    GKMatchRequest *matchRequest = [GKMatchRequest new];
    matchRequest.minPlayers = 2;
    matchRequest.maxPlayers = gameConfiguration.multiplayerHumanCount;
    matchRequest.playerGroup = gameConfiguration.mode;
    matchRequest.playersToInvite = self.playersToInvite;

    [[GorillasAppDelegate get].netController beginRequest:matchRequest];
}

- (void)startHotSeat:(id)sender {

    NSUInteger gameConfigurationIndex = [[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue];
    GameConfiguration *gameConfiguration = ([GorillasConfig get].gameConfigurations)[gameConfigurationIndex];

    [[GorillasAppDelegate get].gameLayer configureGameWithMode:gameConfiguration.mode randomCity:NO
                                                     playerIDs:nil localHumans:2 ais:gameConfiguration.multiplayerAICount];
    [[GorillasAppDelegate get].gameLayer startGame];
}

- (void)gameConfiguration:(id)sender {

    [GorillasConfig get].activeGameConfigurationIndex = @(([[GorillasConfig get].activeGameConfigurationIndex unsignedIntValue] + 1)
                                                          % [[GorillasConfig get].gameConfigurations count]);
}

- (void)upgrade:(id)sender {

    [[GorillasAppDelegate get] showUpgrade];
}

- (void)settings:(id)sender {

    [[GorillasAppDelegate get] showConfiguration];
}

- (void)scores:(id)sender {

    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil) {
        leaderboardController.leaderboardDelegate = self;
        [[[UIApplication sharedApplication] keyWindow].rootViewController presentModalViewController:leaderboardController animated:YES];
        [[CCDirector sharedDirector] pause];
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {

    [[[UIApplication sharedApplication] keyWindow].rootViewController dismissModalViewControllerAnimated:YES];
    [[CCDirector sharedDirector] resume];
}

- (void)back:(id)sender {

    [[GorillasAppDelegate get] popLayer];
}

- (void)appDeBlock:(id)sender {

    [[UIApplication sharedApplication] openURL:
            [NSURL URLWithString:@"http://itunes.apple.com/app/id325058485"]];
}

- (void)appMasterPassword:(id)sender {

    [[UIApplication sharedApplication] openURL:
            [NSURL URLWithString:@"http://itunes.apple.com/app/id510296984"]];
}

@end
