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
//  GorillasAppDelegate.h
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//

#import "PearlCocos2DAppDelegate.h"
#import "GameLayer.h"
#import "MainMenuLayer.h"
#import "ConfigurationSectionLayer.h"
#import "GameConfigurationLayer.h"
#import "AVConfigurationLayer.h"
#import "GHUDLayer.h"
#import "NetController.h"

@interface GorillasAppDelegate : PearlCocos2DAppDelegate

@property(nonatomic, readonly, strong) GameLayer *gameLayer;
@property(nonatomic, readonly, strong) MainMenuLayer *mainMenuLayer;
@property(nonatomic, readonly, strong) ConfigurationSectionLayer *configLayer;
@property(nonatomic, readonly, strong) GameConfigurationLayer *gameConfigLayer;
@property(nonatomic, readonly, strong) AVConfigurationLayer *avConfigLayer;
@property(nonatomic, readonly, strong) GHUDLayer *hudLayer;
@property(nonatomic, readonly, strong) NetController *netController;

- (void)showMainMenu;
- (void)showMainMenuForPlayers:(NSArray *)aPlayersToInvite;
- (void)showConfiguration;
- (void)showGameConfiguration;
- (void)showAVConfiguration;

+ (GorillasAppDelegate *)get;

@end

