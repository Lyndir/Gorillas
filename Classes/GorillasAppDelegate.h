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

