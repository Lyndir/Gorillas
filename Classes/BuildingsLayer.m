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
//  BuildingsLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "BuildingsLayer.h"
#import "BuildingLayer.h"
#import "ExplosionLayer.h"
#import "Throw.h"
#import "GorillasAppDelegate.h"
#import "Utility.h"

@implementation BuildingsLayer


-(id) init {
    
    if (!(self = [super init]))
		return self;

#ifdef _DEBUG_
    dbgTraceStep    = 5;
    dbgPathMaxInd   = 50;
    dbgPathCurInd   = 0;
    dbgPath         = malloc(sizeof(cpVect) * dbgPathMaxInd);
    dbgAIMaxInd   = 1;
    dbgAICurInd   = 0;
    dbgAI           = malloc(sizeof(GorillaLayer *) * dbgAIMaxInd);
    dbgAIVect       = malloc(sizeof(cpVect) * dbgAIMaxInd);
#endif
    
    isTouchEnabled  = true;
    
    aim             = cpv(-1, -1);
    gorillas        = [[NSMutableArray alloc] init];
    buildings       = [[NSMutableArray alloc] init];
    explosions      = [[NSMutableArray alloc] init];
    
    banana          = [[BananaLayer node] retain];
    [banana setVisible:false];
    [self add:banana z:2];
    
    [self reset];

    [self startPanning];
    
    return self;
}


-(void) reset {
    
    BOOL wasPanning = panAction != nil;
    [self stopAction:panAction];
    [panAction release];
    panAction = nil;
    
    for (BuildingLayer *building in buildings)
        [self remove:building];
    [buildings removeAllObjects];
    
    [self stopAllActions];
    [self setPosition:cpv(0, 0)];
    for (int i = 0; i < [[GorillasConfig get] buildingAmount] + 2; ++i) {
        float x = i * ([[GorillasConfig get] buildingWidth] + 1) - [[GorillasConfig get] buildingWidth];
        
        BuildingLayer *building = [BuildingLayer node];
        [buildings addObject: building];
        
        [building setPosition: cpv(x, 0)];
        [self add: building z:1];
    }
    
    if(wasPanning)
        [self startPanning];
}


-(void) message: (NSString *)msg for: (CocosNode<CocosNodeSize> *)node {
    
    if(msgLabel) {
        [msgLabel stopAllActions];
        [self endMessage:self];
    }
    
    // Create a label for our message and position it above our node.
    msgLabel = [[Label labelWithString:msg dimensions:CGSizeMake(1000, [[GorillasConfig get] fontSize] + 5) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize: [[GorillasConfig get] fontSize]] retain];
    [msgLabel setPosition:cpv([node position].x,
                              [node position].y + [node contentSize].height)];
    
    // Make sure label remains on screen.
    CGSize winSize = [[Director sharedDirector] winSize].size;
    if([msgLabel position].x < kItemSize / 2)
        [msgLabel setPosition:cpv(kItemSize / 2, [msgLabel position].y)];
    if([msgLabel position].x > winSize.width - kItemSize / 2)
        [msgLabel setPosition:cpv(winSize.width - kItemSize / 2, [msgLabel position].y)];
    if([msgLabel position].y < kItemSize / 2)
        [msgLabel setPosition:cpv([msgLabel position].x, kItemSize / 2)];
    if([msgLabel position].y > winSize.width - kItemSize * 2)
        [msgLabel setPosition:cpv([msgLabel position].x, winSize.height - kItemSize * 2)];
    
    // Color depending on whether message starts with -, + or neither.
    if([msg hasPrefix:@"+"])
        [msgLabel setRGB:0x66 :0xCC :0x66];
    else if([msg hasPrefix:@"-"])
        [msgLabel setRGB:0xCC :0x66 :0x66];
    else
        [msgLabel setRGB:0xFF :0xFF :0xFF];
    
    // Animate the label to fade out.
    [msgLabel do:[Sequence actions:
                  [DelayTime actionWithDuration:1],
                  [MoveBy actionWithDuration:2 position:cpv(0, kItemSize * 2)],
                  [CallFunc actionWithTarget:self selector:@selector(endMessage:)],
                  nil]];
    [msgLabel do:[FadeOut actionWithDuration:3]];
    
    [self add:msgLabel z:1];
}


-(void) endMessage: (id) sender {
    
    [self remove:msgLabel];
    [msgLabel release];
    msgLabel = nil;
}


-(void) draw {
    
    [super draw];
    
#ifdef _DEBUG_
    BuildingLayer *fb = [buildings objectAtIndex:0], *lb = [buildings lastObject];
    for(float x = [fb position].x; x < [lb position].x; x += dbgTraceStep) {
        for(float y = 0; y < [[Director sharedDirector] winSize].size.height; y += dbgTraceStep) {
            cpVect pos = cpv(x, y);

            BOOL hg = false, he = false;
            for(ExplosionLayer *explosion in explosions)
                if(he = [explosion hitsExplosion:pos])
                    break;

            for(GorillaLayer *gorilla in gorillas)
                if(hg = [gorilla hitsGorilla:pos])
                    break;
            
            if(hg)
                [Utility drawPointAt:pos color:0x00FF00FF];
            else if(he)
                [Utility drawPointAt:pos color:0xFF0000FF];
        }
    }
    
    for(int i = 0; i < dbgPathMaxInd; ++i) {
        [Utility drawPointAt:dbgPath[i] color:0xFFFF00FF];
    }
    
    for(int i = 0; i < dbgAIMaxInd; ++i) {
        [Utility drawLineFrom:dbgAI[i].position by:dbgAIVect[i] color:0xFF00FFFF];
    }
#endif

    if(activeGorilla && aim.x > 0)
        // Only draw aim when aiming and gorillas are set.
        [Utility drawLineFrom:[activeGorilla position] to:aim color:0xFF0000FF width:4];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self touchesMoved:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];

    if(![self mayThrow])
        // State doesn't allow throwing right now.
        return;
    
    if([[[GorillasAppDelegate get] hudLayer] hitsHud:cpv(location.y, location.x)])
        // Ignore when moving/clicking over/on HUD.
        return;
        
    aim = cpv(location.y - position.x, location.x);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    aim = cpv(-1.0f, -1.0f);
}


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
    
    // Cancel when: released over HUD, no aim vector, state doesn't allow throwing.
    if([[[GorillasAppDelegate get] hudLayer] hitsHud:cpv(location.y, location.x)]
        || aim.x <= 0
        || ![self mayThrow]) {
        
        [self touchesCancelled:touches withEvent:event];
        return;
    }
    
    cpVect r0 = [activeGorilla position];
    cpVect v = cpv(aim.x - r0.x, aim.y - r0.y);
        
    [self throwFrom:r0 withVelocity: v];
    
    aim = cpv(-1.0f, -1.0f);
}
    

-(BOOL) mayThrow {

    return ![banana visible] && [activeGorilla alive] && [activeGorilla human]
            && ![[[GorillasAppDelegate get] gameLayer] paused];
}


-(void) throwFrom: (cpVect)r0 withVelocity: (cpVect)v {
    
    [banana setPosition:[activeGorilla position]];
    
    [banana setClearedGorilla:false];
    [banana do:[Throw actionWithVelocity:v startPos:r0]];
}


-(void) nextGorilla {
    
    // Activate the next gorilla.
    GorillaLayer *nextGorilla = nil;
    
    // Look for the next live gorilla; first try the next gorilla AFTER the current.
    // If none there is alive, try the first one from the beginning
    for(BOOL startFromAfterCurrent = true; nextGorilla == nil; startFromAfterCurrent = false) {
        BOOL reachedCurrent = false;
        
        for(GorillaLayer *gorilla in gorillas) {
        
            if(gorilla == activeGorilla)
                reachedCurrent = true;
            
            else
                if(startFromAfterCurrent) {
                    
                    // First run.
                    if(reachedCurrent && [gorilla alive]) {
                        nextGorilla = gorilla;
                        break;
                    }
                } else {
                    
                    // Second run.
                    if(reachedCurrent)
                        // (don't bother looking past the current in the second try)
                        break;
                    
                    else if([gorilla alive]) {
                        nextGorilla = gorilla;
                        break;
                    }
                }
        }
        
        if(!startFromAfterCurrent)
            // Second run didn't find any gorillas -> no gorillas available.
            break;
    }
        
    [activeGorilla release];
    activeGorilla = [nextGorilla retain];
    
    // AI throw.
    if(![activeGorilla human] && [activeGorilla alive]) {
        NSMutableArray *enemies = [gorillas mutableCopy];
        [enemies removeObject:activeGorilla];
        
        GorillaLayer *target = (GorillaLayer *) [enemies objectAtIndex:random() % [enemies count]];
        [enemies release];

        float l = [[GorillasConfig get] level];
        float g = [[GorillasConfig get] gravity];
        cpVect r0 = [activeGorilla position];
        cpVect rt = [target position];
        ccTime t = 4 * 100 / g;

        // Level-based error.
        rt = cpv(rt.x + random() % (int) ((1 - l) * 200), rt.y + random() % (int) (200 * (1 - l)));
        t -= (float)   (random() % (int) ((1 - l) * t * 10)) / 10.0f;
        
        // Velocity vector to hit rt in t seconds.
        cpVect v = cpv((rt.x - r0.x) / t,
                       (g * t * t - 2 * r0.y + 2 * rt.y) / (2 * t));

        [self throwFrom: r0 withVelocity:v];
        
#ifdef _DEBUG_
        dbgAI[dbgAICurInd] = activeGorilla;
        dbgAIVect[dbgAICurInd] = v;
        dbgAICurInd = (dbgAICurInd + 1) % dbgAIMaxInd;
#endif
        }
}


-(void) miss {
    
    if(!([[[GorillasAppDelegate get] gameLayer] singlePlayer] && [activeGorilla human]))
        return;
    
    int nScore = [[GorillasConfig get] level] * [[GorillasConfig get] missScore];
    
    [[GorillasConfig get] setScore:[[GorillasConfig get] score] + nScore];
    [[[GorillasAppDelegate get] hudLayer] updateScore: nScore];

    if(nScore)
        [self message:[NSString stringWithFormat:@"%+d", nScore] for:banana];
}


-(BOOL) hitsBuilding: (cpVect)pos {

#ifdef _DEBUG_
    dbgPath[dbgPathCurInd] = pos;
    dbgPathCurInd = (dbgPathCurInd + 1) % dbgPathMaxInd;
#endif

    // Figure out if a gorilla was hit.
    for(GorillaLayer *gorilla in gorillas)
        if([gorilla hitsGorilla:pos]) {

            if(gorilla == activeGorilla && [banana clearedGorilla] == false)
                // Disregard this hit on active gorilla because the banana didn't clear him yet.
                continue;
            
            // A gorilla was hit.
            hitGorilla = gorilla;
            [hitGorilla setAlive:false];
            
            // Check whether any gorillas are left.
            int liveGorillaCount = 0;
            GorillaLayer *liveGorilla;
            for(GorillaLayer *gorillaState in gorillas)
                if([gorillaState alive]) {
                    liveGorillaCount++;
                    liveGorilla = gorillaState;
                }
            
            // If 0 or 1 gorillas left; show who won and stop the game.
            if(liveGorillaCount < 2) {
                if(liveGorillaCount == 1) {
                    [[[GorillasAppDelegate get] hudLayer] setMenuTitle:[NSString stringWithFormat:@"%@ wins!", [liveGorilla name]]];
                    
                    if([[[GorillasAppDelegate get] gameLayer] singlePlayer]) {
                        // One gorilla left in single player: modify the level depending on who survived.
                        
                        NSString *oldLevel = [[GorillasConfig get] levelName];
                        if([liveGorilla human]) {
                            
                            // Increase difficulty level & update score.
                            int nScore = [[GorillasConfig get] level] * [[GorillasConfig get] killScore];
                            
                            [[GorillasConfig get] setScore:[[GorillasConfig get] score] + nScore];
                            [[[GorillasAppDelegate get] hudLayer] updateScore: nScore];
                            if(nScore)
                                [self message:[NSString stringWithFormat:@"%+d", nScore] for:hitGorilla];
                            [[GorillasConfig get] levelUp];

                            // Message in case we level up.
                            if(oldLevel != [[GorillasConfig get] levelName])
                                [[[GorillasAppDelegate get] gameLayer] message:@"Level Up!"];
                        } else {

                            // Decrease difficulty level & update score.
                            int nScore = [[GorillasConfig get] level] * [[GorillasConfig get] deathScore];
                            
                            [[GorillasConfig get] setScore:[[GorillasConfig get] score] + nScore];
                            [[[GorillasAppDelegate get] hudLayer] updateScore: nScore];
                            if(nScore)
                                [self message:[NSString stringWithFormat:@"%+d", nScore] for:hitGorilla];
                            [[GorillasConfig get] levelDown];
                            
                            // Message in case we level down.
                            if(oldLevel != [[GorillasConfig get] levelName])
                                [[[GorillasAppDelegate get] gameLayer] message:@"Level Down."];
                        }
                    }
                } else
                    [[[GorillasAppDelegate get] hudLayer] setMenuTitle:@"Tie!"];
                
                [[[GorillasAppDelegate get] gameLayer] stopGame];
            }
            
            // Fade out the killed gorilla.
            [hitGorilla do:[Sequence actions:
                                [FadeOut actionWithDuration:1],
                                [CallFunc actionWithTarget:self selector:@selector(hitGorillaCallback:)],
                                nil]];
            return true;
        }
        
        else if(gorilla == activeGorilla)
            // Active gorilla was not hit -> banana cleared him.
            [banana setClearedGorilla:true];
    
    
    // Figure out if a building was hit.
    for(BuildingLayer *building in buildings)
        if( pos.x >= [building position].x &&
            pos.y >= [building position].y &&
            pos.x <= [building position].x + [building contentSize].width &&
            pos.y <= [building position].y + [building contentSize].height) {

            // A building was hit, but if it's in an explosion crater we
            // need to let the banana continue flying.
            BOOL hitsExplosion = false;
            
            for(ExplosionLayer *explosion in explosions)
                if([explosion hitsExplosion: pos])
                    hitsExplosion = true;
            
            if(!hitsExplosion)
                // Hit was not in an explosion.
                return true;
        }
    
    // Nothing hit.
    return false;
}


-(void) hitGorillaCallback: (id) sender {

    [self removeGorilla:hitGorilla];
}


-(void) startGameWithGorilla: (GorillaLayer *)gorillaA andGorilla: (GorillaLayer *)gorillaB {
    
    [[[GorillasAppDelegate get] hudLayer] setMenuTitle: @"Menu"];
    [self stopPanning];
    [self reset];

    [gorillas addObject:[gorillaA retain]];
    [gorillas addObject:[gorillaB retain]];
    
    [gorillaA setAlive:true];
    [gorillaB setAlive:true];
    
    int indexA = 0;
    for(BuildingLayer *building in buildings)
        if(position.x + [building position].x > 0) {
            indexA = [buildings indexOfObject:building] + 1;
            break;
        }
    int indexB = indexA + [[GorillasConfig get] buildingAmount] - 3;
    
    BuildingLayer *buildingA = (BuildingLayer *) [buildings objectAtIndex:indexA];
    [gorillaA setPosition: cpv([buildingA position].x + [buildingA contentSize].width / 2, [buildingA contentSize].height + [gorillaA contentSize].height / 2)];
    
    BuildingLayer *buildingB = (BuildingLayer *) [buildings objectAtIndex:indexB];
    [gorillaB setPosition: cpv([buildingB position].x + [buildingB contentSize].width / 2, [buildingB contentSize].height + [gorillaB contentSize].height / 2)];
    
    [self add:gorillaA z:3];
    [self add:gorillaB z:3];
    
    [gorillaA do:[FadeIn actionWithDuration:1]];
    [gorillaB do:[FadeIn actionWithDuration:1]];
    [self do:[Sequence actions:
              /*[DelayTime actionWithDuration:1],*/
              [CallFunc actionWithTarget:self selector:@selector(startedCallback:)],
              nil]];
    
    activeGorilla = nil;
    [self nextGorilla];
}


-(void) startedCallback: (id) sender {
 
    [[[GorillasAppDelegate get] gameLayer] started];
}


-(void) stopGame {
    
    [activeGorilla release];
    activeGorilla = nil;
    
    for(GorillaLayer *gorilla in gorillas) {
        [gorilla setAlive:false];
        [[gorilla retain] do:[Sequence actions:
                        /*[DelayTime actionWithDuration:2],*/
                        [FadeOut actionWithDuration:1],
                        [CallFunc actionWithTarget:self selector:@selector(stopGameCallback:)],
                        nil]];
    }
    
    [banana stopAllActions];
    [banana setVisible:false];
}


-(void) stopGameCallback: (id) sender {
    
    if(![[[GorillasAppDelegate get] gameLayer] running])
        return;
    
    for(GorillaLayer *gorilla in gorillas)
        [self remove:gorilla];
    for(ExplosionLayer *explosion in explosions)
        [self remove:explosion];
    
    [gorillas removeAllObjects];
    [explosions removeAllObjects];
    
    [self startPanning];
    
    [[[GorillasAppDelegate get] gameLayer] stopped];
}


-(void) removeGorilla: (GorillaLayer *)gorilla {

    [gorilla stopAllActions];

    [self remove:gorilla];
    [gorillas removeObject:gorilla];
}
 

-(void) startPanning {
    
    if(panAction)
        // If already panning, stop first.
        [self stopPanning];
    
    panAction = [[PanAction alloc] initWithSubNodes:buildings duration:[[GorillasConfig get] buildingSpeed] padding:1];
    [self do: panAction];
}


-(void) stopPanning {
    
    [panAction cancel];
    [panAction release];
    panAction = nil;
}


-(void) explodeAt: (cpVect)point {
    
    ExplosionLayer *explosion = [ExplosionLayer node];
    [explosions addObject:explosion];

    [explosion setPosition:point];
    [self add:explosion];
}


-(void) dealloc {
    
    [self stopGame];
    [banana release];
    [gorillas release];
    [activeGorilla release];
    [buildings release];
    [panAction release];
    [super dealloc];
}


@end
