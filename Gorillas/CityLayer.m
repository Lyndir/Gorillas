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
//  CityLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "CityLayer.h"
#import "BuildingsLayer.h"
#import "ExplosionsLayer.h"
#import "GorillasAppDelegate.h"
#import "ShadeTo.h"
#import "PearlGLUtils.h"


@interface CityLayer (Private)

- (void)endGameCallback;

@end


@implementation CityLayer

@synthesize bananaLayer, hitGorilla;


-(id) init {
    dbg(@"CityLayer init");
    
    if (!(self = [super init]))
        return self;
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    _anchorPoint = ccp(0.5f, 0.5f);
    [self setContentSize:s];
    self.ignoreAnchorPointForPosition = YES;
    self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
    
#if DEBUG_COLLISION
    dbgTraceStep    = 5;
    dbgPathMaxInd   = 50;
    dbgPathCurInd   = 0;
    dbgPath         = calloc(dbgPathMaxInd, sizeof(CGPoint));
    dbgAIMaxInd   = 1;
    dbgAICurInd   = 0;
    dbgAI           = calloc(dbgAIMaxInd, sizeof(GorillaLayer *));
    dbgAIVect       = calloc(dbgAIMaxInd, sizeof(CGPoint));
#endif
    
    throwHints      = [[NSMutableArray alloc] initWithCapacity:2];
    
    holes           = nil;
    explosions      = nil;
    
    // Must reset before entering the scene; others' onEnter depends on us being done.
    buildings = nil;
    buildingsCount = 4;
    [self addChild:nonParallaxLayer = [[CCLayer alloc] init] z:1 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
    [self reset];
    
    return self;
}

-(void) addChild: (CCNode*) child z:(NSInteger)z {
    
    [nonParallaxLayer addChild:child z:z];
}


-(void) reset {
    dbg(@"CityLayer reset");
    
    // Clean up.
    [self stopAllActions];
    
    if (holes) {
        [holes removeFromParentAndCleanup:YES];
        [holes release];
    }
    if (explosions) {
        [explosions removeFromParentAndCleanup:YES];
        [explosions release];
    }
    if (buildings) {
        for (NSUInteger b = 0; b < buildingsCount; ++b) {
            [buildings[b] removeFromParentAndCleanup:YES];
            [buildings[b] release];
        }
        free(buildings);
    }
    
    // Construct city.
    holes = [[HolesLayer alloc] init];
    [nonParallaxLayer addChild:holes z:-1];
    explosions = [[ExplosionsLayer alloc] init];
    [nonParallaxLayer addChild:explosions z:4];
    buildings = calloc(buildingsCount, sizeof(BuildingsLayer*));
    
    for (NSInteger b = (signed)buildingsCount - 1; b >= 0; --b) {
        float lightRatio = MAX(-1, -((float)b / buildingsCount) * 1.5f);
        
        buildings[b] = [[BuildingsLayer alloc] initWithWidthRatio:(5 - b) / 5.0f heightRatio:1 + (b / 2.0f) lightRatio:lightRatio];
        if (b)
            [self addChild:buildings[b] z:-2 - (NSInteger)b parallaxRatio:ccp((5 - b) / 5.0f, (10 - b) / 10.0f) positionOffset:CGPointZero];
        else
            [nonParallaxLayer addChild:buildings[b] z:1];
    }
}


-(void) message:(NSString *)msg on:(CCNode *)node {
    
    if(msgLabel) {
        [msgLabel stopAllActions];
        [msgLabel setString:msg];
    }
    
    else {
        msgLabel = [[CCLabelTTF alloc] initWithString:msg
                                             fontName:[GorillasConfig get].fixedFontName
                                             fontSize:[[GorillasConfig get].fontSize intValue]
                                           dimensions:CGSizeMake(1000, [[GorillasConfig get].fontSize intValue] + 5)
                                           hAlignment:kCCTextAlignmentCenter];
        
        [nonParallaxLayer addChild:msgLabel z:9];
    }
    
    [msgLabel setPosition:ccp([node position].x, [node position].y + [node contentSize].height + [[GorillasConfig get].fontSize intValue])];
    
    // Make sure label remains on screen.
    CGSize winSize = [CCDirector sharedDirector].winSize;
    if(![[GorillasConfig get].followThrow boolValue]) {
        if([msgLabel position].x < [[GorillasConfig get].fontSize intValue] / 2)                 // Left edge
            [msgLabel setPosition:ccp([[GorillasConfig get].fontSize intValue] / 2, [msgLabel position].y)];
        if([msgLabel position].x > winSize.width - [[GorillasConfig get].fontSize intValue] / 2) // Right edge
            [msgLabel setPosition:ccp(winSize.width - [[GorillasConfig get].fontSize intValue] / 2, [msgLabel position].y)];
        if([msgLabel position].y < [[GorillasConfig get].fontSize intValue] / 2)                 // Bottom edge
            [msgLabel setPosition:ccp([msgLabel position].x, [[GorillasConfig get].fontSize intValue] / 2)];
        if([msgLabel position].y > winSize.width - [[GorillasConfig get].fontSize intValue] * 2) // Top edge
            [msgLabel setPosition:ccp([msgLabel position].x, winSize.height - [[GorillasConfig get].fontSize intValue] * 2)];
    }
    
    // Color depending on whether message starts with -, + or neither.
    if([msg hasPrefix:@"+"])
        [msgLabel setColor:ccc3l(0x66CC66)];
    else if([msg hasPrefix:@"-"])
        [msgLabel setColor:ccc3l(0xCC6666)];
    else
        [msgLabel setColor:ccc3l(0xFFFFFF)];
    
    // Animate the label to fade out.
    [msgLabel runAction:[CCSpawn actions:
                         [CCFadeOut actionWithDuration:3],
                         [CCSequence actions:
                          [CCDelayTime actionWithDuration:1],
                          [CCMoveBy actionWithDuration:2 position:ccp(0, [[GorillasConfig get].fontSize intValue] * 2)],
                          nil],
                         nil]];
}


-(void) draw {
    
    [super draw];
    
    CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"CityLayer - draw");
    CC_NODE_DRAW_SETUP();
    
#if DEBUG_COLLISION
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGRect field = [self fieldInSpaceOf:self];
    int pCount = (field.size.width / dbgTraceStep + 1)
    * (winSize.height / dbgTraceStep + 1);
    CGPoint *hgp = calloc(pCount, sizeof(CGPoint));
    CGPoint *hep = calloc(pCount, sizeof(CGPoint));
    NSUInteger hgc = 0, hec = 0;
    
    for(float x = field.origin.x; x < field.origin.x + field.size.width; x += dbgTraceStep)
        for(float y = field.origin.y; y < field.origin.y + field.size.height; y += dbgTraceStep) {
            CGPoint pos = ccp(x, y);
            
            BOOL hg = NO, he = NO;
            he = [holes isHoleAtWorld:pos];
            
            for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
                if((hg = [gorilla hitsGorilla:pos]))
                    break;
            
            if(hg)
                hgp[hgc++] = pos; //ccpMult(pos, CC_CONTENT_SCALE_FACTOR()); /* pt to px */
            else if(he)
                hep[hec++] = pos; //ccpMult(pos, CC_CONTENT_SCALE_FACTOR()); /* pt to px */
        }
    
    DrawPointsAt(hgp, hgc, ccc4l(0x00FF00FF));
    DrawPointsAt(hep, hec, ccc4l(0xFF0000FF));
    DrawPointsAt(dbgPath, dbgPathMaxInd, ccc4l(0xFFFF00FF));
    free(hgp);
    free(hep);
#endif
    
    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureCheat]) {
        CGPoint winSize = ccpFromSize([CCDirector sharedDirector].winSize);
        
        for(NSUInteger i = 0; i < [[GorillasAppDelegate get].gameLayer.gorillas count]; ++i) {
            GorillaLayer *gorilla = [[GorillasAppDelegate get].gameLayer.gorillas objectAtIndex:i];
            if(![gorilla alive])
                continue;
            
            CGPoint fromPx = gorilla.position; // ccpMult(gorilla.position, CC_CONTENT_SCALE_FACTOR()); /* pt to px */;
            CGPoint toPx   = ccpAdd(fromPx, ccpCompMult(throwHistory[i], winSize));
            
            if(!CGPointEqualToPoint(toPx, CGPointZero)) {
                ccColor4B color = ccc4l([[GorillasConfig get].windowColorOff unsignedLongValue] & 0xffffff33UL);
                ccDrawColor4F(color.r, color.g, color.b, color.a);
                ccDrawLine(fromPx, toPx); // make 3 wide
            }
        }
    }
    
    CHECK_GL_ERROR_DEBUG();
    CC_INCREMENT_GL_DRAWS(1);
    CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"CityLayer - draw");
}


-(void) tryNextGorilla:(ccTime)dt {
    
    [self unschedule:@selector(tryNextGorilla:)];
    [self nextGorilla];
}


-(void) nextGorilla {
    
    [GorillasAppDelegate get].gameLayer.running = YES;
    
    // Make sure the game hasn't ended.
    if (![[GorillasAppDelegate get].gameLayer checkGameStillOn]) {
        [[GorillasAppDelegate get].gameLayer endGame];
        return;
    }
    
    // Schedule to retry later if game is paused.
    if ([GorillasAppDelegate get].gameLayer.paused) {
        [self schedule:@selector(tryNextGorilla:) interval:0.1f];
        return;
    }
    
    // Save the active gorilla's zoom.
    [GorillasAppDelegate get].gameLayer.activeGorilla.zoom = [GorillasAppDelegate get].gameLayer.panningLayer.scale;
    
    // Active gorilla's turn is over.
    ++[GorillasAppDelegate get].gameLayer.activeGorilla.turns;
    [GorillasAppDelegate get].gameLayer.activeGorilla.active = NO;
    
    // Activate the next gorilla.
    // Look for the next live gorilla; first try the next gorilla AFTER the current.
    // If none there is alive, try the first one from the beginning UNTIL the current.
    BOOL foundNextGorilla = NO;
    for (BOOL startFromAfterCurrent = YES; YES; startFromAfterCurrent = NO) {
        BOOL reachedCurrent = NO;
        
        for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas) {
            
            if(gorilla == [GorillasAppDelegate get].gameLayer.activeGorilla)
                reachedCurrent = YES;
            
            else
                if(startFromAfterCurrent) {
                    
                    // First run.
                    if(reachedCurrent && [gorilla alive]) {
                        [GorillasAppDelegate get].gameLayer.activeGorilla = gorilla;
                        foundNextGorilla = YES;
                        break;
                    }
                } else {
                    
                    // Second run.
                    if(reachedCurrent)
                        // (don't bother looking past the current in the second try)
                        break;
                    
                    else if([gorilla alive]) {
                        [GorillasAppDelegate get].gameLayer.activeGorilla = gorilla;
                        foundNextGorilla = YES;
                        break;
                    }
                }
        }
        
        if(foundNextGorilla)
            break;
        
        if(!startFromAfterCurrent) {
            // Second run didn't find any gorillas -> no gorillas available.
            err(@"No next gorilla to be found; game should've ended in previous check.");
            return;
        }
    }
    
    // Make sure the game hasn't ended.
    if (![[GorillasAppDelegate get].gameLayer checkGameStillOn]) {
        [[GorillasAppDelegate get].gameLayer endGame];
        return;
    }
    
    // Scale to the new active gorilla's saved scale.
    [[GorillasAppDelegate get].gameLayer.panningLayer scaleTo:[GorillasAppDelegate get].gameLayer.activeGorilla.zoom];
    
    // New active gorilla's turn starts.
    [GorillasAppDelegate get].gameLayer.activeGorilla.active = YES;
    
    // AI throw.
    if ([GorillasAppDelegate get].gameLayer.activeGorilla.alive && ![GorillasAppDelegate get].gameLayer.activeGorilla.human) {
        // Active gorilla is a live AI.
        NSMutableArray *enemies = [[GorillasAppDelegate get].gameLayer.gorillas mutableCopy];
        
        // Exclude from enemy list: Dead gorillas, Self, AIs when in team mode.
        for (GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas) {
            if (![gorilla alive]
                || gorilla == [GorillasAppDelegate get].gameLayer.activeGorilla
                || ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureTeam]
                    && ![gorilla human]))
                [enemies removeObject:gorilla];
        }
        
        // Pick a random target from the enemies.
        GorillaLayer *target = [enemies objectAtIndex:(unsigned)PearlGameRandom() % [enemies count]];
        [enemies release];
        
        // Aim at the target.
        CGPoint r0 = [GorillasAppDelegate get].gameLayer.activeGorilla.position;
        CGPoint v = [self calculateThrowFrom:r0
                                          to:target.position
                                  errorLevel:[[GorillasConfig get].level floatValue]];
        
        // Throw at where we aimed.
        [[ThrowController get] throwFrom:[GorillasAppDelegate get].gameLayer.activeGorilla normalizedVelocity:v];
        
#if DEBUG_COLLISION
        dbgAI[dbgAICurInd] = [GorillasAppDelegate get].gameLayer.activeGorilla;
        dbgAIVect[dbgAICurInd] = v;
        dbgAICurInd = (dbgAICurInd + 1) % dbgAIMaxInd;
#endif
    }
    
    // Throw hints.
    for (NSUInteger i = 0; i < [[GorillasAppDelegate get].gameLayer.gorillas count]; ++i) {
        GorillaLayer *gorilla = [[GorillasAppDelegate get].gameLayer.gorillas objectAtIndex:i];
        
        BOOL hintGorilla = YES;
        
        if (![[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureCheat])
            hintGorilla = NO;
        if (gorilla == [GorillasAppDelegate get].gameLayer.activeGorilla
            || ![gorilla alive])
            hintGorilla = NO;
        
        CCSprite *hint = [throwHints objectAtIndex:i];
        [hint setVisible:hintGorilla];
        [hint stopAllActions];
        
        if(hintGorilla) {
            CGPoint v = [self calculateThrowFrom:[[GorillasAppDelegate get].gameLayer.activeGorilla position]
                                              to:[gorilla position] errorLevel:0.9f];
            
            [hint setOpacity:0];
            [hint setPosition:ccpAdd([GorillasAppDelegate get].gameLayer.activeGorilla.position, v)];
            [hint runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                                                               [CCDelayTime actionWithDuration:5],
                                                               [CCFadeTo actionWithDuration:3 opacity:0x55],
                                                               [CCFadeTo actionWithDuration:3 opacity:0x00],
                                                               nil]]];
        }
    }
}


-(void) throwFrom:(GorillaLayer *)gorilla withVelocity:(CGPoint)v {
    
    // Hide all hints.
    for(CCSprite *hint in throwHints)
        if([hint visible]) {
            [hint stopAllActions];
            [hint runAction:[CCFadeTo actionWithDuration:[[GorillasConfig get].transitionDuration floatValue] opacity:0x00]];
        }
    
    // Record throw history.
    throwHistory[[[GorillasAppDelegate get].gameLayer.gorillas indexOfObject:gorilla]] = v;
}


-(CGPoint) calculateThrowFrom:(CGPoint)r0 to:(CGPoint)rt errorLevel:(CGFloat)l {
    
    float g = [[GorillasConfig get].gravity unsignedIntValue];
    float w = [[[[GorillasAppDelegate get] gameLayer] windLayer] wind];
    ccTime t = 5 * 100 / g;
    
    // Level-based error.
    NSInteger rtError = (NSInteger)((1 - l) * [CCDirector sharedDirector].winSize.width / 2);
    rt = ccp(rt.x + PearlGameRandom() % rtError - rtError / 2, rt.y + PearlGameRandom() % rtError - rtError / 2);
    t = (PearlGameRandom() % (int) ((t / 2) * l * 10)) / 10.0f + (t / 2);
    
    // Velocity vector to hit rt in t seconds.
    CGPoint v = ccp((rt.x - r0.x) / t,
                    (g * t * t - 2 * r0.y + 2 * rt.y) / (2 * t));
    
    // Wind-based modifier.
    v.x -= w * t * [[GorillasConfig get].windModifier floatValue];
    
    // Normalize velocity so it's resolution-independant.
    CGSize winSize = [CCDirector sharedDirector].winSize;
    v = ccp(v.x / winSize.width, v.y / winSize.height);
    
    return v;
}


-(BOOL) hitsGorilla:(CGPoint)pos {
    
#if DEBUG_COLLISION
    dbgPath[dbgPathCurInd] = pos;
    dbgPathCurInd = (dbgPathCurInd + 1) % dbgPathMaxInd;
#endif
    
    // Figure out if a gorilla was hit.
    for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
        if([gorilla hitsGorilla:pos]) {
            
            if(gorilla == [GorillasAppDelegate get].gameLayer.activeGorilla && !bananaLayer.clearedGorilla)
                // Disregard this hit on active gorilla because the banana didn't clear him yet.
                continue;
            
            // A gorilla was hit.
            [hitGorilla release];
            hitGorilla = [gorilla retain];
            
            return YES;
        }
    
        else
            // No hit.
            if(gorilla == [GorillasAppDelegate get].gameLayer.activeGorilla)
                // Active gorilla was not hit -> banana cleared him.
                bananaLayer.clearedGorilla = YES;
    
    // No hit.
    return NO;
}


-(BOOL) hitsBuilding:(CGPoint)pos {
    
    if ([buildings[0] hitsBuilding:pos])
        // A building was hit, but if it's in an explosion crater we
        // need to let the banana continue flying.
        return ![holes isHoleAtWorld:[self convertToWorldSpace:pos]];
    
    return NO;
}


-(void) beginGame {
    
    NSArray *gorillas = [GorillasAppDelegate get].gameLayer.gorillas;
    
    // Create enough throw hint sprites / remove needless ones.
    while([throwHints count] != [gorillas count]) {
        if([throwHints count] < [gorillas count]) {
            CCSprite *hint = [CCSprite spriteWithFile:@"fire.png"];
            [throwHints addObject:hint];
            [nonParallaxLayer addChild:hint z:0];
        }
        
        else {
            [[throwHints lastObject] removeFromParentAndCleanup:YES];
            [throwHints removeLastObject];
        }
    }
    
    // Reset throw history & throw hints.
    free(throwHistory);
    throwHistory = calloc([gorillas count], sizeof(CGPoint));
    for(NSUInteger i = 0; i < [gorillas count]; ++i) {
        throwHistory[i] = ccp(-1, -1);
        [[throwHints objectAtIndex:i] setVisible:NO];
    }
    
    // Position our gorillas.
    // Find indexA: The left boundary of allowed gorilla indexes.
    NSUInteger indexA = 0;
    for(NSUInteger b = 0; b < buildings[0].buildingCount; ++b) {
        CGPoint fieldPoint = [buildings[0] convertToWorldSpace:CGPointMake(buildings[0].buildings[b].x, 0)];
        fieldPoint = [self convertToNodeSpace:fieldPoint];
        
        if(fieldPoint.x >= 0) {
            indexA = b;
            break;
        }
    }
    // Find indexB: The right boundary of allowed gorilla indexes.
    NSUInteger indexB = indexA + [[GorillasConfig get].buildingAmount unsignedIntValue] - 1;
    // Less than or 3 gorillas, leave one building padding on the sides.
    if([gorillas count] <= 3) {
        indexA += 1;
        indexB -= 1;
    }
    // Distribute gorillas.
    NSUInteger delta    = indexB - indexA;
    if ([gorillas count] > delta) {
        err(@"Tried to start a game with more gorillas than there's room in the field.");
        return;
    }
    
    NSUInteger minSpace  = ((delta / [gorillas count]) /* share per gorilla */ - 1) /* gorilla's building */ / 2 /* padding on each side */;
    NSMutableArray *gorillasQueue = [gorillas mutableCopy];
    NSMutableArray *gorillaIndexes = [[NSMutableArray alloc] initWithCapacity: [gorillas count]];
    while ([gorillasQueue count]) {
        NSUInteger index = indexA + (unsigned)PearlGameRandom() % (delta + 1);
        BOOL validIndex = YES;
        
        // Make sure gorillas aren't too close to the edge.
        if (index - minSpace <= indexA && index + minSpace >= indexB)
            validIndex = NO;
        
        // Make sure gorillas aren't too close together.
        for (NSNumber *gorillasIndex in gorillaIndexes)
            if (ABS([gorillasIndex unsignedIntegerValue] - index) <= minSpace) {
                validIndex = NO;
                break;
            }
        
        if (validIndex) {
            [gorillaIndexes addObject:[NSNumber numberWithUnsignedInt:index]];
            [gorillasQueue removeLastObject];
        }
    }
    [gorillasQueue release];
    for(NSUInteger i = 0; i < [gorillas count]; ++i) {
        Building building = buildings[0].buildings[[(NSNumber *) [gorillaIndexes objectAtIndex:i] unsignedIntegerValue]];
        GorillaLayer *gorilla = [gorillas objectAtIndex:i];
        CGSize gorillaSize = CGSizeMake(gorilla.contentSize.width * gorilla.scale, gorilla.contentSize.height * gorilla.scale);
        
        gorilla.position = ccp(building.x + building.size.width / 2, building.size.height + gorillaSize.height / 2);
        [gorilla runAction:[CCFadeIn actionWithDuration:1]];
        [nonParallaxLayer addChild:gorilla z:3];
    }
    [gorillaIndexes release];
    // Add a banana to the scene.
    if(bananaLayer) {
        err(@"Tried to start a game while a(n old?) banana still existed.");
        return;
    }
    bananaLayer = [[BananaLayer alloc] init];
    [nonParallaxLayer addChild:bananaLayer z:2];
    
    [[GorillasAppDelegate get].gameLayer began];
}


-(void) endGame {
    
    [hitGorilla release];
    hitGorilla = nil;
    
    if(bananaLayer) {
        [bananaLayer removeFromParentAndCleanup:YES];
        [bananaLayer release];
        bananaLayer = nil;
    }
    
    NSUInteger runningActions = 0;
    for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
        if((runningActions = [gorilla numberOfRunningActions]))
            break;
    
    if(runningActions && ![GorillasAppDelegate get].gameLayer.configuring) {
        [[GorillasAppDelegate get].gameLayer.panningLayer scrollToCenter:[GorillasAppDelegate get].gameLayer.activeGorilla.position
                                                              horizontal:YES];
        [self runAction:[CCSequence actions:
                         [CCDelayTime actionWithDuration:5.2f],
                         [CCCallFunc actionWithTarget:self selector:@selector(endGameCallback)],
                         nil]];
    }
    else
        [self endGameCallback];
}


-(void) endGameCallback {
    
    for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
        [gorilla killDead];
    [GorillasAppDelegate get].gameLayer.activeGorilla = nil;
    
    [[GorillasAppDelegate get].gameLayer ended];
}


-(void) explodeAt: (CGPoint)point isGorilla:(BOOL)isGorilla {
    
    dbg(@"Explosion at: %@", NSStringFromCGPoint(point));
    
    CGPoint worldPoint = [self convertToWorldSpace:point];
    [holes addHoleAtWorld:worldPoint];
    [explosions addExplosionAtWorld:worldPoint hitsGorilla:isGorilla];
}


-(CGRect) fieldInSpaceOf:(CCNode *)node {
    
    Building firstBuilding = buildings[0].buildings[0];
    Building lastBuilding = buildings[0].buildings[buildings[0].buildingCount - 1];
    
    CGPoint bottomLeft = [buildings[0] convertToWorldSpace:CGPointMake(firstBuilding.x, 0)];
    CGPoint topRight = [buildings[0] convertToWorldSpace:CGPointMake(lastBuilding.x + lastBuilding.size.width, 0)];
    topRight.y = [CCDirector sharedDirector].winSize.height * 2.0f;
    
    if (node != nil) {
        bottomLeft = [node convertToNodeSpace:bottomLeft];
        topRight = [node convertToNodeSpace:topRight];
    }
    
    return CGRectMake(bottomLeft.x, bottomLeft.y, topRight.x - bottomLeft.x, topRight.y - bottomLeft.y);
}

- (BuildingsLayer *)buildingLayer {
    
    return buildings[0];
}


-(void) dealloc {
    
    [msgLabel release];
    msgLabel = nil;
    
    if (buildings) {
        for (NSUInteger b = 0; b < 4; ++b)
            [buildings[b] release];
        free(buildings);
        buildings = nil;
    }
    
    [holes release];
    holes = nil;
    
    [explosions release];
    explosions = nil;
    
    [bananaLayer release];
    bananaLayer = nil;
    
    [hitGorilla release];
    hitGorilla = nil;
    
    [throwHints release];
    throwHints = nil;
    
    free(throwHistory);
    throwHistory = nil;
    
#if DEBUG_COLLISION
    free(dbgPath);
    free(dbgAI);
    free(dbgAIVect);
#endif
    
    [super dealloc];
}


@end
