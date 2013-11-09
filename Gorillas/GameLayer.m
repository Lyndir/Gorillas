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
#import "PearlCCRemove.h"
#import "CityTheme.h"
#import "InteractionLayer.h"
#import "TestFlight.h"
#import "LocalyticsSession.h"

@interface GameLayer()

- (void)setPausedSilently:(BOOL)paused;
- (void)updateWeather:(ccTime)dt;
- (void)randomEncounter:(ccTime)dt;

@end

@implementation GameLayer {

@private
    BOOL _randomCity;
    NSUInteger _humans;
    NSUInteger _ais;

    CCAction *_shakeAction;
}



#pragma mark Properties

- (BOOL)isSinglePlayer {

    return _humans == 1;
}

- (BOOL)isEnabled:(GorillasFeature)feature {

    if (!self.singlePlayer) {
        if (feature == GorillasFeatureScore || feature == GorillasFeatureSkill || feature == GorillasFeatureLevel)
                // Features not supported in multiplayer.
            return NO;
    }

    return _mode & feature? YES: NO;
}

- (void)setPaused:(BOOL)paused {

    if (paused == _paused)
            // Nothing changed.
        return;

    [self setPausedSilently:paused];

    if (_running) {
        if (_paused)
            [[GorillasAppDelegate get].uiLayer message:PearlLocalize( @"messages.paused" )];
        else
            [[GorillasAppDelegate get].uiLayer message:PearlLocalize( @"messages.unpaused" )];
    }
}

- (void)setPausedSilently:(BOOL)paused {

    _paused = paused;

    if (_paused) {
        if (_running)
            [self scaleTimeTo:0];
        [[GorillasAppDelegate get] hideHud];
        [_windLayer runAction:[CCFadeTo actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]
                                                   opacity:0x00]];
    }
    else {
        [self scaleTimeTo:1.0f];
        [[GorillasAppDelegate get] popAllLayers];
        [[GorillasAppDelegate get] revealHud];
        [_windLayer runAction:[CCFadeTo actionWithDuration:[[GorillasConfig get].transitionDuration floatValue]
                                                   opacity:0xFF]];
    }
}

- (void)scaleTimeTo:(float)aTimeScale {

    [_scaleTimeAction tweenKeyPath:@"timeScale" to:aTimeScale];
}

- (void)configureGameWithMode:(GorillasMode)aMode randomCity:(BOOL)aRandomCity
                    playerIDs:(NSArray *)playerIDs localHumans:(NSUInteger)localHumans ais:(NSUInteger)ais {

    _configuring = YES;

    [self stopGame];

    _mode = aMode;
    _randomCity = aRandomCity;
    _humans = localHumans + [playerIDs count];
    _ais = ais;

#ifndef DEBUG
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @try {
            [TestFlight passCheckpoint:PearlString(@"GorillasNewGame_%@", [GorillasConfig nameForMode:_mode])];
        }
        @catch (NSException *exception) {
            err(@"TestFlight: %@", exception);
        }
        @try {
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"New Game" attributes:
             [NSDictionary dictionaryWithObjectsAndKeys:
              [GorillasConfig nameForMode:_mode],
              @"mode",
              [NSNumber numberWithUnsignedInt:localHumans],
              @"localHumans",
              [NSNumber numberWithUnsignedInt:[playerIDs count]],
              @"remoteHumans",
              [NSNumber numberWithUnsignedInt:ais],
              @"ais",
              nil]];
        }
        @catch (NSException *exception) {
            err(@"Localytics: %@", exception);
        }
    });
#endif

    [[GorillasAppDelegate get].hudLayer reset];

    // Create gorillas array.
    [_gorillas removeAllObjects];
    if (!_gorillas)
        _gorillas = [[NSMutableArray alloc] initWithCapacity:_humans + _ais];

    // Prepare.
    [GorillaLayer prepareCreation];

    // Add humans to the game.
    if (playerIDs) {
        for (NSString *playerID in playerIDs)
            [_gorillas addObject:[GorillaLayer gorillaWithType:GorillasPlayerTypeHuman playerID:playerID]];

        [GKPlayer loadPlayersForIdentifiers:playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
            if (error)
            err(@"While loading player information: %@", error);

            for (GKPlayer *player in players)
                for (GorillaLayer *gorilla in _gorillas)
                    if ([gorilla.playerID isEqualToString:player.playerID])
                        gorilla.player = player;
        }];
    }
    else
        for (NSUInteger i = 0; i < _humans; ++i)
            [_gorillas addObject:[GorillaLayer gorillaWithType:GorillasPlayerTypeHuman playerID:nil]];

    // Add AIs to the game.
    for (NSUInteger i = 0; i < _ais; ++i)
        [_gorillas addObject:[GorillaLayer gorillaWithType:GorillasPlayerTypeAI playerID:nil]];

    _configuring = NO;
}


#pragma mark Interact

- (void)reset {

    dbg(@"GameLayer reset");

    [_skyLayer reset];
    [_panningLayer reset];
    [_cityLayer reset];
    [_windLayer reset];
    for (GorillaLayer *gorilla in self.gorillas)
        [gorilla reset];
}

- (void)shake {

    if ([[GorillasConfig get].vibration boolValue])
        [GorillasAudioController vibrate];

    if (![_shakeAction isDone])
        [_cityLayer stopAction:_shakeAction];

    [_cityLayer runAction:_shakeAction];
}

- (void)startGame {

    dbg(@"GameLayer startGame");

    if (!_mode) {
        err(@"Tried to start a game without configuring it first.");
        return;
    }

    if (_running) {
        err(@"Tried to start a game while one's still running.");
        return;
    }

    if (_randomCity)
        [GorillasConfig get].cityTheme = [CityTheme getThemeNames][PearlGameRandom() % [[CityTheme getThemeNames] count]];
    else
        [self reset];

    // When there are AIs in the game, show their difficulity.
    if (_ais)
        [[GorillasAppDelegate get].uiLayer message:[GorillasConfig nameForLevel:[GorillasConfig get].level]];

    self.started = YES;

    [self.cityLayer beginGame];
}

- (void)updateStateForThrow:(GThrow)throw withSkill:(float)throwSkill {

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

                if (humanGorillas != 1)
                        // Don't deduct score for non-teamed multiplayer.
                    considderMiss = NO;
            }

            if (considderMiss) {
                int64_t scoreDelta = (int64_t)([[GorillasConfig get].level floatValue] * [[GorillasConfig get].missScore intValue]);

                if (scoreDelta) {
                    [[GorillasConfig get] recordScoreDelta:scoreDelta forMode:_mode];
                    [[GorillasAppDelegate get].hudLayer highlightGood:scoreDelta > 0];

                    [_cityLayer message:[NSString stringWithFormat:@"%+lld", scoreDelta] on:_cityLayer.bananaLayer.banana];
                }
            }

            break;
        }

        case ThrowEndHitGorilla: {
            [_cityLayer.hitGorilla kill];

            if (!_cityLayer.hitGorilla.alive)
                [[[GorillasAppDelegate get] hudLayer] message:[[GorillasConfig get] messageForHitBy:_activeGorilla on:_cityLayer.hitGorilla]
                                                     duration:4 isImportant:NO];

            int64_t scoreDelta = 0;
            BOOL dance = NO;
            if ([_activeGorilla human]) {
                // Human hits ...

                if ([_cityLayer.hitGorilla human]) {
                    // ... Human.
                    if ([self isEnabled:GorillasFeatureTeam]
                        || _cityLayer.hitGorilla == _activeGorilla)
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
            }
            else {
                // AI hits ...

                if ([_cityLayer.hitGorilla human]) {
                    // ... Human.
                    if (![self isEnabled:GorillasFeatureTeam])
                            // In team mode, deduct score.
                        scoreDelta = [GorillasConfig get].deathScore;

                    dance = YES;
                }
                else {
                    // ... AI.
                    if (![self isEnabled:GorillasFeatureTeam] && _cityLayer.hitGorilla != _activeGorilla)
                            // Not in team and not suiciding.
                        dance = YES;
                }
            }

            // Update Skill.
            if ([self isEnabled:GorillasFeatureSkill]) {
                float skill = 0;

                if ([_activeGorilla human]) {
                    // Human skill.
                    [GorillasConfig get].skill = @(skill = fminf( 0.99f, [[GorillasConfig get].skill floatValue] / 2 + throwSkill ));
                }
                else
                        // AI skill.
                    skill = [[GorillasConfig get].level floatValue];

                // Apply oneshot bonus.
                if (_activeGorilla.turns == 0) {
                    [[GorillasAppDelegate get].uiLayer message:PearlLocalize( @"messages.oneshot" )];
                    skill *= [[GorillasConfig get].bonusOneShot floatValue];
                }

                if (scoreDelta)
                    scoreDelta += (int64_t)((Sign(scoreDelta)) * [[GorillasConfig get].bonusSkill floatValue] * skill);
            }

            // Update Level.
            if ([self isEnabled:GorillasFeatureLevel]) {
                scoreDelta *= [[GorillasConfig get].level doubleValue];

                NSString *oldLevel = [GorillasConfig nameForLevel:[GorillasConfig get].level];
                if (scoreDelta > 0)
                    [[GorillasConfig get] levelUp];
                else
                    [[GorillasConfig get] levelDown];

                // Message in case we level up.
                if (![oldLevel isEqualToString:[GorillasConfig nameForLevel:[GorillasConfig get].level]]) {
                    if (scoreDelta > 0) {
                        [[GorillasAppDelegate get].uiLayer message:PearlLocalize( @"messages.level.up" )];
                        if ([[GorillasConfig get].voice boolValue])
                            [[GorillasAudioController get] playEffectNamed:@"Level_Up"];
                    }
                    else {
                        [[GorillasAppDelegate get].uiLayer message:PearlLocalize( @"messages.level.down" )];
                        if ([[GorillasConfig get].voice boolValue])
                            [[GorillasAudioController get] playEffectNamed:@"Level_Down"];
                    }
                }
            }

            // Update score.
            if ([self isEnabled:GorillasFeatureScore] && scoreDelta) {
                [[GorillasConfig get] recordScoreDelta:scoreDelta forMode:_mode];

                [[[GorillasAppDelegate get] hudLayer] highlightGood:scoreDelta > 0];
                [_cityLayer message:[NSString stringWithFormat:@"%+lld", scoreDelta] on:_cityLayer.hitGorilla];
            }

            // Check whether any gorillas are left.
            int liveGorillaCount = 0;
            GorillaLayer *liveGorilla = nil;
            for (GorillaLayer *_gorilla in _gorillas)
                if ([_gorilla alive]) {
                    liveGorillaCount++;
                    liveGorilla = _gorilla;
                }

            // If gorilla did something benefitial: cheer or dance.
            if (dance) {
                if ([_cityLayer.hitGorilla alive])
                    [_activeGorilla danceHit];
                else if (liveGorillaCount > 2)
                    [_activeGorilla danceKill];
                else
                    [_activeGorilla danceVictory];
            }

            // If 0 or 1 gorillas left; show who won and stop the game.
            if (liveGorillaCount < 2) {
                if (liveGorillaCount == 1)
                    [[[GorillasAppDelegate get] hudLayer]
                            message:PearlLocalize( @"messages.wins", [liveGorilla name] ) duration:4 isImportant:NO];
                else
                    [[[GorillasAppDelegate get] hudLayer] message:PearlLocalize( @"messages.tie" ) duration:4 isImportant:NO];
            }

            // Reset the wind.
            [_windLayer reset];

            break;
        }
    }
}

- (BOOL)checkGameStillOn {

    if (_running) {
        // Check to see if there are any opponents left.
        NSUInteger liveGorillas = 0;
        NSUInteger liveEnemyGorillas = 0;
        for (GorillaLayer *gorilla in _gorillas) {
            if (![gorilla alive])
                continue;

            // Gorilla is alive.
            ++liveGorillas;

            // Gorilla is on active gorilla's team.
            if (gorilla.human != _activeGorilla.human)
                ++liveEnemyGorillas;
        }

        if (liveGorillas < 2)
            _running = NO;

        if ([self isEnabled:GorillasFeatureTeam]
            && !liveEnemyGorillas)
            _running = NO;
    }

    return _running;
}

- (void)stopGame {

    _mode = 0;
    _humans = 0;
    _ais = 0;

    if ([GorillasAppDelegate get].netController.match)
        [[GorillasAppDelegate get].netController endMatchForced:NO];

    [self endGame];
}

- (void)endGame {

    _running = NO;
    //[self setPausedSilently:NO];

    [_cityLayer endGame];
}


#pragma mark Internal

- (id)init {

    if (!(self = [super init]))
        return self;

    _timeScale = 1.0f;
    _mode = GorillasModeClassic;
    _running = NO;

    CCActionInterval *l = [CCMoveBy actionWithDuration:.05f position:ccp( -3, 0 )];
    CCActionInterval *r = [CCMoveBy actionWithDuration:.05f position:ccp( 6, 0 )];
    _shakeAction = [CCSequence actions:l, r, l, l, r, l, r, l, l, nil];

    // Set up our own layer.
    self.anchorPoint = ccp( 0.5f, 0.5f );

    // Sky, buildings and wind.
    _cityLayer = [[CityLayer alloc] init];
    _skyLayer = [[SkyLayer alloc] init];
    CCSprite *light = [CCSprite spriteWithFile:@"fire.png"];
    light.position = ccp( 240, -500 );
    light.scale = 150;
    light.color = ccc3( 0xff, 0xff, 0xcc );
    light.opacity = 0x55;
    _panningLayer = [[PanningLayer alloc] init];
    _panningLayer.position = CGPointZero;
    [_panningLayer addChild:[InteractionLayer node] z:1];
    [_panningLayer addChild:_cityLayer z:0];
    [_panningLayer addChild:light z:-1];
    [self addChild:_panningLayer z:0];
    [self addChild:_skyLayer z:-5];

    _windLayer = [[WindLayer alloc] init];
    _windLayer.position = ccp( self.contentSize.width / 2, self.contentSize.height - 15 );
    [self addChild:_windLayer z:5];

    _scaleTimeAction = [[PearlCCAutoTween alloc] initWithDuration:0.5f];
    _scaleTimeAction.tag = kCCActionTagIgnoreTimeScale;
    [self runAction:_scaleTimeAction];

    _paused = YES;

    return self;
}

- (void)onEnter {

    [super onEnter];

    [self setPausedSilently:YES];
    [[GorillasAppDelegate get] showMainMenu];

    [self schedule:@selector(updateWeather:) interval:1];
    [self schedule:@selector(randomEncounter:) interval:1];
}

- (void)onExit {

    [super onExit];

    [self setPausedSilently:YES];
}

- (void)updateWeather:(ccTime)dt {

    if (!_backWeather.emissionRate) {
        // If not emitting ..

        if (_backWeather.active) {
            // Stop active system.
            [_backWeather stopSystem];
            [_frontWeather stopSystem];
        }

        if (_backWeather.particleCount == 0) {
            // If system has no particles left alive ..

            // Remove & release it.
            [_windLayer unregisterSystem:_backWeather];
            [_backWeather removeFromParentAndCleanup:YES];
            _backWeather = nil;
            [_windLayer unregisterSystem:_frontWeather];
            [_frontWeather removeFromParentAndCleanup:YES];
            _frontWeather = nil;

            CGRect field = [_cityLayer fieldInSpaceOf:_panningLayer];

            if (PearlGameRandomFor(GorillasGameRandomWeather) % 100 == 0) {
                // 1% chance to start snow/rain when weather is enabled.

                switch (PearlGameRandomFor(GorillasGameRandomWeather) % 2) {
                    case 0:
                        _backWeather = [[CCParticleRain alloc] init];
                        _backWeather.emissionRate = 60;
                        _backWeather.startSizeVar = 0.5f;
                        _backWeather.startSize = 1;

                        _frontWeather = [[CCParticleRain alloc] init];
                        _frontWeather.emissionRate = 60;
                        _frontWeather.startSizeVar = 1.5f;
                        _frontWeather.startSize = 3;
                        break;

                    case 1:
                        _backWeather = [[CCParticleSnow alloc] init];
                        _backWeather.speed = 10;
                        _backWeather.emissionRate = 3;
                        _backWeather.startSizeVar = 2;
                        _backWeather.startSize = 2;

                        _frontWeather = [[CCParticleSnow alloc] init];
                        _frontWeather.speed = 10;
                        _frontWeather.emissionRate = 3;
                        _frontWeather.startSizeVar = 3;
                        _frontWeather.startSize = 4;
                        break;

                    default:
                        err(@"Unsupported weather type selected.");
                        return;
                }

                _backWeather.positionType = kCCPositionTypeGrouped;
                _backWeather.posVar = ccp( field.size.width / 2, _backWeather.posVar.y );
                _backWeather.position = ccp( field.origin.x + field.size.width / 2,
                        field.origin.y + field.size.height ); // Space above screen.
                [_panningLayer addChild:_backWeather z:-1];
                [_windLayer registerSystem:_backWeather affectAngle:YES];

                _frontWeather.positionType = kCCPositionTypeGrouped;
                _frontWeather.posVar = ccp( field.size.width / 2, _frontWeather.posVar.y );
                _frontWeather.position = ccp( field.origin.x + field.size.width / 2,
                        field.origin.y + field.size.height ); // Space above screen.
                [_panningLayer addChild:_frontWeather];
                [_windLayer registerSystem:_frontWeather affectAngle:YES];
            }
        }
    }

    else {
        // System is alive, let the emission rate evolve.
        float rate = [_backWeather emissionRate] + (PearlGameRandomFor(GorillasGameRandomWeather) % 40 - 15) / 10.0f;
        float max = [_backWeather isKindOfClass:[CCParticleRain class]]? 200: 100;
        rate = fminf( fmaxf( 0, rate ), max );

        if (PearlGameRandomFor(GorillasGameRandomWeather) % 100 == 0)
                // 1% chance for a full stop.
            rate = 0;

        [_backWeather setEmissionRate:rate];
        [_frontWeather setEmissionRate:rate];
    }
}

- (void)randomEncounter:(ccTime)dt {

    if (!_running)
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

- (void)began {

    [self setPausedSilently:NO];

    if ([GorillasAppDelegate get].netController.match)
        [[GorillasAppDelegate get].netController sendBecameReady];
    else
        [self.cityLayer nextGorilla];
}

- (void)ended {

    _started = NO;

    _activeGorilla = nil;

    [_panningLayer scrollToCenter:CGPointZero horizontal:YES];

    if (!_configuring)
        [[GorillasAppDelegate get] showMainMenu];
}

@end
