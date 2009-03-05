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
//  GorillasAppDelegate.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//

#import "GorillasAppDelegate.h"
#import "Splash.h"
#import "Resettable.h"


@implementation GorillasAppDelegate

@synthesize uiLayer, gameLayer, newGameLayer, customGameLayer;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	// Init the window.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:false];
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];
    [window makeKeyAndVisible];

	// Director and OpenGL Setup.
    [Director useFastDirector];
	[[Director sharedDirector] attachInWindow:window];
	[[Director sharedDirector] setDisplayFPS:NO];
	[[Director sharedDirector] setDepthTest:false];
	[[Director sharedDirector] setLandscape:true];
	//glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    //glEnable(GL_LINE_SMOOTH);
    
    // Random seed with timestamp.
    srandom(time(nil));
    
    // Menu items font.
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    menuLayers = [[NSMutableArray alloc] initWithCapacity:3];

	// Build the splash scene.
    Scene *splashScene = [Scene node];
    Sprite *splash = [Splash node];
    [splashScene add:splash];
    
    // Build the game scene.
	gameLayer = [[GameLayer alloc] init];
    uiLayer = [[Layer alloc] init];
    [uiLayer add:gameLayer];
	
    // Start the background music.
    [self playTrack:[[GorillasConfig get] currentTrack]];

    // Show the splash screen, this starts the main loop in the current thread.
	[[Director sharedDirector] runWithScene:splashScene];
}


-(void) revealHud {
    
    if(hudLayer) {
        if(![hudLayer dismissed])
            // Already showing and not dismissed.
            return;
    
        if([hudLayer parent])
            // Already showing and being dismissed.
            [gameLayer removeAndStop:hudLayer];
    }

    [gameLayer add:[self hudLayer]];
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


-(void) clickEffect {
    
    static SystemSoundID clicky = 0;
    
    if([[GorillasConfig get] soundFx]) {
        if(clicky == 0)
            clicky = [AudioController loadEffectWithName:@"click.wav"];
        
        [AudioController playEffect:clicky];
    }
    
    else {
        [AudioController disposeEffect:clicky];
        clicky = 0;
    }
}


-(void) popLayer {

    [(ShadeLayer *) [menuLayers lastObject] dismissAsPush:NO];
    [menuLayers removeLastObject];
    if([menuLayers count])
        [uiLayer add:[menuLayers lastObject]];
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
    
    if([layer parent]) {
        if (![menuLayers containsObject:layer])
            // Layer is showing but shouldn't have been; probably being dismissed.
            [uiLayer removeAndStop:layer];
        
        else {
            // Layer is already showing.
            if ([layer conformsToProtocol:@protocol(Resettable)])
                [(ShadeLayer<Resettable> *) layer reset];
        
            return;
        }
    }

    [(ShadeLayer *) [menuLayers lastObject] dismissAsPush:YES];
    [menuLayers addObject:layer];
    [uiLayer add:layer];
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


-(void) playTrack:(NSString *)track {

    if(![track length])
        track = nil;
    
    nextTrack = track;
    [self startNextTrack];
}


-(void) audioStarted:(AudioPlayer *)player {

    NSString *track = [audioController soundFile];
    if([nextTrack isEqualToString:@"random"])
        track = nextTrack;
    
    [[GorillasConfig get] setCurrentTrack:track];
}


-(void) audioStopped:(AudioPlayer *)player {
    
    if(nextTrack == nil)
        [[GorillasConfig get] setCurrentTrack:nil];
    
    [audioController release];
    audioController = nil;
    
    [self startNextTrack];
}


-(void) startNextTrack {
    
    if(audioController) {
        if([[audioController audioPlayer] isRunning])
            [audioController stop];
        else
            [self audioStopped:[audioController audioPlayer]];
    }

    else if(nextTrack) {
        NSString *track = nextTrack;
        if([track isEqualToString:@"random"])
            track = [GorillasConfig get].randomTrack;
        
        audioController = [[AudioController alloc] initWithFile:track];
        [audioController play];
        [audioController setDelegate:self];
    }
}


-(void) applicationWillResignActive:(UIApplication *)application {
    
    [[Director sharedDirector] pause];
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
    
    [self playTrack:nil];
}


+(GorillasAppDelegate *) get {
    
    return (GorillasAppDelegate *) [[UIApplication sharedApplication] delegate];
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

    [infoLayer release];
    infoLayer = nil;

    [guideLayer release];
    guideLayer = nil;

    [statsLayer release];
    statsLayer = nil;
    
    [hudLayer release];
    hudLayer = nil;
    
    [audioController release];
    audioController = nil;
    
    [nextTrack release];
    nextTrack = nil;
    
    [window release];
    window = nil;
    
    [super dealloc];
}


@end
