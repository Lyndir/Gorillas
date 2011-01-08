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
#import "MainMenuLayer.h"
#import "GorillasAppDelegate.h"
#import "Remove.h"
#import "CityTheme.h"


@interface GameLayer ()

-(void) setPausedSilently:(BOOL)_paused;
- (void)updateWeather:(ccTime)dt;
- (void)randomEncounter:(ccTime)dt;

@end

@implementation GameLayer


#pragma mark Properties

@synthesize paused;
@synthesize gorillas, activeGorilla;
@synthesize skyLayer, panningLayer, cityLayer, windLayer, weather;
//FIXME @synthesize scaleTimeAction;

-(BOOL) isSinglePlayer {
    
    return humans == 1;
}


-(BOOL) isEnabled:(GorillasFeature)feature {
    
    // Make an exception for Score:
    if (feature == GorillasFeatureScore) {
        // Score is disabled if not single player AND not in team mode (non-team multiplayer), even if the feature is enabled.
        if (!self.singlePlayer && ![[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureTeam])
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
            [[GorillasAppDelegate get].uiLayer message:NSLocalizedString(@"messages.paused", @"Paused")];
        else
            [[GorillasAppDelegate get].uiLayer message:NSLocalizedString(@"messages.unpaused", @"Unpaused")];
    }
}


-(void) setPausedSilently:(BOOL)_paused {
    
    paused = _paused;
    
    [[UIApplication sharedApplication] setStatusBarHidden:!paused withAnimation:YES];
    
    if(paused) {
        if(running)
            [self scaleTimeTo:0 duration:0.5f];
        [[GorillasAppDelegate get] hideHud];
        [windLayer runAction:[CCFadeTo actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]
                                                  opacity:0x00]];
    } else {
        [self scaleTimeTo:1.0f duration:1.0f];
        [[GorillasAppDelegate get] popAllLayers];
        [[GorillasAppDelegate get] revealHud];
        [windLayer runAction:[CCFadeTo actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]
                                                  opacity:0xFF]];
    }
}


- (void)scaleTimeTo:(float)aTimeScale duration:(ccTime)aDuration {
    
    /*FIXME    if (scaleTimeAction)
     [self stopAction:scaleTimeAction];
     [scaleTimeAction release];
     
     scaleTimeAction = [[ScaleTime actionWithTimeScaleTarget:aTimeScale duration:aDuration] retain];
     [self runAction:scaleTimeAction scaleTime:NO];*/
}


-(void) configureGameWithMode:(GorillasMode)_mode randomCity:(BOOL)aRandomCity
                    playerIDs:(NSArray *)playerIDs ais:(NSUInteger)_ais {
    
    mode            = _mode;
    randomCity      = aRandomCity;
    humans          = 1 + [playerIDs count];
    ais             = _ais;
    
    // Create gorillas array.
    if(activeGorilla)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Tried to start a game while there's still an active gorilla in the field."
                                     userInfo:nil];
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
    
    if(!mode)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Tried to start a game without configuring it first."
                                     userInfo:nil];
    
    if(running)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Tried to start a game while one's still running."
                                     userInfo:nil];
    
    if (randomCity)
        [GorillasConfig get].cityTheme = [[CityTheme getThemeNames] objectAtIndex:gameRandom() % [[CityTheme getThemeNames] count]];

    
    // When there are AIs in the game, show their difficulity.
    if (ais)
        [[GorillasAppDelegate get].uiLayer message:[GorillasConfig nameForLevel:[GorillasConfig get].level]];
    
    [self reset];
    [self.cityLayer beginGame];
}

-(void) updateStateForThrow:(Throw)throw withSkill:(float)throwSkill {
    
    switch (throw.endCondition) {
        case ThrowNotEnded:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Throw should have ended." userInfo:nil];
            
        case ThrowEndOffScreen:
            [[[GorillasAppDelegate get] hudLayer] message:[GorillasConfig get].offMessage
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
                int score = [[GorillasConfig get].level floatValue] * [[GorillasConfig get].missScore intValue];
                
                [[GorillasConfig get] recordScore:[[GorillasConfig get].score intValue] + score];
                [[GorillasAppDelegate get].hudLayer updateHudWithNewScore:score skill:0 wasGood:YES];
                
                if(score)
                    [cityLayer message:[NSString stringWithFormat:@"%+d", score] on:cityLayer.bananaLayer.banana];
            }
            
            break;
        }
            
        case ThrowEndHitGorilla: {
            [cityLayer.hitGorilla kill];
            
            if (!cityLayer.hitGorilla.alive)
                [[[GorillasAppDelegate get] hudLayer] message:[NSString stringWithFormat:[GorillasConfig get].hitMessage,
                                                               activeGorilla.name, cityLayer.hitGorilla.name]
                                                     duration:4 isImportant:NO];

            int score = 0;
            BOOL cheer = NO;
            if([activeGorilla human]) {
                // Human hits ...
                
                if([cityLayer.hitGorilla human]) {
                    // ... Human.
                    if([self isEnabled:GorillasFeatureTeam]
                       || cityLayer.hitGorilla == activeGorilla)
                        // In team mode or when suiciding, deduct score.
                        score = [GorillasConfig get].deathScore;
                    else
                        cheer = YES;
                }
                
                else {
                    // ... AI.  Score boost.
                    score = [[GorillasConfig get].killScore intValue];
                    cheer = YES;
                }
            } else {
                // AI hits ...
                
                if([cityLayer.hitGorilla human]) {
                    // ... Human.
                    if(![self isEnabled:GorillasFeatureTeam])
                        // In team mode, deduct score.
                        score = [GorillasConfig get].deathScore;
                    
                    cheer = YES;
                } else {
                    // ... AI.
                    if(![self isEnabled:GorillasFeatureTeam] && cityLayer.hitGorilla != activeGorilla)
                        // Not in team and not suiciding.
                        cheer = YES;
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
                    [[GorillasAppDelegate get].uiLayer message:NSLocalizedString(@"messages.oneshot", @"Oneshot!")];
                    skill *= [[GorillasConfig get].bonusOneShot floatValue];
                }
                
                if(score)
                    score += (score / abs(score)) * [[GorillasConfig get].bonusSkill floatValue] * skill;
            }
            
            // Update Level.
            if([self isEnabled:GorillasFeatureLevel]) {
                score *= [[GorillasConfig get].level floatValue];
                
                NSString *oldLevel = [GorillasConfig nameForLevel:[GorillasConfig get].level];
                if(score > 0)
                    [[GorillasConfig get] levelUp];
                else
                    [[GorillasConfig get] levelDown];
                
                // Message in case we level up.
                if(![oldLevel isEqualToString:[GorillasConfig nameForLevel:[GorillasConfig get].level]]) {
                    if(score > 0) {
                        [[GorillasAppDelegate get].uiLayer message:NSLocalizedString(@"messages.level.up", @"Level Up!")];
                        if ([[GorillasConfig get].voice boolValue])
                            [[GorillasAudioController get] playEffectNamed:@"Level_Up"];
                    } else {
                        [[GorillasAppDelegate get].uiLayer message:NSLocalizedString(@"messages.level.down", @"Level Down")];
                        if ([[GorillasConfig get].voice boolValue])
                            [[GorillasAudioController get] playEffectNamed:@"Level_Down"];
                    }
                }
            }
            
            // Update score.
            if([self isEnabled:GorillasFeatureScore] && score) {
                [[GorillasConfig get] recordScore:[[GorillasConfig get].score intValue] + score];
                
                [[[GorillasAppDelegate get] hudLayer] updateHudWithNewScore:score skill:0 wasGood:YES];
                [cityLayer message:[NSString stringWithFormat:@"%+d", score] on:cityLayer.hitGorilla];
            }
            
            // If gorilla did something benefitial: cheer or dance.
            if(cheer) {
                if ([cityLayer.hitGorilla alive])
                    [activeGorilla cheer];
                else
                    [activeGorilla dance];
            }
            
            // Check whether any gorillas are left.
            int liveGorillaCount = 0;
            GorillaLayer *liveGorilla;
            for(GorillaLayer *_gorilla in gorillas)
                if([_gorilla alive]) {
                    liveGorillaCount++;
                    liveGorilla = _gorilla;
                }
            
            // If 0 or 1 gorillas left; show who won and stop the game.
            if(liveGorillaCount < 2) {
                if(liveGorillaCount == 1)
                    [[[GorillasAppDelegate get] hudLayer] message:[NSString stringWithFormat:NSLocalizedString(@"messages.wins", @"%@ wins!"),
                                                                   [liveGorilla name]] duration:4 isImportant:NO];
                else
                    [[[GorillasAppDelegate get] hudLayer] message:NSLocalizedString(@"messages.tie", @"Tie!") duration:4 isImportant:NO];
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
    
    [[GorillasAppDelegate get].netController endMatch];
    
    [self endGame];
}


-(void) endGame {
    
    [self setPausedSilently:NO];
    
    [cityLayer endGame];
}


#pragma mark Internal

-(id) init {
    
	if (!(self = [super init]))
		return self;
    
    running = NO;
    
    CCActionInterval *l     = [CCMoveBy actionWithDuration:.05f position:ccp(-3, 0)];
    CCActionInterval *r     = [CCMoveBy actionWithDuration:.05f position:ccp(6, 0)];
    shakeAction             = [[CCSequence actions:l, r, l, l, r, l, r, l, l, nil] retain];
    
    // Set up our own layer.
    self.anchorPoint        = ccp(0.5f, 0.5f);
    
    // Sky, buildings and wind.
    cityLayer               = [[CityLayer alloc] init];
    skyLayer                = [[SkyLayer alloc] init];
    panningLayer            = [[PanningLayer alloc] init];
    panningLayer.position   = CGPointZero;
    [panningLayer addChild:cityLayer z:0];
    [panningLayer addChild:skyLayer z:-5];
    [self addChild:panningLayer z:0];
    
    windLayer               = [[WindLayer alloc] init];
    windLayer.position      = ccp(self.contentSize.width / 2, self.contentSize.height - 15);
    [self addChild:windLayer z:5];
    
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
    
    if (![[GorillasConfig get].visualFx boolValue] && weather.active)
        [weather stopSystem];
    
    if (!weather.emissionRate) {
        // If not emitting ..
        
        if (weather.active)
            // Stop active system.
            [weather stopSystem];
        
        if (weather.particleCount == 0) {
            // If system has no particles left alive ..
            
            // Remove & release it.
            [windLayer unregisterSystem:weather];
            [weather.parent removeChild:weather cleanup:YES];
            [weather release];
            weather = nil;
            
            CGRect field = [cityLayer fieldInSpaceOf:panningLayer];
            
            if ([[GorillasConfig get].visualFx boolValue] && gameRandomFor(GorillasGameRandomWeather) % 100 == 0) {
                // 1% chance to start snow/rain when weather is enabled.
                
                switch (gameRandomFor(GorillasGameRandomWeather) % 2) {
                    case 0:
                        weather = [[CCParticleRain alloc] init];
                        weather.emissionRate    = 60;
                        weather.startSizeVar    = 1.5f;
                        weather.startSize       = 3;
                        break;
                        
                    case 1:
                        weather = [[CCParticleSnow alloc] init];
                        weather.speed           = 10;
                        weather.emissionRate    = 3;
                        weather.startSizeVar    = 3;
                        weather.startSize       = 4;
                        break;
                        
                    default:
                        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                                       reason:@"Unsupported weather type selected." userInfo:nil];
                }
                
                weather.positionType    = kCCPositionTypeGrouped;
                weather.posVar          = ccp(field.size.width / 2, weather.posVar.y);
                weather.position        = ccp(field.origin.x + field.size.width / 2, field.origin.y + field.size.height); // Space above screen.
                [panningLayer addChild:weather z:-3 /*parallaxRatio:ccp(1.3f, 1.8f) positionOffset:ccp(self.contentSize.width / 2,
                                                     self.contentSize.height / 2)*/];
                
                [windLayer registerSystem:weather affectAngle:YES];
            }
        }
    }
    
    else {
        // System is alive, let the emission rate evolve.
        float rate = [weather emissionRate] + (gameRandomFor(GorillasGameRandomWeather) % 40 - 15) / 10.0f;
        float max = [weather isKindOfClass:[CCParticleRain class]]? 200: 100;
        rate = max; // fminf(fmaxf(0, rate), max);
        
        if(gameRandomFor(GorillasGameRandomWeather) % 100 == 0)
            // 1% chance for a full stop.
            rate = 0;
        
        [weather setEmissionRate:rate];
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
    
    running = YES;
    
    [self setPausedSilently:NO];
    
    [self.cityLayer nextGorilla];
}


-(void) ended {
    
    running = NO;
    
    [activeGorilla release];
    activeGorilla = nil;
    
    if([panningLayer position].x != 0 || [panningLayer position].y != 0)
        [panningLayer runAction:[CCMoveTo actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]
                                                    position:CGPointZero]];
    
    if(mode)
        [[GorillasAppDelegate get] showContinueMenu];
    else
        // Selected game mode was unset, can't "continue".
        [[GorillasAppDelegate get] showMainMenu];
}


-(void) dealloc {
    
    [shakeAction release];
    shakeAction = nil;
    
    [skyLayer release];
    skyLayer = nil;
    
    [cityLayer release];
    cityLayer = nil;
    
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
    
    [super dealloc];
}


@end
