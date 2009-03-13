/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  GorillasAppDelegate.h
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//

#import "GameLayer.h"
#import "MainMenuLayer.h"
#import "NewGameLayer.h"
#import "CustomGameLayer.h"
#import "ContinueMenuLayer.h"
#import "ConfigurationSectionLayer.h"
#import "GameConfigurationLayer.h"
#import "AVConfigurationLayer.h"
#import "InformationLayer.h"
#import "GuideLayer.h"
#import "StatisticsLayer.h"
#import "HUDLayer.h"
#import "AudioController.h"
#import "AudioControllerDelegate.h"
#import "UILayer.h"


@interface GorillasAppDelegate : NSObject <UIApplicationDelegate, AudioControllerDelegate> {
    
    UIWindow                    *window;
    
    UILayer                     *uiLayer;
    GameLayer                   *gameLayer;
    ContinueMenuLayer           *continueMenuLayer;
    MainMenuLayer               *mainMenuLayer;
    NewGameLayer                *newGameLayer;
    CustomGameLayer             *customGameLayer;
    ConfigurationSectionLayer   *configLayer;
    GameConfigurationLayer      *gameConfigLayer;
    AVConfigurationLayer        *avConfigLayer;
    InformationLayer            *infoLayer;
    GuideLayer                  *guideLayer;
    StatisticsLayer             *statsLayer;
    HUDLayer                    *hudLayer;
    AudioController             *audioController;
    NSString                    *nextTrack;
    
    NSMutableArray              *menuLayers;
}

@property (nonatomic, readonly) UILayer                    *uiLayer;
@property (nonatomic, readonly) NewGameLayer               *newGameLayer;
@property (nonatomic, readonly) CustomGameLayer            *customGameLayer;
@property (nonatomic, readonly) GameLayer                  *gameLayer;
@property (nonatomic, readonly) HUDLayer                   *hudLayer;

-(void) updateConfig;
-(void) clickEffect;
-(void) popAllLayers;
-(void) popLayer;
-(void) cleanup;

-(void) showMainMenu;
-(void) showNewGame;
-(void) showCustomGame;
-(void) showContinueMenu;
-(void) showConfiguration;
-(void) showGameConfiguration;
-(void) showAVConfiguration;
-(void) showInformation;
-(void) showGuide;
-(void) showStatistics;
-(void) revealHud;
-(void) hideHud;

-(void) playTrack:(NSString *)track;
-(void) startNextTrack;

+(GorillasAppDelegate *) get;


@end

