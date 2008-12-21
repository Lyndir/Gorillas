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

@synthesize gameLayer, configLayer, hudLayer, audioController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:true];
    
    // Start the background music.
    [self playTrack:[[GorillasConfig get] currentTrack]];

    // Random seed with timestamp.
    srandom(time(nil));
    
    // Menu items font.
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];

	// Director and OpenGL Setup.
    [Director setPixelFormat:RGBA8];
	//[[Director sharedDirector] setDisplayFPS:true];
	[[Director sharedDirector] setDepthTest:false];
	[[Director sharedDirector] setLandscape:true];
	//glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    //glEnable(GL_POINT_SMOOTH);
	
    // Build the scene.
	gameLayer = [GameLayer node];
	Scene *scene = [Scene node];
	[scene add: gameLayer];
    
    // Start the scene and bring up the menu.
	[[Director sharedDirector] runScene: scene];
    //[gameLayer add:[TestLayer node]];
    //return
    [self showMainMenu];
    
    // Load the HUD.
    hudLayer = [[HUDLayer alloc] init];
    [gameLayer add:hudLayer];
}


-(void) revealHud {
    
    [[UIApplication sharedApplication] setStatusBarHidden:true animated:true];
    [hudLayer reveal];
}


-(void) hideHud {
    
    [[UIApplication sharedApplication] setStatusBarHidden:false animated:true];
    [hudLayer dismiss];
}


-(void) dismissLayer {
    
    [currentLayer dismiss];
}


-(void) showLayer: (ShadeLayer *)layer {
    
    if([currentLayer showing])
        [currentLayer dismiss];
    
    currentLayer = layer;
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
        configLayer = [[ConfigurationLayer alloc] init];
        [gameLayer add:configLayer];
    }
    
    [self showLayer:configLayer];
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
        audioController = [[[AudioController alloc] initWithFile:nextTrack] retain];
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


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
	[[TextureMgr sharedTextureMgr] removeAllTextures];
    
    if(![currentLayer showing])
        if(currentLayer == mainMenuLayer) {
            [gameLayer remove:mainMenuLayer];
            [mainMenuLayer release];
            mainMenuLayer = nil;
        }
        else if(currentLayer == statsLayer) {
            [gameLayer remove:statsLayer];
            [statsLayer release];
            statsLayer = nil;
        }
        else if(currentLayer == configLayer) {
            [gameLayer remove:configLayer];
            [configLayer release];
            configLayer = nil;
        }
    
    [self playTrack:nil];
}


+(GorillasAppDelegate *) get {
    
    return (GorillasAppDelegate *) [[UIApplication sharedApplication] delegate];
}


- (void)dealloc {
    
    [mainMenuLayer release];
    [statsLayer release];
    [configLayer release];
    [audioController release];
    [hudLayer release];
    
    [super dealloc];
}


@end
