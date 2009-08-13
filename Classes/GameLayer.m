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
@synthesize scaleTimeAction;

-(BOOL) singlePlayer {

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
        else {
            [[GorillasAppDelegate get].uiLayer message:NSLocalizedString(@"messages.unpaused", @"Unpaused")];
            if ([[GorillasConfig get].voice boolValue])
                [[GorillasAudioController get] playEffectNamed:@"Go"];
        }
    }
}


-(void) setPausedSilently:(BOOL)_paused {
    
    paused = _paused;
    
    [[UIApplication sharedApplication] setStatusBarHidden:!paused animated:YES];
    
    if(paused) {
        if(running)
            [self scaleTimeTo:0 duration:0.5f];
        [[GorillasAppDelegate get] hideHud];
        [windLayer runAction:[FadeTo actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]
                                                opacity:0x00]];
    } else {
        [self scaleTimeTo:1.0f duration:1.0f];
        [[GorillasAppDelegate get] popAllLayers];
        [[GorillasAppDelegate get] revealHud];
        [windLayer runAction:[FadeTo actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]
                                                opacity:0xFF]];
    }
}


- (void)scaleTimeTo:(float)aTimeScale duration:(ccTime)aDuration {

    if (scaleTimeAction)
        [self stopAction:scaleTimeAction];
    [scaleTimeAction release];
    
    scaleTimeAction = [[ScaleTime actionWithTimeScaleTarget:aTimeScale duration:aDuration] retain];
    [self runAction:scaleTimeAction scaleTime:NO];
}


-(void) configureGameWithMode:(GorillasMode)_mode humans:(NSUInteger)_humans ais:(NSUInteger)_ais {
    
    mode = _mode;
    humans = _humans;
    ais = _ais;
}


#pragma mark Interact

-(void) reset {
    
    [skyLayer reset];
    [panningLayer reset];
    [cityLayer reset];
    [windLayer reset];
}

-(void) shake {
    
    if ([[GorillasConfig get].vibration boolValue])
        [GorillasAudioController vibrate];
    
    [cityLayer runAction:shakeAction];
}


-(void) startGame {

    if(!mode)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Tried to start a game without configuring it first."
                                     userInfo:nil];
    
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
    
    [GorillaLayer prepareCreation];
    
    // Add humans to the game.
    for (NSUInteger i = 0; i < humans; ++i) {
        NSString *name = NSLocalizedString(@"names.player", @"Player");
        if(humans > 1)
            name = [NSString stringWithFormat:NSLocalizedString(@"names.player.n", @"Player %d"), i + 1];
        
        GorillaLayer *gorilla = [[GorillaLayer alloc] initWithName:name type:GorillasPlayerTypeHuman];
        [gorillas addObject:gorilla];
        [gorilla release];
    }
    
    // Add AIs to the game.
    for (NSUInteger i = 0; i < ais; ++i) {
        NSString *name = NSLocalizedString(@"names.chip", @"Chip");
        if(ais > 1)
            name = [NSString stringWithFormat:NSLocalizedString(@"names.chip.n", @"Chip %d"), i + 1];
        
        GorillaLayer *gorilla = [[GorillaLayer alloc] initWithName:name type:GorillasPlayerTypeAI];
        [gorillas addObject:gorilla];
        [gorilla release];
    }
    
    // When there are AIs in the game, show their difficulity.
    if (ais)
        [[GorillasAppDelegate get].uiLayer message:[GorillasConfig get].levelName];
    
    // Reset the game field and start the game.
    //[buildingsLayer stopPanning];
    [self reset];
    [cityLayer startGame];
}


-(void) updateStateHitGorilla:(BOOL)hitGorilla hitBuilding:(BOOL)hitBuilding offScreen:(BOOL)offScreen throwSkill:(float)throwSkill {
    
    if (offScreen)
        [[[GorillasAppDelegate get] hudLayer] message:[GorillasConfig get].offMessage
                                             duration:4 isImportant:NO];
    else if(hitGorilla && !cityLayer.hitGorilla.alive)
        [[[GorillasAppDelegate get] hudLayer] message:[NSString stringWithFormat:[GorillasConfig get].hitMessage,
                                                       activeGorilla.name, cityLayer.hitGorilla.name]
                                             duration:4 isImportant:NO];

    if (hitGorilla) {
        // Gorilla hit a gorilla.
        
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
                if(![self isEnabled:GorillasFeatureTeam]
                   && cityLayer.hitGorilla != activeGorilla)
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
            
            NSString *oldLevel = [GorillasConfig get].levelName;
            if(score > 0)
                [[GorillasConfig get] levelUp];
            else
                [[GorillasConfig get] levelDown];
            
            // Message in case we level up.
            if(![oldLevel isEqualToString:[GorillasConfig get].levelName]) {
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
            
            [[[GorillasAppDelegate get] hudLayer] updateHudWithScore:score skill:0];
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
    }
    
    else if (hitBuilding || offScreen) {
        // Gorilla missed gorilla: either hit building or threw off screen.
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
            [[GorillasAppDelegate get].hudLayer updateHudWithScore:score skill:0];
            
            if(score)
                [cityLayer message:[NSString stringWithFormat:@"%+d", score] on:cityLayer.bananaLayer.banana];
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
    
    [self endGame];
}


-(void) endGame {
    
    [self setPausedSilently:NO];

    // FIXME: Hack to avoid issue with stopGame removing parent from throw smoke (bananaLayer)
    // This causes the smoke's step: that occurs later in the event processing queue that
    // triggered this call to reference a dealloced parent (bananaLayer).
    //[self schedule:@selector(endGameFix:)];
    [cityLayer stopGame];
}


-(void) endGameFix:(ccTime)dt {
    
    [self unschedule:@selector(endGameFix:)];
    [cityLayer stopGame];
}


#pragma mark Internal

-(id) init {
    
	if (!(self = [super init]))
		return self;

    running = NO;
    
    IntervalAction *l       = [MoveBy actionWithDuration:.05f position:ccp(-3, 0)];
    IntervalAction *r       = [MoveBy actionWithDuration:.05f position:ccp(6, 0)];
    shakeAction             = [[Sequence actions:l, r, l, l, r, l, r, l, l, nil] retain];
    
    // Set up our own layer.
    self.anchorPoint        = ccp(0.5f, 0.5f);
    
    // Sky, buildings and wind.
    cityLayer               = [[CityLayer alloc] init];
    skyLayer                = [[SkyLayer alloc] init];
    panningLayer            = [[PanningLayer alloc] init];
    panningLayer.position   = ccp(0, 0);
    [panningLayer addChild:cityLayer z:0];
    [panningLayer addChild:skyLayer z:-5];
    [self addChild:panningLayer];
    
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
            
            if ([[GorillasConfig get].visualFx boolValue] && random() % 100 == 0) {
                // 1% chance to start snow/rain when weather is enabled.
            
                switch (random() % 2) {
                    case 0:
                        weather = [[ParticleRain alloc] init];
                        weather.emissionRate    = 60;
                        weather.startSizeVar    = 1.5f;
                        weather.startSize       = 3;
                        break;
                    
                    case 1:
                        weather = [[ParticleSnow alloc] init];
                        weather.speed           = 10;
                        weather.emissionRate    = 3;
                        weather.startSizeVar    = 3;
                        weather.startSize       = 4;
                        break;
                        
                    default:
                        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                                       reason:@"Unsupported weather type selected." userInfo:nil];
                }
                
                weather.posVar = ccp(field.size.width / 2, weather.posVar.y);
                weather.position = ccp(field.origin.x + field.size.width / 2, field.origin.y + field.size.height); // Space above screen.
                [panningLayer addChild:weather z:-3 /*parallaxRatio:ccp(1.3f, 1.8f) positionOffset:ccp(self.contentSize.width / 2,
                                                                                                       self.contentSize.height / 2)*/];

                [windLayer registerSystem:weather affectAngle:YES];
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


-(void) randomEncounter:(ccTime)dt {

    if(!running)
        return;

    // Need to refactor some bad logic about setting projectile as cleared before this'll work.
    //    if(random() % 1 == 0) {
    //        BananaLayer *egg = [[BananaLayer alloc] init];
    //        [egg setModel:GorillasProjectileModelEasterEgg];
    //
    //        CGSize winSize = [[Director sharedDirector] winSize];
    //        [egg throwFrom:ccp(winSize.width / 2 - buildingsLayer.position.x, winSize.height * 2)
    //          withVelocity:ccp(0, 0)];
    //        
    //        [buildingsLayer addChild:egg z:2];
    //        [egg release];
    //    }
}


-(void) started {
    
    running = YES;

    [self setPausedSilently:NO];

    if ([[GorillasConfig get].voice boolValue])
        [[GorillasAudioController get] playEffectNamed:@"Go"];
}


-(void) stopped {
    
    running = NO;
    
    [activeGorilla release];
    activeGorilla = nil;
    
    if([panningLayer position].x != 0 || [panningLayer position].y != 0)
        [panningLayer runAction:[MoveTo actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]
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
