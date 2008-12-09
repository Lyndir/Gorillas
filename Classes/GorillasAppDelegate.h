/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
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
//  Copyright Lin.k 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameLayer.h"
#import "MainMenuLayer.h"
#import "StatisticsLayer.h"
#import "ConfigurationLayer.h"
#import "HUDLayer.h"
#import "AudioController.h"

@interface GorillasAppDelegate : NSObject <UIApplicationDelegate> {
    
    @private
    GameLayer *gameLayer;
    ShadeLayer *currentLayer;
    MainMenuLayer *mainMenuLayer;
    StatisticsLayer *statsLayer;
    ConfigurationLayer *configLayer;
    HUDLayer *hudLayer;
    AudioController *audioController;
}

@property (readonly) GameLayer *gameLayer;
@property (readonly) MainMenuLayer *mainMenuLayer;
@property (readonly) StatisticsLayer *statsLayer;
@property (readonly) ConfigurationLayer *configLayer;
@property (readonly) HUDLayer *hudLayer;

-(void) dismissLayer;

-(void) showMainMenu;
-(void) showStatistics;
-(void) showConfiguration;
-(void) revealHud;
-(void) hideHud;

+(GorillasAppDelegate *) get;


@end

