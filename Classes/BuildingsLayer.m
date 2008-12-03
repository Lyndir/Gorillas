//
//  BuildingsLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
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
    
    for (int i = 0; i < [[GorillasConfig get] buildingAmount] + 2; ++i) {
        float x = i * ([[GorillasConfig get] buildingWidth] + 1) - [[GorillasConfig get] buildingWidth];
        
        BuildingLayer *building = [BuildingLayer node];
        [buildings addObject: building];
        
        [building setPosition: cpv(x, 0)];
        [self add: building z:1];
    }

    [self startPanning];
    
    return self;
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
        ccTime t = 4;

        // Level-based error.
        if(l != 1) {
            rt = cpv(rt.x + random() % (int) ((1 - l) * 200), rt.y + random() % (int) (200 * (1 - l)));
            t -= (float)   (random() % (int) ((1 - l) * t * 10)) / 10.0f;
        }
        
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
                            [[GorillasConfig get] levelUp];
                            if(oldLevel != [[GorillasConfig get] levelName])
                                [[[GorillasAppDelegate get] gameLayer] message:@"Level Up!"];
                        } else {
                            [[GorillasConfig get] levelDown];
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
            pos.x <= [building position].x + [building width] &&
            pos.y <= [building position].y + [building height]) {

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
    [gorillaA setPosition: cpv([buildingA position].x + [buildingA width] / 2, [buildingA height] + [gorillaA height] / 2)];
    
    BuildingLayer *buildingB = (BuildingLayer *) [buildings objectAtIndex:indexB];
    [gorillaB setPosition: cpv([buildingB position].x + [buildingB width] / 2, [buildingB height] + [gorillaB height] / 2)];
    
    [self add:gorillaA z:3];
    [self add:gorillaB z:3];
    
    [self stopPanning];
    gorillaA.opacity = 0;
    gorillaB.opacity = 0;
    [gorillaA do:[FadeIn actionWithDuration:1]];
    [gorillaB do:[FadeIn actionWithDuration:1]];
    /*[self do:[Sequence actions:[DelayTime actionWithDuration:1],
              [CallFunc actionWithTarget:self selector:@selector(startedCallback:)],
              nil]];*/
    
    activeGorilla = nil;
    [self nextGorilla];
    
    [[[GorillasAppDelegate get] gameLayer] started];
}


/*-(void) startedCallback: (id) sender {
    
    [[[GorillasAppDelegate get] gameLayer] unpause];
}*/


-(void) stopGame {
    
    [activeGorilla release];
    activeGorilla = nil;
    
    for(GorillaLayer *gorilla in gorillas) {
        [gorilla setAlive:false];
        [[gorilla retain] do:[Sequence actions:
                        [DelayTime actionWithDuration:2],
                        [FadeOut actionWithDuration:1],
                        [CallFunc actionWithTarget:self selector:@selector(stopGameCallback:)],
                        nil]];
    }
    
    [gorillas removeAllObjects];
    
    [banana stopAllActions];
    [banana setVisible:false];
}


-(void) stopGameCallback: (id) sender {
    
    for(GorillaLayer *gorilla in gorillas)
        [self removeGorilla:gorilla];
    
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
    
    panAction = [[PanAction actionWithNode: self subNodes: buildings nodeWidth: ([[GorillasConfig get] buildingWidth] + 1) duration: [[GorillasConfig get] buildingSpeed]] retain];
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
    [explosion setOpacity:0x00];
    
    [self add:explosion];
    [explosion do:[FadeIn actionWithDuration:0.3f]];
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
