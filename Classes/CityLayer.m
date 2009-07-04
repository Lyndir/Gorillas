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
#import "Remove.h"


@interface CityLayer (Private)

- (void)showAim;
-(void) stopGameCallback;

@end


@implementation CityLayer

@synthesize aim, bananaLayer, hitGorilla;


-(id) init {
    
    if (!(self = [super init]))
		return self;

#ifdef _DEBUG_
    dbgTraceStep    = 2;
    dbgPathMaxInd   = 50;
    dbgPathCurInd   = 0;
    dbgPath         = malloc(sizeof(CGPoint) * dbgPathMaxInd);
    dbgAIMaxInd   = 1;
    dbgAICurInd   = 0;
    dbgAI           = malloc(sizeof(GorillaLayer *) * dbgAIMaxInd);
    dbgAIVect       = malloc(sizeof(CGPoint) * dbgAIMaxInd);
#endif
    
    isTouchEnabled  = YES;
    
    throwHints      = [[NSMutableArray alloc] initWithCapacity:2];

    self.aim        = ccp(-1, -1);
    buildings       = [[NSMutableArray alloc] init];
    holes           = nil;
    explosions      = nil;
    
    aimSprite       = [[BarSprite alloc] initWithHead:@"aim.head.png" body:@"aim.body.%d.png" withFrames:16 tail:@"aim.tail.png"];
    aimSprite.textureSize = CGSizeMake(aimSprite.textureSize.width / 2, aimSprite.textureSize.height / 2);
    [self addChild:aimSprite z:2];
    
    angleLabel      = [[LabelAtlas alloc] initWithString:[NSString stringWithFormat:@"%0.0f", 99.99f]
                                             charMapFile:@"bonk.png" itemWidth:13 itemHeight:26 startCharMap:' '];
    strengthLabel   = [[LabelAtlas alloc] initWithString:[NSString stringWithFormat:@"%0.0f", 99.99f]
                                             charMapFile:@"bonk.png" itemWidth:13 itemHeight:26 startCharMap:' '];
    infoLabel       = [[Label alloc] initWithString:@"∡\n⊿" dimensions:CGSizeMake(100, 100) alignment:UITextAlignmentLeft
                                           fontName:[GorillasConfig get].fixedFontName fontSize:[GorillasConfig get].smallFontSize];
    [infoLabel addChild:angleLabel];
    [infoLabel addChild:strengthLabel];
    
    CGSize winSize  = [Director sharedDirector].winSize;
    angleLabel.position     = ccp(15, 80);
    strengthLabel.position  = ccp(15, 58);
    angleLabel.scale        = 0.5f;
    strengthLabel.scale     = 0.5f;
    infoLabel.position      = ccp(5 + infoLabel.contentSize.width / 2,
                                  winSize.height - infoLabel.contentSize.height / 2 - 5);
    infoLabel.visible = NO;
    
    [self reset];
    
    return self;
}

-(void) onEnter {

    [super onEnter];
    
    if (!infoLabel.parent)
        [[GorillasAppDelegate get].uiLayer addChild:infoLabel z:9];
}


-(void) registerWithTouchDispatcher {
    
	[[TouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}



-(void) reset {
    
    BOOL wasPanning = panAction != nil;
    [panAction release];
    panAction = nil;
    
    [self stopAllActions];
    [self setPosition:CGPointZero];
    
    if(holes) {
        [self removeChild:holes cleanup:YES];
        [holes release];
    }
    if(explosions) {
        [self removeChild:explosions cleanup:YES];
        [explosions release];
    }
    holes = [[HolesLayer alloc] init];
    [self addChild:holes z:-1];
    explosions = [[ExplosionsLayer alloc] init];
    [self addChild:explosions z:4];

    for (BuildingsLayer *building in buildings)
        [self removeChild:building cleanup:YES];
    [buildings removeAllObjects];
    
    for (NSUInteger i = 0; i < [[GorillasConfig get] buildingAmount] * 3; ++i) {
        float x = i * ([[GorillasConfig get] buildingWidth] + 1)
                - ([[GorillasConfig get] buildingWidth] + 1) * [[GorillasConfig get] buildingAmount] / 2;
        
        BuildingsLayer *building = [[BuildingsLayer alloc] init];
        [buildings addObject: building];
        
        [building setPosition: ccp(x, 0)];
        [self addChild:building z:1];

        [building release];
    }
    
    if(wasPanning)
        [self startPanning];
}


-(void) message:(NSString *)msg on:(CocosNode *)node {
    
    if(msgLabel)
        [msgLabel stopAllActions];

    else {
        msgLabel = [[Label alloc] initWithString:@""
                                      dimensions:CGSizeMake(1000, [[GorillasConfig get] fontSize] + 5)
                                       alignment:UITextAlignmentCenter
                                        fontName:[[GorillasConfig get] fixedFontName]
                                        fontSize:[[GorillasConfig get] fontSize]];
    
        [self addChild:msgLabel z:9];
    }
    
    [msgLabel setString:msg];
    [msgLabel setPosition:ccp([node position].x,
                              [node position].y + [node contentSize].height)];
    
    // Make sure label remains on screen.
    CGSize winSize = [[Director sharedDirector] winSize];
    if(![[GorillasConfig get] followThrow]) {
        if([msgLabel position].x < [[GorillasConfig get] fontSize] / 2)                 // Left edge
            [msgLabel setPosition:ccp([[GorillasConfig get] fontSize] / 2, [msgLabel position].y)];
        if([msgLabel position].x > winSize.width - [[GorillasConfig get] fontSize] / 2) // Right edge
            [msgLabel setPosition:ccp(winSize.width - [[GorillasConfig get] fontSize] / 2, [msgLabel position].y)];
        if([msgLabel position].y < [[GorillasConfig get] fontSize] / 2)                 // Bottom edge
            [msgLabel setPosition:ccp([msgLabel position].x, [[GorillasConfig get] fontSize] / 2)];
        if([msgLabel position].y > winSize.width - [[GorillasConfig get] fontSize] * 2) // Top edge
            [msgLabel setPosition:ccp([msgLabel position].x, winSize.height - [[GorillasConfig get] fontSize] * 2)];
    }
    
    // Color depending on whether message starts with -, + or neither.
    if([msg hasPrefix:@"+"])
        [msgLabel setRGB:0x66 :0xCC :0x66];
    else if([msg hasPrefix:@"-"])
        [msgLabel setRGB:0xCC :0x66 :0x66];
    else
        [msgLabel setRGB:0xFF :0xFF :0xFF];
    
    // Animate the label to fade out.
    [msgLabel runAction:[Spawn actions:
                         [FadeOut actionWithDuration:3],
                         [Sequence actions:
                          [DelayTime actionWithDuration:1],
                          [MoveBy actionWithDuration:2 position:ccp(0, [[GorillasConfig get] fontSize] * 2)],
                          nil],
                         nil]];
}


-(void) draw {

#ifdef _DEBUG_
    BuildingLayer *fb = [buildings objectAtIndex:0], *lb = [buildings lastObject];
    int pCount = (([lb position].x - [fb position].x) / dbgTraceStep + 1)
                * ([[Director sharedDirector] winSize].height / dbgTraceStep + 1);
    CGPoint *hgp = malloc(sizeof(CGPoint) * pCount);
    CGPoint *hep = malloc(sizeof(CGPoint) * pCount);
    int hgc = 0, hec = 0;
    
    for(float x = [fb position].x; x < [lb position].x; x += dbgTraceStep)
        for(float y = 0; y < [[Director sharedDirector] winSize].height; y += dbgTraceStep) {
            CGPoint pos = ccp(x, y);

            BOOL hg = NO, he = NO;
            he = [holes hitsHole:pos];

            for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
                if((hg = [gorilla hitsGorilla:pos]))
                    break;
            
            if(hg)
                hgp[hgc++] = pos;
            else if(he)
                hep[hec++] = pos;
        }
    
    drawPointsAt(hgp, hgc, 0x00FF00FF);
    drawPointsAt(hep, hec, 0xFF0000FF);
    drawPointsAt(dbgPath, dbgPathMaxInd, 0xFFFF00FF);
    free(hgp);
    free(hep);
#endif

    if ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureCheat]) {
        for(NSUInteger i = 0; i < [[GorillasAppDelegate get].gameLayer.gorillas count]; ++i) {
            GorillaLayer *gorilla = [[GorillasAppDelegate get].gameLayer.gorillas objectAtIndex:i];
            if(![gorilla alive])
                continue;
            
            CGPoint from = [gorilla position];
            CGPoint to   = ccpAdd(from, throwHistory[i]);
            
            if(to.x && to.y)
                drawLinesTo(from, &to, 1, [[GorillasConfig get] windowColorOff] & 0xffffff33, 3);
        }
    }
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {

    if([[event allTouches] count] != 1)
        // Ignore: multiple fingers on the screen.
        return NO;
    
    if(![self mayThrow])
        // State doesn't allow throwing right now.
        return NO;
    
    CGPoint p = [self convertTouchToNodeSpace:[[event allTouches] anyObject]];
    
    if([[[GorillasAppDelegate get] hudLayer] hitsHud:p])
        // Ignore when moving/clicking over/on HUD.
        return NO;
    
    if(aim.x != -1 || aim.y != -1)
        // Has already began.
        return NO;
        
    self.aim = ccpSub(p, self.position);

    return YES;
}


- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if([[event allTouches] count] != 1) {
        // Cancel when: multiple fingers hit the screen.
        self.aim = ccp(-1, -1);
        return;
    }

    CGPoint p = [self convertTouchToNodeSpace:[[event allTouches] anyObject]];
    if([[[GorillasAppDelegate get] hudLayer] hitsHud:p]) {
        // Ignore when moving/clicking over/on HUD.
        return;
    }

    CGPoint wp = [self convertToWorldSpace:p];
    NSLog(@"%f", fabsf(wp.y - [Director sharedDirector].winSize.height));
    if (fabsf(wp.y - [Director sharedDirector].winSize.height) < 20)
        [self performSelector:@selector(zoomOut) withObject:nil afterDelay:3];
    else
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(zoomOut) object:nil];
    
    self.aim = ccpSub(p, [self position]);
}


- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(zoomOut) object:nil];

    self.aim = ccp(-1, -1);
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(zoomOut) object:nil];
    
    if([[event allTouches] count] != 1) {
        // Cancel when: multiple fingers hit the screen.
        self.aim = ccp(-1, -1);
        return;
    }
    
    CGPoint p = [self convertTouchToNodeSpace:[[event allTouches] anyObject]];
    
    if([[[GorillasAppDelegate get] hudLayer] hitsHud:p]
        || aim.x <= 0 || ![self mayThrow]) {
        // Cancel when: released over HUD, no aim vector, state doesn't allow throwing.
        self.aim = ccp(-1, -1);
        return;
    }
    
    CGPoint r0 = [[GorillasAppDelegate get].gameLayer.activeGorilla position];
    CGPoint v = ccpSub(aim, r0);
    self.aim = ccp(-1, -1);
    
    [self throwFrom:[GorillasAppDelegate get].gameLayer.activeGorilla withVelocity:v];
}


- (void)setAim:(CGPoint)anAim {
    
    aim                     = anAim;
    
    infoLabel.visible   = NO;
    aimSprite.visible       = NO;
    
    CGPoint gorillaPosition = [GorillasAppDelegate get].gameLayer.activeGorilla.position;
    
    if (aim.x < 0 && aim.y < 0)
        return;
    
    [aimSprite updateWithOrigin:gorillaPosition target:aim];
    aimSprite.visible       = YES;
    
    CGPoint relAim = ccpSub(aim, gorillaPosition);
    CGPoint worldAim = [self convertToWorldSpace:relAim];

    [angleLabel setString:[NSString stringWithFormat:@"%0.0f", CC_RADIANS_TO_DEGREES(ccpToAngle(worldAim))]];
    [strengthLabel setString:[NSString stringWithFormat:@"%0.0f", ccpLength(worldAim)]];
    infoLabel.visible = YES;
}


-(void) zoomOut {

    PanningLayer *panningLayer = [GorillasAppDelegate get].gameLayer.panningLayer;
    [panningLayer scaleTo:panningLayer.scale * 0.9f limited:YES];
}


-(BOOL) mayThrow {

    return ![bananaLayer throwing] && [[GorillasAppDelegate get].gameLayer.activeGorilla active] && [[GorillasAppDelegate get].gameLayer.activeGorilla alive] && [[GorillasAppDelegate get].gameLayer.activeGorilla human]
            && ![GorillasAppDelegate get].gameLayer.paused;
}


-(void) tryNextGorilla:(ccTime)dt {
    
    [self unschedule:@selector(tryNextGorilla:)];
    [self nextGorilla];
}


-(void) nextGorilla {
    
    // Make sure the game hasn't ended.
    if(![[GorillasAppDelegate get].gameLayer checkGameStillOn]) {
        [[GorillasAppDelegate get].gameLayer endGame];
        return;
    }

    // Schedule to retry later if game is paused.
    if([GorillasAppDelegate get].gameLayer.paused) {
        [self schedule:@selector(tryNextGorilla:) interval:0.1f];
        return;
    }
    
    // Save the active gorilla's zoom.
    [GorillasAppDelegate get].gameLayer.activeGorilla.zoom = [GorillasAppDelegate get].gameLayer.panningLayer.scale;
    
    // Active gorilla's turn is over.
    ++[GorillasAppDelegate get].gameLayer.activeGorilla.turns;
    [[GorillasAppDelegate get].gameLayer.activeGorilla setActive:NO];
    
    // Activate the next gorilla.
    // Look for the next live gorilla; first try the next gorilla AFTER the current.
    // If none there is alive, try the first one from the beginning UNTIL the current.
    BOOL foundNextGorilla = NO;
    for(BOOL startFromAfterCurrent = YES; YES; startFromAfterCurrent = NO) {
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
        
        if(!startFromAfterCurrent)
            // Second run didn't find any gorillas -> no gorillas available.
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"No next gorilla to be found; game should've ended in previous check." userInfo:nil];
    }
    
    // Make sure the game hasn't ended.
    if(![[GorillasAppDelegate get].gameLayer checkGameStillOn]) {
        [[GorillasAppDelegate get].gameLayer endGame];
        return;
    }
    
    // Scale to the active gorilla's saved scale.
    [[GorillasAppDelegate get].gameLayer.panningLayer scaleTo:[GorillasAppDelegate get].gameLayer.activeGorilla.zoom limited:YES];
    [[GorillasAppDelegate get].gameLayer.activeGorilla setActive:YES];

    // AI throw.
    if([GorillasAppDelegate get].gameLayer.activeGorilla.alive && ![GorillasAppDelegate get].gameLayer.activeGorilla.human) {
        // Active gorilla is a live AI.
        NSMutableArray *enemies = [[GorillasAppDelegate get].gameLayer.gorillas mutableCopy];

        // Exclude from enemy list: Dead gorillas, Self, AIs when in team mode.
        for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas) {
            if(![gorilla alive]
                || gorilla == [GorillasAppDelegate get].gameLayer.activeGorilla
                || ([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureTeam]
                    && ![gorilla human]))
                [enemies removeObject:gorilla];
        }

        // Pick a random target from the enemies.
        GorillaLayer *target = [[enemies objectAtIndex:random() % [enemies count]] retain];
        [enemies release];
        
        // Aim at the target.
        CGPoint r0 = [GorillasAppDelegate get].gameLayer.activeGorilla.position;
        CGPoint v = [self calculateThrowFrom:r0
                                         to:[target position]
                                 errorLevel:[[GorillasConfig get] level]];
        [target release];

        // Throw at where we aimed.
        [self throwFrom:[GorillasAppDelegate get].gameLayer.activeGorilla withVelocity:v];
        
#ifdef _DEBUG_
        dbgAI[dbgAICurInd] = [GorillasAppDelegate get].gameLayer.activeGorilla;
        dbgAIVect[dbgAICurInd] = v;
        dbgAICurInd = (dbgAICurInd + 1) % dbgAIMaxInd;
#endif
    }
    
    // Throw hints.
    for(NSUInteger i = 0; i < [[GorillasAppDelegate get].gameLayer.gorillas count]; ++i) {
        GorillaLayer *gorilla = [[GorillasAppDelegate get].gameLayer.gorillas objectAtIndex:i];

        BOOL hintGorilla = YES;
        
        if (![[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureCheat])
            hintGorilla = NO;
        if (gorilla == [GorillasAppDelegate get].gameLayer.activeGorilla
            || ![gorilla alive])
            hintGorilla = NO;
        
        Sprite *hint = [throwHints objectAtIndex:i];
        [hint setVisible:hintGorilla];
        [hint stopAllActions];
        
        if(hintGorilla) {
            CGPoint v = [self calculateThrowFrom:[[GorillasAppDelegate get].gameLayer.activeGorilla position]
                                             to:[gorilla position] errorLevel:0.9f];

            [hint setOpacity:0];
            [hint setPosition:ccpAdd([GorillasAppDelegate get].gameLayer.activeGorilla.position, v)];
            [hint runAction:[RepeatForever actionWithAction:[Sequence actions:
                                                             [DelayTime actionWithDuration:5],
                                                             [FadeTo actionWithDuration:3 opacity:0x55],
                                                             [FadeTo actionWithDuration:3 opacity:0x00],
                                                             nil]]];
        }
    }
}


-(void) throwFrom:(GorillaLayer *)gorilla withVelocity:(CGPoint)v {
    
    // Hide all hints.
    for(Sprite *hint in throwHints)
        if([hint visible]) {
            [hint stopAllActions];
            [hint runAction:[FadeTo actionWithDuration:[[GorillasConfig get] transitionDuration] opacity:0x00]];
        }
    
    // Record throw history & start the actual throw.
    throwHistory[[[GorillasAppDelegate get].gameLayer.gorillas indexOfObject:gorilla]] = v;
    [gorilla threw:v];

    [bananaLayer setModel:gorilla.projectileModel type:gorilla.type];
    [bananaLayer throwFrom:[gorilla position] withVelocity:v];
}


-(CGPoint) calculateThrowFrom:(CGPoint)r0 to:(CGPoint)rt errorLevel:(CGFloat)l {

    float g = [[GorillasConfig get] gravity];
    float w = [[[[GorillasAppDelegate get] gameLayer] windLayer] wind];
    ccTime t = 5 * 100 / g;

    // Level-based error.
    rt = ccp(rt.x + random() % (int) ((1 - l) * 100), rt.y + random() % (int) (100 * (1 - l)));
    t = (random() % (int) ((t / 2) * l * 10)) / 10.0f + (t / 2);

    // Velocity vector to hit rt in t seconds.
    CGPoint v = ccp((rt.x - r0.x) / t,
                   (g * t * t - 2 * r0.y + 2 * rt.y) / (2 * t));

    // Wind-based modifier.
    v.x -= w * t * [[GorillasConfig get] windModifier];

    return v;
}


-(void) miss {
    
    if(!([[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureScore]))
        // Don't deduct score when score not enabled.
        return;
    
    if(!([[GorillasAppDelegate get].gameLayer.activeGorilla human]))
        // Don't deduct score for AI misses.
        return;
    
    if(![[GorillasAppDelegate get].gameLayer isEnabled:GorillasFeatureTeam]) {
        NSUInteger humanGorillas = 0;
        for (GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
            if ([gorilla human])
                ++humanGorillas;
        
        if(humanGorillas != 1)
            // Don't deduct score for non-teamed multiplayer.
            return;
    }
    
    int score = [[GorillasConfig get] level] * [[GorillasConfig get] missScore];
    
    [[GorillasConfig get] setScore:[[GorillasConfig get] score] + score];
    [[[GorillasAppDelegate get] hudLayer] updateHudWithScore:score skill:0];

    if(score)
        [self message:[NSString stringWithFormat:@"%+d", score] on:[bananaLayer banana]];
}


-(BOOL) hitsGorilla:(CGPoint)pos {

#ifdef _DEBUG_
    dbgPath[dbgPathCurInd] = pos;
    dbgPathCurInd = (dbgPathCurInd + 1) % dbgPathMaxInd;
#endif

    // Figure out if a gorilla was hit.
    for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
        if([gorilla hitsGorilla:pos]) {

            if(gorilla == [GorillasAppDelegate get].gameLayer.activeGorilla && ![bananaLayer clearedGorilla])
                // Disregard this hit on active gorilla because the banana didn't clear him yet.
                continue;
            
            // A gorilla was hit.
            [hitGorilla release];
            hitGorilla = [gorilla retain];
            [hitGorilla kill];

            return YES;
        }
        
        else
            // No hit.
            if(gorilla == [GorillasAppDelegate get].gameLayer.activeGorilla)
                // Active gorilla was not hit -> banana cleared him.
                [bananaLayer setClearedGorilla:YES];
    
    // No hit.
    return NO;
}


-(BOOL) hitsBuilding:(CGPoint)pos {
    
    // Figure out if a building was hit.
    for(BuildingsLayer *building in buildings)
        if( pos.x >= [building position].x &&
            pos.y >= [building position].y &&
            pos.x <= [building position].x + [building contentSize].width &&
            pos.y <= [building position].y + [building contentSize].height) {

            // A building was hit, but if it's in an explosion crater we
            // need to let the banana continue flying.
            if(![holes hitsHole: pos])
                // Hit was not in a hole.
                return YES;
        }
    
    // No hit.
    return NO;
}


-(void) startGame {
    
    [self stopPanning];

    NSArray *gorillas = [GorillasAppDelegate get].gameLayer.gorillas;
    
    // Create enough throw hint sprites / remove needless ones.
    while([throwHints count] != [gorillas count]) {
        if([throwHints count] < [gorillas count]) {
            Sprite *hint = [Sprite spriteWithFile:@"fire.png"];
            [throwHints addObject:hint];
            [self addChild:hint];
        }
        
        else
            [throwHints removeLastObject];
    }

    // Reset throw history & throw hints.
    free(throwHistory);
    throwHistory = malloc(sizeof(CGPoint) * [gorillas count]);
    for(NSUInteger i = 0; i < [gorillas count]; ++i) {
        throwHistory[i] = ccp(-1, -1);
        [[throwHints objectAtIndex:i] setVisible:NO];
    }
    
    // Position our gorillas.
    // Find indexA: The left boundary of allowed gorilla indexes.
    NSUInteger indexA = 0;
    for(BuildingsLayer *building in buildings)
        if(self.position.x + building.position.x >= 0) {
            indexA = [buildings indexOfObject:building];
            break;
        }
    // Find indexB: The right boundary of allowed gorilla indexes.
    NSUInteger indexB = indexA + [GorillasConfig get].buildingAmount - 1;
    // Less than or 3 gorillas, leave one building padding on the sides.
    if([gorillas count] <= 3) {
        indexA += 1;
        indexB -= 1;
    }
    // Distribute gorillas.
    NSUInteger delta    = indexB - indexA;
    NSInteger minSpace  = (delta - 1) / 2 - ([gorillas count] - 2) * 2;
    if(minSpace < 0)
        minSpace = 0;
    if (minSpace * ([gorillas count] - 1) > delta)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Tried to start a game with more gorillas than there's room in the field." userInfo:nil];

    NSMutableArray *gorillasQueue = [gorillas mutableCopy];
    NSMutableArray *gorillaIndexes = [[NSMutableArray alloc] initWithCapacity: [gorillas count]];
    while ([gorillasQueue count]) {
        NSUInteger index = indexA + random() % (delta + 1);
        BOOL validIndex = YES;
        
        if (index - minSpace <= indexA && index + minSpace >= indexB)
            validIndex = NO;
        
        for (NSNumber *gorillasIndex in gorillaIndexes)
            if (abs([gorillasIndex unsignedIntegerValue] - index) <= minSpace) {
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
        BuildingsLayer *building = [buildings objectAtIndex:[(NSNumber *) [gorillaIndexes objectAtIndex:i] unsignedIntegerValue]];
        GorillaLayer *gorilla = [gorillas objectAtIndex:i];
        
        [gorilla setPosition:ccp([building position].x + [building contentSize].width / 2, [building contentSize].height + [gorilla contentSize].height / 2)];
        [gorilla runAction:[FadeIn actionWithDuration:1]];
        [self addChild:gorilla z:3];
    }
    [gorillaIndexes release];
    
    // Add a banana to the scene.
    if(bananaLayer) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Tried to start a game while a(n old?) banana still existed."
                                     userInfo:nil];
    }
    bananaLayer = [[BananaLayer alloc] init];
    [bananaLayer setFocussed:YES];
    [self addChild:bananaLayer z:2];
    
    [self runAction:[Sequence actions:
                     [DelayTime actionWithDuration:1],
                     [CallFunc actionWithTarget:self selector:@selector(nextGorilla)],
                     nil]];
    
    [[[GorillasAppDelegate get] gameLayer] started];
}


-(void) stopGame {
    
    [hitGorilla release];
    hitGorilla = nil;
    
    if(bananaLayer) {
        [self removeChild:bananaLayer cleanup:YES];
        [bananaLayer release];
        bananaLayer = nil;
    }

    NSUInteger runningActions = 0;
    for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
        if((runningActions = [gorilla numberOfRunningActions]))
            break;

    if(runningActions) {
        [[GorillasAppDelegate get].gameLayer.panningLayer scrollToCenter:[GorillasAppDelegate get].gameLayer.activeGorilla.position
                                                              horizontal:YES];
        [self runAction:[Sequence actions:
                  [DelayTime actionWithDuration:1],
                  [CallFunc actionWithTarget:self selector:@selector(stopGameCallback)],
                  nil]];
    }
    else
        [self stopGameCallback];
}


-(void) stopGameCallback {
    
    for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
        [gorilla killDead];
    
    [[GorillasAppDelegate get].gameLayer.gorillas removeAllObjects];
    
    [self startPanning];
    
    [[GorillasAppDelegate get].gameLayer stopped];
}
 

-(void) startPanning {
    
    if(panAction)
        // If already panning, stop first.
        [self stopPanning];
    
    [[GorillasAppDelegate get].gameLayer.panningLayer scaleTo:0.7f];
    
    panAction = [[PanAction alloc] initWithSubNodes:buildings duration:[[GorillasConfig get] buildingSpeed] padding:1];
    [self runAction:panAction];
}


-(void) stopPanning {
    
    [[GorillasAppDelegate get].gameLayer.panningLayer scaleTo:1];
    
    [panAction cancel];
    [panAction release];
    panAction = nil;
}


-(void) explodeAt: (CGPoint)point isGorilla:(BOOL)isGorilla {
    
    [holes addHoleAt:point];
    [explosions addExplosionAt:point hitsGorilla:isGorilla];
}


-(CGFloat) left {
    
    BuildingsLayer *firstBuilding = [buildings objectAtIndex:1];
    return [firstBuilding position].x;
}


-(CGFloat) right {
    
    BuildingsLayer *lastBuilding = [buildings lastObject];
    return [lastBuilding position].x + [lastBuilding contentSize].width;
}


-(void) dealloc {
    
    [panAction release];
    panAction = nil;
    
    [msgLabel release];
    msgLabel = nil;
    
    [buildings release];
    buildings = nil;
    
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
    
#ifdef _DEBUG_
    free(dbgPath);
    free(dbgAI);
    free(dbgAIVect);
#endif
    
    [super dealloc];
}


@end
