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
//  GorillasAppDelegate.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//

#import "GorillasAppDelegate.h"
#import "Splash.h"
#import "Resettable.h"
#import "DebugLayer.h"
#import "ccMacros.h"

@interface CCDirector (Reveal)

-(void) startAnimation;

@end

@interface GorillasAppDelegate ()

@property (nonatomic, readwrite, retain) GameLayer                     *gameLayer;
@property (nonatomic, readwrite, retain) MainMenuLayer                 *mainMenuLayer;
@property (nonatomic, readwrite, retain) NewGameLayer                  *newGameLayer;
@property (nonatomic, readwrite, retain) CustomGameLayer               *customGameLayer;
@property (nonatomic, readwrite, retain) ContinueMenuLayer             *continueMenuLayer;
@property (nonatomic, readwrite, retain) ConfigurationSectionLayer     *configLayer;
@property (nonatomic, readwrite, retain) GameConfigurationLayer        *gameConfigLayer;
@property (nonatomic, readwrite, retain) AVConfigurationLayer          *avConfigLayer;
@property (nonatomic, readwrite, retain) ModelsConfigurationLayer      *modelsConfigLayer;
@property (nonatomic, readwrite, retain) InformationLayer              *infoLayer;
@property (nonatomic, readwrite, retain) GuideLayer                    *guideLayer;
@property (nonatomic, readwrite, retain) StatisticsLayer               *statsLayer;
@property (nonatomic, readwrite, retain) FullGameLayer                 *fullLayer;

@end

@implementation GorillasAppDelegate

@synthesize gameLayer, mainMenuLayer, newGameLayer, customGameLayer, continueMenuLayer;
@synthesize configLayer, gameConfigLayer, avConfigLayer, modelsConfigLayer;
@synthesize infoLayer, guideLayer, statsLayer, fullLayer;

+ (void)initialize {
    
    [GorillasConfig get];
}

- (void)setup {
    
	// Build the splash scene.
    CCScene *splashScene = [CCScene node];
    CCSprite *splash = [Splash node];
    [splashScene addChild:splash];
    
    // Build the game scene.
	gameLayer = [[GameLayer alloc] init];
    [self.uiLayer addChild:gameLayer];
	
    // Show the splash screen, this starts the main loop in the current thread.
    [[CCDirector sharedDirector] pushScene:splashScene];
    [self showMainMenu];
    
    do {
#if ! TARGET_IPHONE_SIMULATOR
        @try {
#endif
            [[CCDirector sharedDirector] startAnimation];
#if ! TARGET_IPHONE_SIMULATOR
        }
        @catch (NSException * e) {
            NSLog(@"=== Exception Occurred! ===");
            NSLog(@"Name: %@; Reason: %@; Context: %@.\n", [e name], [e reason], [e userInfo]);
            [self.hudLayer message:[e reason] duration:5 isImportant:YES];
        }
#endif
    } while ([[CCDirector sharedDirector] runningScene]);
}


-(GHUDLayer *) hudLayer {
    
    if(!_hudLayer)
        _hudLayer = [[GHUDLayer alloc] init];
    
    return (GHUDLayer *)super.hudLayer;
}


-(void) updateConfig {

    [configLayer reset];
    [gameConfigLayer reset];
    [avConfigLayer reset];
}

- (void)hudMenuPressed {
    
    [self showMainMenu];
}

-(void) showMainMenu {
    
    if(!mainMenuLayer)
        mainMenuLayer = [[MainMenuLayer alloc] init];

    [self pushLayer:mainMenuLayer];
}


-(void) showNewGame {
    
    if(!newGameLayer)
        newGameLayer = [[NewGameLayer alloc] init];
    
    [self pushLayer:newGameLayer];
}


-(void) showCustomGame {
    
    if(!customGameLayer)
        customGameLayer = [[CustomGameLayer alloc] init];
    
    [self pushLayer: customGameLayer];
}


-(void) showContinueMenu {
    
    if(!continueMenuLayer)
        continueMenuLayer = [[ContinueMenuLayer alloc] init];
    
    [self pushLayer:continueMenuLayer];
}


-(void) showConfiguration {
    
    if(!configLayer)
        configLayer = [[ConfigurationSectionLayer alloc] init];
    
    [self pushLayer:configLayer];
}


-(void) showGameConfiguration {
    
    if(!gameConfigLayer)
        gameConfigLayer = [[GameConfigurationLayer alloc] init];
    
    [self pushLayer:gameConfigLayer];
}


-(void) showAVConfiguration {
    
    if(!avConfigLayer)
        avConfigLayer = [[AVConfigurationLayer alloc] init];
    
    [self pushLayer:avConfigLayer];
}


-(void) showModelsConfiguration {
    
    if(!modelsConfigLayer)
        modelsConfigLayer = [[ModelsConfigurationLayer alloc] init];
    
    [self pushLayer:modelsConfigLayer];
}


-(void) showInformation {
    
    if(!infoLayer)
        infoLayer = [[InformationLayer alloc] init];
    
    [self pushLayer:infoLayer];
}


-(void) showGuide {
    
    if(!guideLayer)
        guideLayer = [[GuideLayer alloc] init];
    
    [self pushLayer:guideLayer];
}


-(void) showStatistics {

    if(!statsLayer)
        statsLayer = [[StatisticsLayer alloc] init];
    
    [self pushLayer:statsLayer];
}


-(void) showFullGame {
    
    if(!fullLayer)
        fullLayer = [[FullGameLayer alloc] init];
    
    [self pushLayer:fullLayer];
}


- (void)pushLayer: (ShadeLayer *)layer hidden:(BOOL)hidden {
    
    [gameLayer setPaused:YES];
    
    [super pushLayer:layer hidden:hidden];
}


-(void) applicationWillResignActive:(UIApplication *)application {

    [super applicationWillResignActive:application];

    if(!gameLayer.paused)
        [self showMainMenu];
}


-(void) cleanup {
    
    [super cleanup];
    
    if(mainMenuLayer && ![mainMenuLayer parent]) {
        [mainMenuLayer stopAllActions];
        self.mainMenuLayer = nil;
    }
    if(newGameLayer && ![newGameLayer parent]) {
        [newGameLayer stopAllActions];
        self.newGameLayer = nil;
    }
    if(customGameLayer && ![customGameLayer parent]) {
        [customGameLayer stopAllActions];
        self.customGameLayer = nil;
    }
    if(continueMenuLayer && ![continueMenuLayer parent]) {
        [continueMenuLayer stopAllActions];
        self.continueMenuLayer = nil;
    }
    if(configLayer && ![configLayer parent]) {
        [configLayer stopAllActions];
        self.configLayer = nil;
    }
    if(gameConfigLayer && ![gameConfigLayer parent]) {
        [gameConfigLayer stopAllActions];
        self.gameConfigLayer = nil;
    }
    if(avConfigLayer && ![avConfigLayer parent]) {
        [avConfigLayer stopAllActions];
        self.avConfigLayer = nil;
    }
    if(modelsConfigLayer && ![modelsConfigLayer parent]) {
        [modelsConfigLayer stopAllActions];
        self.modelsConfigLayer = nil;
    }
    if(infoLayer && ![infoLayer parent]) {
        [infoLayer stopAllActions];
        self.infoLayer = nil;
    }
    if(guideLayer && ![guideLayer parent]) {
        [guideLayer stopAllActions];
        self.guideLayer = nil;
    }
    if(statsLayer && ![statsLayer parent]) {
        [statsLayer stopAllActions];
        self.statsLayer = nil;
    }
    if(fullLayer && ![fullLayer parent]) {
        [fullLayer stopAllActions];
        self.fullLayer = nil;
    }
}


- (void)dealloc {
    
    self.gameLayer = nil;
    self.mainMenuLayer = nil;
    self.newGameLayer = nil;
    self.customGameLayer = nil;
    self.continueMenuLayer = nil;
    self.configLayer = nil;
    self.gameConfigLayer = nil;
    self.avConfigLayer = nil;
    self.modelsConfigLayer = nil;
    self.infoLayer = nil;
    self.guideLayer = nil;
    self.statsLayer = nil;
    self.fullLayer = nil;
    
    [super dealloc];
}


+(GorillasAppDelegate *) get {
    
    return (GorillasAppDelegate *) [[UIApplication sharedApplication] delegate];
}


@end
