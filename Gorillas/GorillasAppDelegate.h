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
#import "BuyPlusLayer.h"
#import "ConfigurationSectionLayer.h"
#import "GameConfigurationLayer.h"
#import "AVConfigurationLayer.h"
#import "GHUDLayer.h"
#import "NetController.h"

static NSString *const GORILLAS_PLUS = @"com.lyndir.lhunath.Gorillas.plus";

@interface GorillasAppDelegate : PearlCocos2DAppDelegate {
    
@private
    GameLayer                                                       *_gameLayer;
    MainMenuLayer                                                   *_mainMenuLayer;
    BuyPlusLayer                                                    *_buyPlusLayer;
    ConfigurationSectionLayer                                       *_configLayer;
    GameConfigurationLayer                                          *_gameConfigLayer;
    AVConfigurationLayer                                            *_avConfigLayer;
    NetController                                                   *_netController;
}

@property (nonatomic, readonly, retain) GameLayer                   *gameLayer;
@property (nonatomic, readonly, retain) MainMenuLayer               *mainMenuLayer;
@property (nonatomic, readonly, retain) ConfigurationSectionLayer   *configLayer;
@property (nonatomic, readonly, retain) GameConfigurationLayer      *gameConfigLayer;
@property (nonatomic, readonly, retain) AVConfigurationLayer        *avConfigLayer;
@property (nonatomic, readonly, retain) GHUDLayer                   *hudLayer;
@property (nonatomic, readonly, retain) NetController               *netController;
@property (nonatomic, readonly, retain) NSDictionary *products;
@property (nonatomic) BOOL plusAvailable;

-(void) showMainMenu;
-(void) showMainMenuForPlayers:(NSArray *)aPlayersToInvite;
-(void) showUpgrade;
-(void) showConfiguration;
-(void) showGameConfiguration;
-(void) showAVConfiguration;

+(GorillasAppDelegate *) get;


@end

