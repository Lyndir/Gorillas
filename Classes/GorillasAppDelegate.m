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
//  GorillasAppDelegate.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//

#import "GorillasAppDelegate.h"
#import "Splash.h"


@implementation GorillasAppDelegate

@synthesize gameLayer;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:false];
    
    // Start the background music.
    [self playTrack:[[GorillasConfig get] currentTrack]];

    // Random seed with timestamp.
    srandom(time(nil));
    
    // Menu items font.
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];

	// Director and OpenGL Setup.
    [Director setPixelFormat:RGBA8];
	[[Director sharedDirector] setDisplayFPS:false];
	[[Director sharedDirector] setDepthTest:false];
	[[Director sharedDirector] setLandscape:true];
	//glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    //glEnable(GL_LINE_SMOOTH);

	// Build the splash scene.
    Scene *splashScene = [[Scene alloc] init];
    Sprite *splash = [[Splash alloc] init];
    [splashScene add:splash];

    // Show the splash screen.
	[[Director sharedDirector] runScene:splashScene];
    [splashScene release];
    [splash release];
    
    // Build the game scene.
	gameLayer = [[GameLayer alloc] init];
}


-(void) exit {
    
    [gameLayer removeAndStopAll];
    [gameLayer release];
    gameLayer = nil;
    
    [self cleanup];
    [[GorillasConfig get] release];
    
    [[Director sharedDirector] stopScene];
    /*[[Director sharedDirector] popScene];
    [[Director sharedDirector] release];*/
}


-(void) revealHud {
    
    if([hudLayer parent])
        [gameLayer removeAndStop:hudLayer];
    
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

    [gameConfigLayer reset];
    [avConfigLayer reset];
}


-(void) dismissLayer {
    
    [currentLayer dismiss];
    [currentLayer release];
    currentLayer = nil;
}


-(void) showLayer: (ShadeLayer *)layer {
    
    if([currentLayer parent])
        [self dismissLayer];
    
    currentLayer = [layer retain];
    [gameLayer add:currentLayer];
}


-(void) showMainMenu {
    
    if(!mainMenuLayer)
        mainMenuLayer = [[MainMenuLayer alloc] init];
    
    [self showLayer:mainMenuLayer];
}


-(void) showContinueMenu {
    
    if(!continueMenuLayer)
        continueMenuLayer = [[ContinueMenuLayer alloc] init];
    
    [self showLayer:continueMenuLayer];
}


-(void) showConfiguration {
    
    if(!configLayer)
        configLayer = [[ConfigurationSectionLayer alloc] init];
    
    [self showLayer:configLayer];
}


-(void) showGameConfiguration {
    
    if(!gameConfigLayer)
        gameConfigLayer = [[GameConfigurationLayer alloc] init];
    
    [self showLayer:gameConfigLayer];
}


-(void) showAVConfiguration {
    
    if(!avConfigLayer)
        avConfigLayer = [[AVConfigurationLayer alloc] init];
    
    [self showLayer:avConfigLayer];
}


-(void) showInformation {
    
    if(!infoLayer)
        infoLayer = [[InformationLayer alloc] init];
    
    [self showLayer:infoLayer];
}


-(void) showGuide {
    
    if(!guideLayer)
        guideLayer = [[GuideLayer alloc] init];
    
    [self showLayer:guideLayer];
}


-(void) showStatistics {

    if(!statsLayer)
        statsLayer = [[StatisticsLayer alloc] init];
    
    [self showLayer:statsLayer];
}


-(void) playTrack:(NSString *)track {

    if(![track length])
        track = nil;
    nextTrack = track;

    [self startNextTrack];
}


-(void) audioStarted:(AudioPlayer *)player {
    
    [[GorillasConfig get] setCurrentTrack:[audioController soundFile]];
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
        audioController = [[AudioController alloc] initWithFile:nextTrack];
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
    if(currentLayer && ![currentLayer parent]) {
        [currentLayer release];
        currentLayer = nil;
    }
    
    [self playTrack:nil];
}


+(GorillasAppDelegate *) get {
    
    return (GorillasAppDelegate *) [[UIApplication sharedApplication] delegate];
}


- (void)dealloc {
    
    [gameLayer release];
    gameLayer = nil;
    
    [currentLayer release];
    currentLayer = nil;
    
    [mainMenuLayer release];
    mainMenuLayer = nil;
    
    [continueMenuLayer release];
    continueMenuLayer = nil;

    [gameConfigLayer release];
    gameConfigLayer = nil;
    
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
    
    [super dealloc];
}


@end
