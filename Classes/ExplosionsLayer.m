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
//  ExplosionsLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 04/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "ExplosionsLayer.h"
#import "GorillasAppDelegate.h"
#define flameVariantion 3

typedef enum {
    GorillasExplosionHitGorilla  = 2 << 0,
    GorillasExplosionHeavy       = 2 << 1,
} GorillasExplosion;


@interface ExplosionsLayer (Private)

-(cpFloat) size;
+(ParticleSystem *) flameWithRadius:(cpFloat)radius heavy:(BOOL)heavy;

@end

static ParticleSystem **flameTypes = nil;

@implementation ExplosionsLayer


-(id) init {

    if(!(self = [super init]))
        return self;

    explosions      = [[NSMutableArray alloc] initWithCapacity:10];
    flames          = [[NSMutableArray alloc] initWithCapacity:10];
    positions       = nil;
    
    [self schedule:@selector(gc:) interval:0.5f];
    [self schedule:@selector(step:)];

    return self;
}


-(void) gc:(ccTime)dt {

    BOOL stuffToClean;
    do {
        stuffToClean = NO;
        
        if(explosions.count) {
            ParticleSystem *explosion = [explosions objectAtIndex:0];
            
            if(!explosion.particleCount && !explosion.active) {
                [explosions removeObjectAtIndex:0];
                [self removeChild:explosion cleanup:YES];
                stuffToClean = YES;
            }
        }
    } while(stuffToClean);
}


-(void) step:(ccTime)dt {
    
    for(CocosNode *node = self; node; node = node.parent)
        dt *= node.timeScale;

    if(flameTypes) {
        for (NSUInteger type = 0; type < flameVariantion * 2; ++type)
            [(id)flameTypes[type] step:dt];
    }
}


-(cpFloat) size {
    
    return 32;
}


-(void) addExplosionAt:(cpVect)pos hitsGorilla:(BOOL) hitsGorilla {
    
    BOOL heavy = hitsGorilla || (random() % 100 > 90);

    if([[GorillasConfig get] soundFx])
        [GorillasAudioController playEffect:[ExplosionsLayer explosionEffect:heavy]];

    if([[GorillasConfig get] vibration])
        [[GorillasAppDelegate get].gameLayer shake];
    
    int explosionParticles = random() % 50 + 300;
    if(heavy)
        explosionParticles += 400;
    
    ParticleSystem *explosion = [[ParticleSun alloc] initWithTotalParticles:explosionParticles];
    [[GorillasAppDelegate get].gameLayer.windLayer registerSystem:explosion affectAngle:NO];
    
    explosion.position  = cpvzero;
    explosion.source    = pos;
    explosion.size      = (heavy? 20: 15) * self.scale;
    explosion.sizeVar   = 5 * self.scale;
    explosion.speed     = 10;
    explosion.posVar    = cpv([self size] * 0.2f,
                              [self size] * 0.2f);
    explosion.tag       = (hitsGorilla? GorillasExplosionHitGorilla  : 0) |
                          (heavy?       GorillasExplosionHeavy       : 0);
    [explosion runAction:[Sequence actions:
                          [DelayTime actionWithDuration:heavy? 0.6f: 0.2f],
                          [CallFuncN actionWithTarget:self selector:@selector(stop:)],
                          nil]];
    
    [self addChild:explosion z:1];
    [explosions addObject:explosion];
    [explosion release];
}


-(void) draw {

    if(positions) {
        NSUInteger f = 0;
        cpVect prevFlamePos = cpvzero;
        for(ParticleSystem *flame in flames) {
            cpVect translate = cpvsub(positions[f], prevFlamePos);
            prevFlamePos = positions[f];
            
            glTranslatef(translate.x, translate.y, 0);
            [flame draw];
            
            ++f;
        }
        glTranslatef(-prevFlamePos.x, -prevFlamePos.y, 0);
    }
    
    [super draw];
}


-(void) onExit {
    
    [super onExit];
    
    for (ParticleSystem *explosion in explosions) {
        [[GorillasAppDelegate get].gameLayer.windLayer unregisterSystem:explosion];
        [self removeChild:explosion cleanup:YES];
    }
    [explosions removeAllObjects];
    
    for (ParticleSystem *flame in flames) {
        [[GorillasAppDelegate get].gameLayer.windLayer unregisterSystem:flame];
        [self removeChild:flame cleanup:YES];
    }
    [flames removeAllObjects];
}


-(void) stop:(ParticleSystem *)explosion {
    
    BOOL hitsGorilla    = [explosion tag] & GorillasExplosionHitGorilla;
    BOOL heavy          = [explosion tag] & GorillasExplosionHeavy;
    
    if(!hitsGorilla && [GorillasConfig get].visualFx) {
        ParticleSystem *flame = [ExplosionsLayer flameWithRadius:[self size] / 2 heavy:heavy];

        positions = realloc(positions, sizeof(cpVect) * (flames.count + 1));
        positions[flames.count] = explosion.source;
        [flames addObject:flame];
    }
    
    [explosion stopSystem];
}


+(ParticleSystem *) flameWithRadius:(cpFloat)radius heavy:(BOOL)heavy {
    
    if(!flameTypes) {
        flameTypes = malloc(sizeof(ParticleSystem *) * 2 * flameVariantion);
        
        for (NSUInteger type = 0; type < flameVariantion * 2; ++type) {
            BOOL typeIsHeavy = !(type < flameVariantion);
            int flameParticles = typeIsHeavy? 80: 60;
            
            ParticleSystem *flame   = [[ParticleFire alloc] initWithTotalParticles:flameParticles];
            
            flame.position          = cpvzero;
            //flames.angleVar       = 90;
            flame.size              = typeIsHeavy? 10: 4;
            flame.sizeVar           = 5;
            flame.posVar            = cpv(radius / 2, radius / 2);
            flame.speed             = 8;
            flame.speedVar          = 10;
            flame.life              = typeIsHeavy? 2: 1;
            ccColorF startColor     = { 0.9f, 0.5f, 0.0f, 1.0f };
            flame.startColor        = startColor;
            ccColorF startColorVar  = { 0.1f, 0.2f, 0.0f, 0.1f };
            flame.startColorVar     = startColorVar;
            flame.emissionRate     *= 1.5f;
            
            [[GorillasAppDelegate get].gameLayer.windLayer registerSystem:flame affectAngle:NO];
            flameTypes[type]        = flame;
        }
    }
    
    NSUInteger t = (heavy? 1: 0) * flameVariantion + random() % flameVariantion;
    return flameTypes[t];
}


+(SystemSoundID) explosionEffect: (BOOL)heavy {
    
    static NSUInteger lastEffect = -1;
    static NSUInteger explosionEffects = 0;
    static SystemSoundID* explosionEffect = nil;
    
    if(explosionEffect == nil) {
        explosionEffects = 4;
        explosionEffect = malloc(sizeof(SystemSoundID) * explosionEffects);
        
        for(NSUInteger i = 0; i < explosionEffects; ++i)
            explosionEffect[i] = [GorillasAudioController loadEffectWithName:[NSString stringWithFormat:@"explosion%d.wav", i]];
    }

    // Pick a random effect.
    NSUInteger chosenEffect;
    if(heavy) {
        // Effect 0 is reserved for heavy explosions.
        chosenEffect = 0;
        lastEffect = -1;
    }
    
    else {
        // Pick an effect that is not 0 (see above) and not the same as the last effect.
        do {
            chosenEffect = random() % explosionEffects;
        } while(chosenEffect == lastEffect || chosenEffect == 0);
        lastEffect = chosenEffect;
    }
    
    return explosionEffect[chosenEffect];
}


-(void) dealloc {
    
    [explosions release];
    explosions = nil;
    
    [flames release];
    flames = nil;
    
    [super dealloc];
}


@end
