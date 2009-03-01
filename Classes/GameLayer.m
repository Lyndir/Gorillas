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
#import "Remove.h"


@interface GameLayer (Private)

-(void) setPausedSilently:(BOOL)_paused;
-(void) resetMessage:(NSString *)msg;
-(void) shuffleGorillas;

@end

@implementation GameLayer


#pragma mark Properties

@synthesize paused;
@synthesize gorillas, activeGorilla;
@synthesize skiesLayer, panningLayer, buildingsLayer, windLayer, weather;

-(BOOL) singlePlayer {

    return humans == 1;
}


-(BOOL) isEnabled:(GorillasFeature)feature {
    
    return mode & feature;
}


-(void) setPaused:(BOOL)_paused {

    if(paused == _paused)
        // Nothing changed.
        return;
    
    [self setPausedSilently:_paused];
    
    if(running) {
        if(paused)
            [self message:@"Paused"];
        else
            [self message:@"Unpaused"];
    }
}


-(void) setPausedSilently:(BOOL)_paused {
    
    paused = _paused;
    
    [[UIApplication sharedApplication] setStatusBarHidden:!paused animated:YES];
    
    if(paused) {
        [[GorillasAppDelegate get] hideHud];
        [windLayer do:[FadeTo actionWithDuration:[[GorillasConfig get] transitionDuration]
                                         opacity:0x00]];
    } else {
        [[GorillasAppDelegate get] dismissLayer];
        [[GorillasAppDelegate get] revealHud];
        [windLayer do:[FadeTo actionWithDuration:[[GorillasConfig get] transitionDuration]
                                         opacity:0xFF]];
    }
}


-(void) configureGameWithMode:(GorillasMode)_mode humans:(NSUInteger)_humans ais:(NSUInteger)_ais {
    
    mode = _mode;
    humans = _humans;
    ais = _ais;
}


#pragma mark Interact

-(void) reset {
    
    [skiesLayer reset];
    [panningLayer reset];
    [buildingsLayer reset];
    [windLayer reset];
    
    if ([self rotation])
        [self do:[RotateTo actionWithDuration:[[GorillasConfig get] transitionDuration]
                                        angle:0]];
}

-(void) shake {
    
    [AudioController vibrate];
    
    [buildingsLayer do:shakeAction];
}


-(void) message:(NSString *)msg {
    
    [self message:msg callback:nil :nil];
}


-(void) message:(NSString *)msg callback:(id)target :(SEL)selector {
    
    NSInvocation *callback = nil;
    if(target) {
        NSMethodSignature *signature = [[target class] instanceMethodSignatureForSelector:selector];
        callback = [NSInvocation invocationWithMethodSignature:signature];
        [callback setTarget:[target retain]];
        [callback setSelector:selector];
    }
    
    @synchronized(messageQueue) {
        [messageQueue insertObject:msg atIndex:0];
        [callbackQueue insertObject:callback? callback: (id)[NSNull null] atIndex:0];
        
        if(![self isScheduled:@selector(popMessageQueue:)])
            [self schedule:@selector(popMessageQueue:)];
    }
}


-(void) startGame {

    if(running)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Tried to start a game while one's still running."
                                     userInfo:nil];
    
    // Create gorillas array.
    if(activeGorilla)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Tried to start a game while there's still an active gorilla in the field."
                                     userInfo:nil];
    if(!gorillas)
        gorillas = [[NSMutableArray alloc] initWithCapacity:4];
    if([gorillas count])
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Tried to start a game while there's still gorillas in the field."
                                     userInfo:nil];
    
    // Add humans to the game.
    for (NSUInteger i = 0; i < humans; ++i) {
        GorillaLayer *gorilla = [[GorillaLayer alloc] initAsHuman:YES];
        
        if(humans == 1)
            [gorilla setName:@"Player"];
        else
            [gorilla setName:[NSString stringWithFormat:@"Player %d", i + 1]];
        
        [gorillas addObject:gorilla];
        [gorilla release];
    }
    
    // Add AIs to the game.
    for (NSUInteger i = 0; i < ais; ++i) {
        GorillaLayer *gorilla = [[GorillaLayer alloc] initAsHuman:NO];
        
        if(ais == 1)
            [gorilla setName:@"Phone"];
        else
            [gorilla setName:[NSString stringWithFormat:@"Chip %d", i + 1]];
        
        [gorillas addObject:gorilla];
        [gorilla release];
    }
    
    // Shuffle the order of the gorillas.
    [self shuffleGorillas];
    
    // When there are AIs in the game, show their difficulity.
    if (ais)
        [self message:[[GorillasConfig get] levelName]];
    
    // Reset the game field and start the game.
    [buildingsLayer stopPanning];
    [self reset];
    [buildingsLayer startGame];
}


- (void)shuffleGorillas {
    
    NSUInteger count = [gorillas count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (random() % nElements) + i;
        [gorillas exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}


-(BOOL) checkGameStillOn {

    if(running) {
        // Check to see if there are any opponents left.
        NSUInteger liveGorillas = 0;
        for (GorillaLayer *gorilla in gorillas)
            if ([gorilla alive])
                ++liveGorillas;
        
        if(liveGorillas < 2)
            running = false;
        
        // Team mode: Check if there are any gorillas left in the other team.
        if([self isEnabled:GorillasFeatureTeam]) {
            NSUInteger liveEnemyGorillas = 0;
            for (GorillaLayer *gorilla in gorillas)
                if (gorilla.alive && gorilla.human != activeGorilla.human)
                    ++liveEnemyGorillas;
            
            if(!liveEnemyGorillas)
                running = false;
        }
        
        if (!running)
            [self endGame];
    }
    
    return running;
}


-(void) stopGame {
    
    mode = 0;
    humans = 0;
    ais = 0;
    
    [self endGame];
}


-(void) endGame {
    
    [self setPausedSilently:NO];
    [buildingsLayer stopGame];
}


#pragma mark Internal

-(id) init {
    
	if (!(self = [super init]))
		return self;

    running = false;

    // Build internal structures.
    messageQueue = [[NSMutableArray alloc] initWithCapacity:3];
    callbackQueue = [[NSMutableArray alloc] initWithCapacity:3];
    msgLabel = nil;
    
    IntervalAction *l = [MoveBy actionWithDuration:.05f position:cpv(-3, 0)];
    IntervalAction *r = [MoveBy actionWithDuration:.05f position:cpv(6, 0)];
    shakeAction = [[Sequence actions:l, r, l, l, r, l, nil] retain];
    
    // Set up our own layer.
    CGSize winSize = [[Director sharedDirector] winSize];
    [self setTransformAnchor:cpv(winSize.width / 2, winSize.height / 2)];
    
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

    // Make sure we're paused, hide HUD and show status bar.
    [self setPausedSilently:YES];

    return self;
}


-(void) onEnter {
    
    [super onEnter];
    
    if ([[GorillasConfig get] weather])
        [self schedule:@selector(updateWeather:) interval:1];
}


-(void) onExit {

    [super onExit];
    
    [self unschedule:@selector(updateWeather:)];
}


-(void) updateWeather:(ccTime)dt {
    
    if (![[GorillasConfig get] weather] && [weather active])
        [weather stopSystem];
    
    if (![weather emissionRate]) {
        // If not emitting ..
        
        if ([weather active])
            // Stop active system.
            [weather stopSystem];
        
        if ([weather particleCount] == 0) {
            // If system has no particles left alive ..
            
            // Remove & release it.
            [windLayer unregisterSystem:weather];
            [[weather parent] removeAndStop:weather];
            [weather release];
            weather = nil;
            
            if ([[GorillasConfig get] weather] && random() % 10 == 0) {
                // 10% chance to start snow/rain when weather is enabled.
            
                switch (random() % 2) {
                    case 0:
                        weather = [[ParticleRain alloc] init];
                        [weather setEmissionRate:60];
                        [weather setSizeVar:1.5f];
                        [weather setSize:3];
                        break;
                    
                    case 1:
                        weather = [[ParticleSnow alloc] init];
                        [weather setSpeed:10];
                        [weather setEmissionRate:3];
                        [weather setSizeVar:3];
                        [weather setSize:4];
                        break;
                }
                
                [weather setPosVar:cpv([weather posVar].x * 2.5f, [weather posVar].y)];
                [weather setPosition:cpv([weather position].x, [weather position].y * 2)]; // Space above screen.
                [buildingsLayer add:weather z:-3 parallaxRatio:cpv(1.3f, 1.8f)];

                [windLayer registerSystem:weather affectAngle:true];
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


-(void) popMessageQueue: (ccTime)dt {
    
    @synchronized(messageQueue) {
        [self unschedule:@selector(popMessageQueue:)];

        if(![messageQueue count])
            // No messages left, don't reschedule.
            return;
        
        [self schedule:@selector(popMessageQueue:) interval:1.5f];
    }
    
    NSString *msg = [[messageQueue lastObject] retain];
    [messageQueue removeLastObject];
    
    NSInvocation *callback = [[callbackQueue lastObject] retain];
    [callbackQueue removeLastObject];
    
    [self resetMessage:msg];
    [msgLabel do:[Sequence actions:
                  [MoveBy actionWithDuration:1 position:cpv(0, -([[GorillasConfig get] fontSize] * 2))],
                  [FadeTo actionWithDuration:2 opacity:0x00],
                  nil]];
    
    if(callback != (id)[NSNull null]) {
        [callback invoke];
        [[callback target] release];
    }
    
    [msg release];
    [callback release];
}


-(void) resetMessage:(NSString *)msg {
    
    if(!msgLabel || [msgLabel numberOfRunningActions]) {
        // Detach existing label & create a new message label for the next message.
        if(msgLabel) {
            [msgLabel stopAllActions];
            [msgLabel do:[Sequence actions:
                          [MoveTo actionWithDuration:1
                                            position:cpv(-[msgLabel contentSize].width / 2, [msgLabel position].y)],
                          [FadeOut actionWithDuration:1],
                          [Remove action],
                          nil]];
            [msgLabel release];
        }
        
        msgLabel = [[Label alloc] initWithString:msg
                                        fontName:[[GorillasConfig get] fixedFontName]
                                        fontSize: [[GorillasConfig get] fontSize]];
        [self add:msgLabel z:1];
    }
    else
        [msgLabel setString:msg];

    CGSize winSize = [[Director sharedDirector] winSize];
    [msgLabel setPosition:cpv([msgLabel contentSize].width / 2 + [[GorillasConfig get] fontSize],
                              winSize.height + [[GorillasConfig get] fontSize])];
    [msgLabel setOpacity:0xff];
}


-(void) started {
    
    running = true;

    [self setPausedSilently:NO];
}


-(void) stopped {
    
    running = false;
    
    [activeGorilla release];
    activeGorilla = nil;
    
    if([self rotation])
        [self do:[RotateTo actionWithDuration:[[GorillasConfig get] transitionDuration]
                                        angle:0]];
    if([panningLayer position].x != 0 || [panningLayer position].y != 0)
        [panningLayer do:[MoveTo actionWithDuration:[[GorillasConfig get] transitionDuration]
                                           position:cpvzero]];
    
    if(mode)
        [[GorillasAppDelegate get] showContinueMenu];
    else
        // Selected game mode was unset, can't "continue".
        [[GorillasAppDelegate get] showMainMenu];
}


-(void) dealloc {
    
    [messageQueue release];
    messageQueue = nil;
    
    [callbackQueue release];
    callbackQueue = nil;
    
    [shakeAction release];
    shakeAction = nil;
    
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
    
    [gorillas release];
    gorillas = nil;
    
    [activeGorilla release];
    activeGorilla = nil;
    
    [msgLabel release];
    msgLabel = nil;
    
    [super dealloc];
}


@end
