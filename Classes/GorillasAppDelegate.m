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
#import "TestLayer.h"


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
	[[Director sharedDirector] setDisplayFPS:true];
	[[Director sharedDirector] setDepthTest:false];
	[[Director sharedDirector] setLandscape:true];
	//glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    //glEnable(GL_LINE_SMOOTH);
	
    // Build the scene.
	gameLayer = [[GameLayer alloc] init];
	Scene *scene = [[Scene alloc] init];
	[scene add: gameLayer];
    
    // Start the scene and bring up the menu.
	[[Director sharedDirector] runScene: scene];
    [scene release];

    [self showMainMenu];
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
    
    [[self hudLayer] reveal];
}


-(void) hideHud {
    
    [hudLayer dismiss];
}


-(HUDLayer *) hudLayer {
    
    if(!hudLayer) {
        hudLayer = [[HUDLayer alloc] init];
        [gameLayer add:hudLayer];
    }
    
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
    
    if([currentLayer showing])
        [self dismissLayer];
    
    currentLayer = [layer retain];
    [currentLayer reveal];
}


-(void) showMainMenu {
    
    if(!mainMenuLayer) {
        mainMenuLayer = [[MainMenuLayer alloc] init];
        [gameLayer add:mainMenuLayer];
    }    
    
    [self showLayer:mainMenuLayer];
}


-(void) showContinueMenu {
    
    if(!continueMenuLayer) {
        continueMenuLayer = [[ContinueMenuLayer alloc] init];
        [gameLayer add:continueMenuLayer];
    }    
    
    [self showLayer:continueMenuLayer];
}


-(void) showConfiguration {
    
    if(!configLayer) {
        configLayer = [[ConfigurationSectionLayer alloc] init];
        [gameLayer add:configLayer];
    }
    
    [self showLayer:configLayer];
}


-(void) showGameConfiguration {
    
    if(!gameConfigLayer) {
        gameConfigLayer = [[GameConfigurationLayer alloc] init];
        [gameLayer add:gameConfigLayer];
    }
    
    [self showLayer:gameConfigLayer];
}


-(void) showAVConfiguration {
    
    if(!avConfigLayer) {
        avConfigLayer = [[AVConfigurationLayer alloc] init];
        [gameLayer add:avConfigLayer];
    }
    
    [self showLayer:avConfigLayer];
}


-(void) showInformation {
    
    if(!infoLayer) {
        infoLayer = [[InformationLayer alloc] init];
        [gameLayer add:infoLayer];
    }    
    
    [self showLayer:infoLayer];
}


-(void) showGuide {
    
    if(!guideLayer) {
        guideLayer = [[GuideLayer alloc] init];
        [gameLayer add:guideLayer];
    }    
    
    [self showLayer:guideLayer];
}


-(void) showStatistics {

    if(!statsLayer) {
        statsLayer = [[StatisticsLayer alloc] init];
        [gameLayer add:statsLayer];
    }    
    
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
    
    if(hudLayer && ![hudLayer showing]) {
        [hudLayer removeAndStopAll];
        [hudLayer release];
        hudLayer = nil;
    }
    if(mainMenuLayer && ![mainMenuLayer showing]) {
        [gameLayer removeAndStop:mainMenuLayer];
        [mainMenuLayer release];
        mainMenuLayer = nil;
    }
    if(continueMenuLayer && ![continueMenuLayer showing]) {
        [gameLayer removeAndStop:continueMenuLayer];
        [continueMenuLayer release];
        continueMenuLayer = nil;
    }
    if(configLayer && ![configLayer showing]) {
        [gameLayer removeAndStop:configLayer];
        [configLayer release];
        configLayer = nil;
    }
    if(gameConfigLayer && ![gameConfigLayer showing]) {
        [gameLayer removeAndStop:gameConfigLayer];
        [gameConfigLayer release];
        gameConfigLayer = nil;
    }
    if(avConfigLayer && ![avConfigLayer showing]) {
        [gameLayer removeAndStop:avConfigLayer];
        [avConfigLayer release];
        avConfigLayer = nil;
    }
    if(infoLayer && ![infoLayer showing]) {
        [gameLayer removeAndStop:infoLayer];
        [infoLayer release];
        infoLayer = nil;
    }
    if(guideLayer && ![guideLayer showing]) {
        [gameLayer removeAndStop:guideLayer];
        [guideLayer release];
        guideLayer = nil;
    }
    if(statsLayer && ![statsLayer showing]) {
        [gameLayer removeAndStop:statsLayer];
        [statsLayer release];
        statsLayer = nil;
    }
    if(currentLayer && ![currentLayer showing]) {
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
