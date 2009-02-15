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
//  GameLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 19/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//


#import "GameLayer.h"
#import "MainMenuLayer.h"
#import "GorillasAppDelegate.h"


@implementation GameLayer


@synthesize panningLayer, skiesLayer, buildingsLayer, windLayer, weather, singlePlayer, running, paused;


-(id) init {
    
	if (!(self = [super init]))
		return self;
    
    singlePlayer = false;
    running = false;
    paused = true;
    
    // Sky, buildings and wind.
    buildingsLayer = [[BuildingsLayer alloc] init];
    [buildingsLayer setTransformAnchor:cpvzero];

    skiesLayer = [[SkiesLayer alloc] init];
    [skiesLayer setTransformAnchor:cpvzero];
    
    panningLayer = [[PanningLayer alloc] init];
    [panningLayer setTransformAnchor:cpvzero];
    [panningLayer add:buildingsLayer z:0];
    [panningLayer add:skiesLayer z:-5 parallaxRatio:cpv(0.3f, 0.8f)];
    [self add:panningLayer];
    
    windLayer = [[WindLayer alloc] init];
    [windLayer setColor:0xffffff00];
    [self add:windLayer z:5];

    return self;
}


-(void) onEnter {
    
    [super onEnter];
    
    if([[GorillasConfig get] weather])
        [self schedule:@selector(updateWeather:) interval:1];
}


-(void) onExit {

    [super onExit];
    
    [self unschedule:@selector(updateWeather:)];
}


-(void) updateWeather:(ccTime)dt {
    
    if(![[GorillasConfig get] weather])
        [self unschedule:@selector(updateWeather:)];
    
    if(![weather emissionRate]) {
        // If not emitting ..
        
        if([weather active])
            // Stop active system.
            [weather stopSystem];
        
        if([weather particleCount] == 0) {
            // If system has no particles left alive ..
            
            // Remove & release it.
            [[[[GorillasAppDelegate get] gameLayer] windLayer] unregisterSystem:weather];
            if([weather parent])
                [[weather parent] removeAndStop:weather];
            [weather release];
            weather = nil;
            
            if(random() % 10 == 0) {
                // 10% chance to start snow/rain.
            
                switch (random() % 2) {
                    case 0:
                        weather = [[ParticleRain alloc] init];
                        [weather setEmissionRate:60];
                        [weather setSize:3];
                        [weather setSizeVar:1.5f];
                        break;
                    
                    case 1:
                        weather = [[ParticleSnow alloc] init];
                        [weather setSpeed:10];
                        [weather setEmissionRate:3];
                        [weather setSize:4];
                        [weather setSizeVar:3];
                        break;
                }
                
                [weather setPosVar:cpv([weather posVar].x * 2.5f, [weather posVar].y)];
                [weather setPosition:cpv([weather position].x, [weather position].y * 2)]; // Space above screen.
                [buildingsLayer add:weather z:-3 parallaxRatio:cpv(1.3f, 1.8f)];

                [[[[GorillasAppDelegate get] gameLayer] windLayer] registerSystem:weather affectAngle:true];
            }
        }
    }
    
    else {
        // System is alive, let the emission rate evolve.
        float rate = [weather emissionRate] + (random() % 40 - 15) / 10.0f;
        float max = [weather isKindOfClass:[ParticleRain class]]? 100: 50;
        rate = fminf(fmaxf(0, rate), max);

        if(random() % 100 == 0)
            // 1% chance for a full stop.
            rate = 0;
    
        [weather setEmissionRate:rate];
    }
}


-(void) reset {

    [skiesLayer reset];
    [buildingsLayer reset];
    [windLayer reset];
}


-(void) pause {
    
    if(!running)
        // Only allow toggling pause state while game is running.
        return;
    
    if(!paused)
        [self message:@"Paused"];
    
    paused = true;
    
    [[UIApplication sharedApplication] setStatusBarHidden:false animated:true];
    [[GorillasAppDelegate get] hideHud];
    [windLayer do:[FadeOut actionWithDuration:[[GorillasConfig get] transitionDuration]]];
}


-(void) unpause {
    
    if(!running)
        // Only allow toggling pause state while game is running.
        return;
    
    if(paused)
        [self message:@"Unpaused!"];

    paused = false;
    
    [[UIApplication sharedApplication] setStatusBarHidden:true animated:true];
    [[GorillasAppDelegate get] dismissLayer];
    [[GorillasAppDelegate get] revealHud];
    [windLayer do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
}


-(void) message: (NSString *)msg {
    
    if(!msgLabel) {
        msgLabel = [[Label alloc] initWithString:@"" dimensions:CGSizeMake(1000, [[GorillasConfig get] fontSize] + 5)
                                       alignment:UITextAlignmentLeft
                                        fontName:[[GorillasConfig get] fixedFontName]
                                        fontSize: [[GorillasConfig get] fontSize]];
        [self add:msgLabel z:1];
    }
    
    [self resetMessage:nil];
    [msgLabel setVisible:true];
    [msgLabel setString:msg];
    [msgLabel do:[Sequence actions:
                    [MoveBy actionWithDuration:1 position:cpv(0, -([[GorillasConfig get] fontSize] * 2))],
                    [FadeOut actionWithDuration:2],
                    [CallFunc actionWithTarget:self selector:@selector(resetMessage:)],
                    nil]];
}


-(void) resetMessage: (id) sender {
    
    [msgLabel stopAllActions];

    CGSize winSize = [[Director sharedDirector] winSize];
    [msgLabel setPosition:cpv([msgLabel contentSize].width / 2 + [[GorillasConfig get] fontSize], winSize.height + [[GorillasConfig get] fontSize])];
    [msgLabel setOpacity:0xff];
    [msgLabel setVisible:false];
}


-(void) startSinglePlayer {
    
    if(running)
        return;
    
    running = true;
    singlePlayer = true;
    
    [self message:[[GorillasConfig get] levelName]];
    
    GorillaLayer *gorillaA = [[GorillaLayer alloc] init];
    GorillaLayer *gorillaB = [[GorillaLayer alloc] init];
    
    [gorillaA setName:@"Player"];
    [gorillaA setHuman:true];
    
    [gorillaB setName:@"Phone"];
    [gorillaB setHuman:false];
    
    [windLayer reset];
    [buildingsLayer startGameWithGorilla:gorillaA andGorilla:gorillaB];
    
    [gorillaA release];
    [gorillaB release];
}


-(void) startMultiplayer {
    
    if(running)
        return;
    
    running = true;
    singlePlayer = false;
    
    GorillaLayer *gorillaA = [[GorillaLayer alloc] init];
    GorillaLayer *gorillaB = [[GorillaLayer alloc] init];
    
    [gorillaA setName:@"Gorilla One"];
    [gorillaA setHuman:true];
    
    [gorillaB setName:@"Gorilla Two"];
    [gorillaB setHuman:true];
    
    [windLayer reset];
    [buildingsLayer startGameWithGorilla:gorillaA andGorilla:gorillaB];
    
    [gorillaA release];
    [gorillaB release];
}


-(void) started {
    
    running = true;
    paused = false;
    
    [self unpause];
}


-(void) stopGame {
    
    if(!running)
        return;
    
    paused = false;
    [self unpause];
    
    [buildingsLayer stopGame];
}


-(void) stopped {
    
    paused = true;
    [self pause];
    
    running = false;
    
    if(singlePlayer)
        [[GorillasAppDelegate get] showContinueMenu];
    else
        [[GorillasAppDelegate get] showMainMenu];
}


-(void) dealloc {
    
    [skiesLayer release];
    skiesLayer = nil;
    
    [buildingsLayer release];
    buildingsLayer = nil;
    
    [weather release];
    weather = nil;
    
    [panningLayer release];
    panningLayer = nil;
    
    [windLayer release];
    windLayer = nil;
    
    [msgLabel release];
    msgLabel = nil;
    
    [super dealloc];
}


@end
