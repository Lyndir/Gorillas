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

@interface Director (Reveal)

-(void) startAnimation;

@end


@implementation GorillasAppDelegate

@synthesize uiLayer, gameLayer, newGameLayer, customGameLayer;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	// Init the window.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];
    [window makeKeyAndVisible];

	// Director and OpenGL Setup.
    [Director useFastDirector];
    [[Director sharedDirector] setPixelFormat:kRGBA8];
    //[[Director sharedDirector] setDisplayFPS:YES];
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[Director sharedDirector] attachInWindow:window];
	[[Director sharedDirector] setDepthTest:NO];
    
    // Random seed with timestamp.
    srandom(time(nil));
    
    // Menu items font.
    [MenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    [MenuItemFont setFontName:[GorillasConfig get].fontName];
    menuLayers = [[NSMutableArray alloc] initWithCapacity:3];

	// Build the splash scene.
    Scene *splashScene = [Scene node];
    Sprite *splash = [Splash node];
    [splashScene addChild:splash];
    
    // Build the game scene.
	gameLayer = [[GameLayer alloc] init];
    uiLayer = [[UILayer alloc] init];
    DebugLayer *debugLayer = [DebugLayer node];
    [uiLayer addChild:debugLayer z:99];
    [uiLayer addChild:gameLayer];
	
    // Start the background music.
    [[GorillasAudioController get] playTrack:[[GorillasConfig get] currentTrack]];

    // Show the splash screen, this starts the main loop in the current thread.
    [[Director sharedDirector] pushScene:splashScene];
    do {
#if ! TARGET_IPHONE_SIMULATOR
        @try {
#endif
            [[Director sharedDirector] startAnimation];
#if ! TARGET_IPHONE_SIMULATOR
        }
        @catch (NSException * e) {
            NSLog(@"=== Exception Occurred! ===");
            NSLog(@"Name: %@; Reason: %@; Context: %@.\n", [e name], [e reason], [e userInfo]);
            [hudLayer message:[e reason] duration:5 isImportant:YES];
        }
#endif
    } while ([[Director sharedDirector] runningScene]);
}


-(void) revealHud {
    
    if(hudLayer) {
        if(![hudLayer dismissed])
            // Already showing and not dismissed.
            return;
    
        if([hudLayer parent])
            // Already showing and being dismissed.
            [uiLayer removeChild:hudLayer cleanup:YES];
    }

    [uiLayer addChild:[self hudLayer]];
}


-(void) hideHud {
    
    [hudLayer dismiss];
}


-(HUDLayer *) hudLayer {
    
    if(!hudLayer)
        hudLayer = [[HUDLayer alloc] init];
    
    return hudLayer;
}


-(void) updateConfig {

    [configLayer reset];
    [gameConfigLayer reset];
    [avConfigLayer reset];
}


-(void) popLayer {

    [(ShadeLayer *) [menuLayers lastObject] dismissAsPush:NO];
    [menuLayers removeLastObject];
    if([menuLayers count])
        [uiLayer addChild:[menuLayers lastObject]];
    else
        [gameLayer.activeGorilla applyZoom];
}


-(void) popAllLayers {
    
    if(![menuLayers count])
        return;

    id last = [menuLayers lastObject];
    [menuLayers makeObjectsPerformSelector:@selector(dismissAsPush:) withObject:NO];
    [menuLayers removeAllObjects];
    [menuLayers addObject:last];

    [self popLayer];
}


-(void) pushLayer: (ShadeLayer *)layer {
    
    if(layer.parent) {
        if (![menuLayers containsObject:layer])
            // Layer is showing but shouldn't have been; probably being dismissed.
            [uiLayer removeChild:layer cleanup:YES];
        
        else {
            // Layer is already showing.
            if ([layer conformsToProtocol:@protocol(Resettable)])
                [(ShadeLayer<Resettable> *) layer reset];
        
            return;
        }
    }

    [(ShadeLayer *) [menuLayers lastObject] dismissAsPush:YES];
    [menuLayers addObject:layer];
    [uiLayer addChild:layer];

    [gameLayer.panningLayer scaleTo:0.5f];
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


-(void) applicationWillResignActive:(UIApplication *)application {
    
    [[Director sharedDirector] pause];

    if(!gameLayer.paused)
        [self showMainMenu];
}


-(void) applicationDidBecomeActive:(UIApplication *)application {

    [[Director sharedDirector] resume];
}


-(void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
	[[TextureMgr sharedTextureMgr] removeAllTextures];
    
    [self cleanup];
}


-(void) cleanup {
    
    if(hudLayer && ![hudLayer parent]) {
        [hudLayer stopAllActions];
        [hudLayer release];
        hudLayer = nil;
    }
    if(mainMenuLayer && ![mainMenuLayer parent]) {
        [mainMenuLayer stopAllActions];
        [mainMenuLayer release];
        mainMenuLayer = nil;
    }
    if(newGameLayer && ![newGameLayer parent]) {
        [newGameLayer stopAllActions];
        [newGameLayer release];
        newGameLayer = nil;
    }
    if(customGameLayer && ![customGameLayer parent]) {
        [customGameLayer stopAllActions];
        [customGameLayer release];
        customGameLayer = nil;
    }
    if(continueMenuLayer && ![continueMenuLayer parent]) {
        [continueMenuLayer stopAllActions];
        [continueMenuLayer release];
        continueMenuLayer = nil;
    }
    if(configLayer && ![configLayer parent]) {
        [configLayer stopAllActions];
        [configLayer release];
        configLayer = nil;
    }
    if(gameConfigLayer && ![gameConfigLayer parent]) {
        [gameConfigLayer stopAllActions];
        [gameConfigLayer release];
        gameConfigLayer = nil;
    }
    if(avConfigLayer && ![avConfigLayer parent]) {
        [avConfigLayer stopAllActions];
        [avConfigLayer release];
        avConfigLayer = nil;
    }
    if(modelsConfigLayer && ![modelsConfigLayer parent]) {
        [modelsConfigLayer stopAllActions];
        [modelsConfigLayer release];
        modelsConfigLayer = nil;
    }
    if(infoLayer && ![infoLayer parent]) {
        [infoLayer stopAllActions];
        [infoLayer release];
        infoLayer = nil;
    }
    if(guideLayer && ![guideLayer parent]) {
        [guideLayer stopAllActions];
        [guideLayer release];
        guideLayer = nil;
    }
    if(statsLayer && ![statsLayer parent]) {
        [statsLayer stopAllActions];
        [statsLayer release];
        statsLayer = nil;
    }
    if(fullLayer && ![fullLayer parent]) {
        [fullLayer stopAllActions];
        [fullLayer release];
        fullLayer = nil;
    }
    
    [[GorillasAudioController get] playTrack:nil];
}


- (void)dealloc {
    
    [gameLayer release];
    gameLayer = nil;
    
    [uiLayer release];
    uiLayer = nil;
    
    [menuLayers release];
    menuLayers = nil;
    
    [mainMenuLayer release];
    mainMenuLayer = nil;
    
    [newGameLayer release];
    newGameLayer = nil;
    
    [customGameLayer release];
    customGameLayer = nil;
    
    [continueMenuLayer release];
    continueMenuLayer = nil;
    
    [configLayer release];
    configLayer = nil;

    [gameConfigLayer release];
    gameConfigLayer = nil;

    [avConfigLayer release];
    avConfigLayer = nil;

    [modelsConfigLayer release];
    modelsConfigLayer = nil;
    
    [infoLayer release];
    infoLayer = nil;

    [guideLayer release];
    guideLayer = nil;

    [statsLayer release];
    statsLayer = nil;
    
    [fullLayer release];
    fullLayer = nil;
    
    [hudLayer release];
    hudLayer = nil;
    
    [window release];
    window = nil;
    
    [super dealloc];
}


+(GorillasAppDelegate *) get {
    
    return (GorillasAppDelegate *) [[UIApplication sharedApplication] delegate];
}


@end
