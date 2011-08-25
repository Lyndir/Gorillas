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
//  GameLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 19/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//


#import "GameLayer.h"
#import "GorillasAppDelegate.h"
#import "Remove.h"
#import "CityTheme.h"
#import "InteractionLayer.h"
#import "LocalyticsSession.h"


@interface GameLayer ()

-(void) setPausedSilently:(BOOL)_paused;
- (void)updateWeather:(ccTime)dt;
- (void)randomEncounter:(ccTime)dt;

@end

@implementation GameLayer


#pragma mark Properties

@synthesize paused, configuring, started, running, mode;
@synthesize gorillas, activeGorilla;
@synthesize skyLayer, panningLayer, cityLayer, windLayer, backWeather, frontWeather;
@synthesize scaleTimeAction, timeScale;

-(BOOL) isSinglePlayer {
    
    return humans == 1;
}


-(BOOL) isEnabled:(GorillasFeature)feature {
    
    if (!self.singlePlayer) {
        if (feature == GorillasFeatureScore || feature == GorillasFeatureSkill || feature == GorillasFeatureLevel)
            // Features not supported in multiplayer.
            return NO;
    }
    
    return mode & feature;
}


-(void) setPaused:(BOOL)_paused {
    
    if(paused == _paused)
        // Nothing changed.
        return;
    
    [self setPausedSilently:_paused];
    
    if(running) {
        if(paused)
            [[GorillasAppDelegate get].uiLayer message:l(@"messages.paused")];
        else
            [[GorillasAppDelegate get].uiLayer message:l(@"messages.unpaused")];
    }
}


-(void) setPausedSilently:(BOOL)_paused {
    
    paused = _paused;
    
    if(paused) {
        if(running)
            [self scaleTimeTo:0];
        [[GorillasAppDelegate get] hideHud];
        [windLayer runAction:[CCFadeTo actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]
                                                  opacity:0x00]];
    } else {
        [self scaleTimeTo:1.0f];
        [[GorillasAppDelegate get] popAllLayers];
        [[GorillasAppDelegate get] revealHud];
        [windLayer runAction:[CCFadeTo actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]
                                                  opacity:0xFF]];
    }
}


- (void)scaleTimeTo:(float)aTimeScale {
    
    [scaleTimeAction tweenKeyPath:@"timeScale" to:aTimeScale];
}


-(void) configureGameWithMode:(GorillasMode)_mode randomCity:(BOOL)aRandomCity
                    playerIDs:(NSArray *)playerIDs localHumans:(NSUInteger)localHumans ais:(NSUInteger)_ais {
    
    configuring     = YES;

    [self stopGame];
    
    mode            = _mode;
    randomCity      = aRandomCity;
    humans          = localHumans + [playerIDs count];
    ais             = _ais;
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"New Game" attributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [GorillasConfig nameForMode:mode],
      @"mode",
      [NSNumber numberWithUnsignedInt:localHumans],
      @"localHumans",
      [NSNumber numberWithUnsignedInt:[playerIDs count]],
      @"remoteHumans",
      [NSNumber numberWithUnsignedInt:ais],
      @"ais",
      nil]];

    // Create gorillas array.
    [gorillas removeAllObjects];
    if(!gorillas)
        gorillas = [[NSMutableArray alloc] initWithCapacity:humans + ais];
    
    // Prepare.
    [GorillaLayer prepareCreation];
    
    // Add humans to the game.
    if (playerIDs) {
        for (NSString *playerID in playerIDs)
            [gorillas addObject:[GorillaLayer gorillaWithType:GorillasPlayerTypeHuman playerID:playerID]];
        
        [GKPlayer loadPlayersForIdentifiers:playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
            if (error)
                err(@"While loading player information: %@", error);
            
            for (GKPlayer *player in players)
                for (GorillaLayer *gorilla in gorillas)
                    if ([gorilla.playerID isEqualToString:player.playerID])
                        gorilla.player = player;
        }];
    }
    else
        for (NSUInteger i = 0; i < humans; ++i)
            [gorillas addObject:[GorillaLayer gorillaWithType:GorillasPlayerTypeHuman playerID:nil]];
    
    // Add AIs to the game.
    for (NSUInteger i = 0; i < ais; ++i)
        [gorillas addObject:[GorillaLayer gorillaWithType:GorillasPlayerTypeAI playerID:nil]];
    
    configuring     = NO;
}


#pragma mark Interact

-(void) reset {
    dbg(@"GameLayer reset");
    
    [skyLayer reset];
    [panningLayer reset];
    [cityLayer reset];
    [windLayer reset];
    for (GorillaLayer *gorilla in self.gorillas)
        [gorilla reset];
}

-(void) shake {
    
    if ([[GorillasConfig get].vibration boolValue])
        [GorillasAudioController vibrate];
    
    if (![shakeAction isDone])
        [cityLayer stopAction:shakeAction];
    
    [cityLayer runAction:shakeAction];
}


-(void) startGame {
    dbg(@"GameLayer startGame");
    
    if(!mode) {
        err(@"Tried to start a game without configuring it first.");
        return;
    }
    
    if(running) {
        err(@"Tried to start a game while one's still running.");
        return;
    }
    
    if (randomCity)
        [GorillasConfig get].cityTheme = [[CityTheme getThemeNames] objectAtIndex:gameRandom() % [[CityTheme getThemeNames] count]];
    else
        [self reset];

    // When there are AIs in the game, show their difficulity.
    if (ais)
        [[GorillasAppDelegate get].uiLayer message:[GorillasConfig nameForLevel:[GorillasConfig get].level]];
    
    self.started = YES;
    
    [self.cityLayer beginGame];
}

-(void) updateStateForThrow:(Throw)throw withSkill:(float)throwSkill {
    
    switch (throw.endCondition) {
        case ThrowNotEnded:
            err(@"Throw should have ended.");
            return;
            
        case ThrowEndOffScreen:
            [[[GorillasAppDelegate get] hudLayer] message:[[GorillasConfig get] messageForOff]
                                                 duration:4 isImportant:NO];
        case ThrowEndHitBuilding: {
            // Either hit building or threw off screen.
            
            BOOL considderMiss = YES;
            
            if (!([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureScore]))
                // Don't deduct score when score not enabled.
                considderMiss = NO;
            
            if (!([[GorillasAppDelegate get].gameLayer.activeGorilla human]))
                // Don't deduct score for AI misses.
                considderMiss = NO;
            
            if (![[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureTeam]) {
                NSUInteger humanGorillas = 0;
                for (GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
                    if ([gorilla human])
                        ++humanGorillas;
                
                if(humanGorillas != 1)
                    // Don't deduct score for non-teamed multiplayer.
                    considderMiss = NO;
            }
            
            if (considderMiss) {
                int64_t scoreDelta = [[GorillasConfig get].level floatValue] * [[GorillasConfig get].missScore intValue];
                
                if(scoreDelta) {
                    [[GorillasConfig get] recordScoreDelta:scoreDelta forMode:mode];
                    [[GorillasAppDelegate get].hudLayer highlightGood:scoreDelta > 0];
                    
                    [cityLayer message:[NSString stringWithFormat:@"%+d", scoreDelta] on:cityLayer.bananaLayer.banana];
                }
            }
            
            break;
        }
            
        case ThrowEndHitGorilla: {
            [cityLayer.hitGorilla kill];
            
            if (!cityLayer.hitGorilla.alive)
                [[[GorillasAppDelegate get] hudLayer] message:[[GorillasConfig get] messageForHitBy:activeGorilla on:cityLayer.hitGorilla]
                                                     duration:4 isImportant:NO];
            
            int64_t scoreDelta = 0;
            BOOL dance = NO;
            if([activeGorilla human]) {
                // Human hits ...
                
                if([cityLayer.hitGorilla human]) {
                    // ... Human.
                    if([self isEnabled:GorillasFeatureTeam]
                       || cityLayer.hitGorilla == activeGorilla)
                        // In team mode or when suiciding, deduct score.
                        scoreDelta = [GorillasConfig get].deathScore;
                    else
                        dance = YES;
                }
                
                else {
                    // ... AI.  Score boost.
                    scoreDelta = [[GorillasConfig get].killScore intValue];
                    dance = YES;
                }
            } else {
                // AI hits ...
                
                if([cityLayer.hitGorilla human]) {
                    // ... Human.
                    if(![self isEnabled:GorillasFeatureTeam])
                        // In team mode, deduct score.
                        scoreDelta = [GorillasConfig get].deathScore;
                    
                    dance = YES;
                } else {
                    // ... AI.
                    if(![self isEnabled:GorillasFeatureTeam] && cityLayer.hitGorilla != activeGorilla)
                        // Not in team and not suiciding.
                        dance = YES;
                }
            }
            
            // Update Skill.
            if([self isEnabled:GorillasFeatureSkill]) {
                float skill = 0;
                
                if([activeGorilla human]) {
                    // Human skill.
                    [GorillasConfig get].skill = [NSNumber numberWithFloat:skill = fminf(0.99f, [[GorillasConfig get].skill floatValue] / 2 + throwSkill)];
                } else
                    // AI skill.
                    skill = [[GorillasConfig get].level floatValue];
                
                // Apply oneshot bonus.
                if(activeGorilla.turns == 0) {
                    [[GorillasAppDelegate get].uiLayer message:l(@"messages.oneshot")];
                    skill *= [[GorillasConfig get].bonusOneShot floatValue];
                }
                
                if(scoreDelta)
                    scoreDelta += (int64_t)((Sign(scoreDelta)) * [[GorillasConfig get].bonusSkill floatValue] * skill);
            }
            
            // Update Level.
            if([self isEnabled:GorillasFeatureLevel]) {
                scoreDelta *= [[GorillasConfig get].level doubleValue];

                NSString *oldLevel = [GorillasConfig nameForLevel:[GorillasConfig get].level];
                if(scoreDelta > 0)
                    [[GorillasConfig get] levelUp];
                else
                    [[GorillasConfig get] levelDown];
                
                // Message in case we level up.
                if(![oldLevel isEqualToString:[GorillasConfig nameForLevel:[GorillasConfig get].level]]) {
                    if(scoreDelta > 0) {
                        [[GorillasAppDelegate get].uiLayer message:l(@"messages.level.up")];
                        if ([[GorillasConfig get].voice boolValue])
                            [[GorillasAudioController get] playEffectNamed:@"Level_Up"];
                    } else {
                        [[GorillasAppDelegate get].uiLayer message:l(@"messages.level.down")];
                        if ([[GorillasConfig get].voice boolValue])
                            [[GorillasAudioController get] playEffectNamed:@"Level_Down"];
                    }
                }
            }
            
            // Update score.
            if([self isEnabled:GorillasFeatureScore] && scoreDelta) {
                [[GorillasConfig get] recordScoreDelta:scoreDelta forMode:mode];
                
                [[[GorillasAppDelegate get] hudLayer] highlightGood:scoreDelta > 0];
                [cityLayer message:[NSString stringWithFormat:@"%+d", scoreDelta] on:cityLayer.hitGorilla];
            }
            
            // Check whether any gorillas are left.
            int liveGorillaCount = 0;
            GorillaLayer *liveGorilla = nil;
            for(GorillaLayer *_gorilla in gorillas)
                if([_gorilla alive]) {
                    liveGorillaCount++;
                    liveGorilla = _gorilla;
                }
            
            // If gorilla did something benefitial: cheer or dance.
            if(dance) {
                if ([cityLayer.hitGorilla alive])
                    [activeGorilla danceHit];
                else if (liveGorillaCount > 2)
                    [activeGorilla danceKill];
                else
                    [activeGorilla danceVictory];
            }
            
            // If 0 or 1 gorillas left; show who won and stop the game.
            if(liveGorillaCount < 2) {
                if(liveGorillaCount == 1)
                    [[[GorillasAppDelegate get] hudLayer] message:l(@"messages.wins", [liveGorilla name]) duration:4 isImportant:NO];
                else
                    [[[GorillasAppDelegate get] hudLayer] message:l(@"messages.tie") duration:4 isImportant:NO];
            }
            
            // Reset the wind.
            [windLayer reset];
            
            break;
        }
    }
}


-(BOOL) checkGameStillOn {
    
    if(running) {
        // Check to see if there are any opponents left.
        NSUInteger liveGorillas = 0;
        NSUInteger liveEnemyGorillas = 0;
        for (GorillaLayer *gorilla in gorillas) {
            if (![gorilla alive])
                continue;
            
            // Gorilla is alive.
            ++liveGorillas;
            
            // Gorilla is on active gorilla's team.
            if (gorilla.human != activeGorilla.human)
                ++liveEnemyGorillas;
        }
        
        if(liveGorillas < 2)
            running = NO;
        
        if([self isEnabled:GorillasFeatureTeam]
           && !liveEnemyGorillas)
            running = NO;
    }
    
    return running;
}


-(void) stopGame {
    
    mode = 0;
    humans = 0;
    ais = 0;
    
#if ! LITE
    if ([GorillasAppDelegate get].netController.match)
        [[GorillasAppDelegate get].netController endMatchForced:NO];
#endif
    
    [self endGame];
}


-(void) endGame {
    
    running = NO;
    [self setPausedSilently:NO];
    
    [cityLayer endGame];
}


#pragma mark Internal

-(id) init {
    
	if (!(self = [super init]))
		return self;
    
    timeScale = 1.0f;
    mode = GorillasModeClassic;
    running = NO;
    
    CCActionInterval *l     = [CCMoveBy actionWithDuration:.05f position:ccp(-3, 0)];
    CCActionInterval *r     = [CCMoveBy actionWithDuration:.05f position:ccp(6, 0)];
    shakeAction             = [[CCSequence actions:l, r, l, l, r, l, r, l, l, nil] retain];
    
    // Set up our own layer.
    self.anchorPoint        = ccp(0.5f, 0.5f);
    
    // Sky, buildings and wind.
    cityLayer               = [[CityLayer alloc] init];
    skyLayer                = [[SkyLayer alloc] init];
    CCSprite *light = [CCSprite spriteWithFile:@"fire.png"];
    light.position = ccp(240, -500);
    light.scale = 100;
    light.color = ccc3(0xff, 0xff, 0);
    light.opacity = 0x55;
    panningLayer            = [[PanningLayer alloc] init];
    panningLayer.position   = CGPointZero;
    [panningLayer addChild:[InteractionLayer node] z:1];
    [panningLayer addChild:cityLayer z:0];
    [panningLayer addChild:skyLayer z:-5];
    [panningLayer addChild:light z:-1];
    [self addChild:panningLayer z:0];

    windLayer               = [[WindLayer alloc] init];
    windLayer.position      = ccp(self.contentSize.width / 2, self.contentSize.height - 15);
    [self addChild:windLayer z:5];
    
    scaleTimeAction         = [[AutoTween alloc] initWithDuration:0.5f];
    scaleTimeAction.tag     = kCCActionTagIgnoreTimeScale;
    [self runAction:scaleTimeAction];
    
    paused = YES;
    
    return self;
}


-(void) onEnter {
    
    [super onEnter];
    
    [self setPausedSilently:YES];
    
    if ([[GorillasConfig get].visualFx boolValue])
        [self schedule:@selector(updateWeather:) interval:1];
    [self schedule:@selector(randomEncounter:) interval:1];
}


-(void) onExit {
    
    [super onExit];
    
    [self setPausedSilently:YES];
}


-(void) updateWeather:(ccTime)dt {
    
    if (![[GorillasConfig get].visualFx boolValue] && backWeather.active) {
        [backWeather stopSystem];
        [frontWeather stopSystem];
    }
    
    if (!backWeather.emissionRate) {
        // If not emitting ..
        
        if (backWeather.active) {
            // Stop active system.
            [backWeather stopSystem];
            [frontWeather stopSystem];
        }
        
        if (backWeather.particleCount == 0) {
            // If system has no particles left alive ..
            
            // Remove & release it.
            [windLayer unregisterSystem:backWeather];
            [backWeather removeFromParentAndCleanup:YES];
            [backWeather release];
            backWeather = nil;
            [windLayer unregisterSystem:frontWeather];
            [frontWeather removeFromParentAndCleanup:YES];
            [frontWeather release];
            frontWeather = nil;
            
            
            CGRect field = [cityLayer fieldInSpaceOf:panningLayer];
            
            if ([[GorillasConfig get].visualFx boolValue] && gameRandomFor(GorillasGameRandomWeather) % 100 == 0) {
                // 1% chance to start snow/rain when weather is enabled.
                
                switch (gameRandomFor(GorillasGameRandomWeather) % 2) {
                    case 0:
                        backWeather                 = [[CCParticleRain alloc] init];
                        backWeather.emissionRate    = 60;
                        backWeather.startSizeVar    = 0.5f;
                        backWeather.startSize       = 1;
                        
                        frontWeather                = [[CCParticleRain alloc] init];
                        frontWeather.emissionRate   = 60;
                        frontWeather.startSizeVar   = 1.5f;
                        frontWeather.startSize      = 3;
                        break;
                        
                    case 1:
                        backWeather                 = [[CCParticleSnow alloc] init];
                        backWeather.speed           = 10;
                        backWeather.emissionRate    = 3;
                        backWeather.startSizeVar    = 2;
                        backWeather.startSize       = 2;
                        
                        frontWeather                = [[CCParticleSnow alloc] init];
                        frontWeather.speed          = 10;
                        frontWeather.emissionRate   = 3;
                        frontWeather.startSizeVar   = 3;
                        frontWeather.startSize      = 4;
                        break;
                        
                    default:
                        err(@"Unsupported weather type selected.");
                        return;
                }
                
                backWeather.positionType    = kCCPositionTypeGrouped;
                backWeather.posVar          = ccp(field.size.width / 2, backWeather.posVar.y);
                backWeather.position        = ccp(field.origin.x + field.size.width / 2, field.origin.y + field.size.height); // Space above screen.
                [panningLayer addChild:backWeather z:-1];
                [windLayer registerSystem:backWeather affectAngle:YES];
                
                frontWeather.positionType   = kCCPositionTypeGrouped;
                frontWeather.posVar         = ccp(field.size.width / 2, frontWeather.posVar.y);
                frontWeather.position       = ccp(field.origin.x + field.size.width / 2, field.origin.y + field.size.height); // Space above screen.
                [panningLayer addChild:frontWeather];
                [windLayer registerSystem:frontWeather affectAngle:YES];
            }
        }
    }
    
    else {
        // System is alive, let the emission rate evolve.
        float rate = [backWeather emissionRate] + (gameRandomFor(GorillasGameRandomWeather) % 40 - 15) / 10.0f;
        float max = [backWeather isKindOfClass:[CCParticleRain class]]? 200: 100;
        rate = fminf(fmaxf(0, rate), max);
        
        if(gameRandomFor(GorillasGameRandomWeather) % 100 == 0)
            // 1% chance for a full stop.
            rate = 0;
        
        [backWeather setEmissionRate:rate];
        [frontWeather setEmissionRate:rate];
    }
}


-(void) randomEncounter:(ccTime)dt {
    
    if(!running)
        return;
    
    // Need to refactor some bad logic about setting projectile as cleared before this'll work.
    //    if(gameRandom(GorillasGameRandomWeather) % 1 == 0) {
    //        BananaLayer *egg = [[BananaLayer alloc] init];
    //        [egg setModel:GorillasProjectileModelEasterEgg];
    //
    //        CGSize winSize = [[CCDirector sharedDirector] winSize];
    //        [egg throwFrom:ccp(winSize.width / 2 - buildingsLayer.position.x, winSize.height * 2)
    //          withVelocity:ccp(0, 0)];
    //        
    //        [buildingsLayer addChild:egg z:2];
    //        [egg release];
    //    }
}


-(void) began {
    
    [self setPausedSilently:NO];
    
#if ! LITE
    if ([GorillasAppDelegate get].netController.match)
        [[GorillasAppDelegate get].netController sendBecameReady];
    else
#endif
        [self.cityLayer nextGorilla];
}


-(void) ended {
    
    started = NO;
    
    [activeGorilla release];
    activeGorilla = nil;
    
    [panningLayer scrollToCenter:CGPointZero horizontal:YES];
    
    if (!configuring)
        [[GorillasAppDelegate get] showMainMenu];
}


-(void) dealloc {
    
    [shakeAction release];
    shakeAction = nil;
    
    [skyLayer release];
    skyLayer = nil;
    
    [cityLayer release];
    cityLayer = nil;
    
    [backWeather release];
    backWeather = nil;
    
    [frontWeather release];
    frontWeather = nil;
    
    [panningLayer release];
    panningLayer = nil;
    
    [windLayer release];
    windLayer = nil;
    
    [gorillas release];
    gorillas = nil;
    
    [activeGorilla release];
    activeGorilla = nil;
    
    [super dealloc];
}


@end
