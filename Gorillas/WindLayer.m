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
//  WindLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "WindLayer.h"
#import "GorillasAppDelegate.h"


@interface WindLayer (Private)

-(void) updateSystems;

@end

@implementation WindLayer

@synthesize wind;


- (id) init {
    
    if (!(self = [super init]))
        return self;
    
    systems = [[NSMutableArray alloc] init];
    affectAngles = [[NSMutableArray alloc] init];
    
    head = [[CCSprite alloc] initWithFile:@"arrow.head.png"];
    body = [[CCSprite alloc] initWithFile:@"arrow.body.png"];
    //tail = [[CCSprite alloc] initWithFile:@"arrow.tail.png"];

    [self addChild:head z:1];
    [self addChild:body z:0];
    //[self addChild:tail z:1];
    
    // Dynamic wind.
    // Disabled for now, it makes the banana's course fluxuate too much.
    // Would need to revise banana course calculation; it currently assumes
    // the active wind has been applied to the banana the whole time it's
    // been flying already (assumes constant wind).
    incrementDuration = 0.5f;
    
    return self;
}


-(void) onEnter {
    
    [self reset];
    
    [super onEnter];
}


-(void) reset {

    wind = (PearlGameRandom() % 100) / 100.0f - 0.5f;

    [self updateSystems];
}


-(void) updateSystems {
    
    float windRange = (3.0f * [[GorillasConfig get].windModifier floatValue]);
    head.position   = ccp(wind * windRange, 0);
    body.position   = ccp(0, 0);
    tail.position   = ccp(-wind * windRange, 0);
    body.scaleX     = wind * windRange * 2 / body.contentSize.width;
    head.rotation   = wind < 0? 180: 0;
    
    @synchronized(self) {
        for(NSUInteger i = 0; i < [systems count]; ++i) {
            CCParticleSystem *system = [systems objectAtIndex:i];
            
            if([[affectAngles objectAtIndex:i] boolValue])
                [system setAngle:270 + 45 * wind];
            
            [system setGravity:ccp(wind * 100 / [system life], [system gravity].y)];
        }
    }
}


-(void) registerSystem:(CCParticleSystem *)system affectAngle:(BOOL)affectAngle {
    
    @synchronized(self) {
        if(!system || [systems containsObject:system])
            return;
    
        [systems addObject:system];
        [affectAngles addObject:[NSNumber numberWithBool:affectAngle]];
    }
    
    if(affectAngle)
        [system setAngle:270 + 45 * wind];
    [system setGravity:ccp(wind * 100 / [system life], [system gravity].y)];
}


-(void) unregisterSystem:(CCParticleSystem *)system {
    
    if(!system)
        return;
    
    @synchronized(self) {
        [systems removeObject:system];
    }
}


- (ccColor3B)color {
    
    return head.color;
}

- (GLubyte)opacity {
    
    return head.opacity;
}


- (void)setColor:(ccColor3B)aColor {

    head.color = aColor;
    body.color = aColor;
    tail.color = aColor;
}


- (void)setOpacity: (GLubyte)anOpacity {

    head.opacity = anOpacity;
    body.opacity = anOpacity;
    tail.opacity = anOpacity;
}

- (ccColor3B)displayedColor {

    return self.color;
}

- (BOOL)isCascadeColorEnabled {

    return NO;
}

- (void)setCascadeColorEnabled:(BOOL)cascadeColorEnabled {
}

- (void)updateDisplayedColor:(ccColor3B)color {
}

- (GLubyte)displayedOpacity {

    return self.opacity;
}

- (BOOL)isCascadeOpacityEnabled {

    return NO;
}

- (void)setCascadeOpacityEnabled:(BOOL)cascadeOpacityEnabled {
}

- (void)updateDisplayedOpacity:(GLubyte)opacity {
}

/*-(void) draw {

    [super draw];

    CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"WindLayer - draw");
       CC_NODE_DRAW_SETUP();

    float windRange = (5 * [[GorillasConfig get] windModifier]);
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    const CGPoint from = ccp(winSize.width / 2, winSize.height - [[GorillasConfig get].smallFontSize intValue]);
    CGPoint prev = from;
    
    const CGPoint by[] = {
        prev = ccpAdd(prev, ccp(windRange * wind,           0     )),
        prev = ccpAdd(prev, ccp((wind < 0? 1: -1) * 3,      +3    )),
        prev = ccpAdd(prev, ccp(0,                          -3 * 2)),
        prev = ccpAdd(prev, ccp((wind < 0? -1: 1) * 3,      +3    )),
    };
    drawLinesTo(from, by, 4, color, 2);

    CHECK_GL_ERROR_DEBUG();
    CC_INCREMENT_GL_DRAWS(1);
       CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"WindLayer - draw");
}*/


-(void) dealloc {
    
    [head release];
    head = nil;
    
    [body release];
    body = nil;
    
    [tail release];
    tail = nil;

    @synchronized(self) {
        [systems release];
        systems = nil;
        
        [affectAngles release];
        affectAngles = nil;
    }
    
    [super dealloc];
}


@end
