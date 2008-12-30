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
//  ExplosionLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 04/11/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "ExplosionLayer.h"
#import "ExplosionAnimationLayer.h"
#import "GorillasAppDelegate.h"


@implementation ExplosionLayer


-(id) initHitsGorilla:(BOOL)gorillaHit {
    
    if(!(self = [super initWithFile:@"hole.png"]))
        return self;
    
    hitsGorilla = gorillaHit;
    //[self add:[ExplosionAnimationLayer get] z:-9];
    
    return self;
}


-(void) onEnter {
    
    [explosion release];
    explosion = [[ParticleSun alloc] initWithTotalParticles:random() % 100 + hitsGorilla? 900: 400];
    
    [explosion setPosition:[self position]];
    [explosion setSize:15];
    [explosion setSizeVar:5];
    [explosion setSpeed:10];
    [explosion setPosVar:cpv([self contentSize].width * 0.2f,
                             [self contentSize].height * 0.2f)];
    [explosion do:[Sequence actions:
                   [DelayTime actionWithDuration:hitsGorilla? 1: 0.2f],
                   [CallFunc actionWithTarget:self selector:@selector(stop:)],
                   nil]];

    [[self parent] add:explosion z:9];
}


-(void) stop:(id)sender {
    
    [explosion stopSystem];
    
    if(!hitsGorilla) {
        [flames release];
        flames = [[ParticleFire alloc] initWithTotalParticles:random() % 40];
        
        [flames setPosition:[self position]];
        //[flames setAngleVar:90];
        [flames setSize:5];
        [flames setSizeVar:5];
        [flames setPosVar:cpv([self contentSize].width / 4, [self contentSize].height / 4)];
        [flames setSpeed:5];
        [flames setSpeedVar:10];
        [flames setLife:2.0f];
        [flames setGravity:cpv([[[[GorillasAppDelegate get] gameLayer] wind] wind] * [[GorillasConfig get] windModifier], 0)];
        ccColorF startColor;
        startColor.r = 0.9f;
        startColor.g = 0.6f;
        startColor.b = 0.0f;
        startColor.a = 0.8f;
        [flames setStartColor:startColor];
        ccColorF startColorVar;
        startColorVar.r = 0.1f;
        startColorVar.g = 0.2f;
        startColorVar.b = 0.0f;
        startColorVar.a = 0.1f;
        [flames setStartColorVar:startColorVar];
        [[self parent] add:flames z:99999999];
    }
}


-(BOOL) hitsExplosion: (cpVect)pos {
    
    return ((position.x - pos.x) * (position.x - pos.x) +
            (position.y - pos.y) * (position.y - pos.y) ) < ([self width] * [self width]) / 9;
}


-(void) draw {
    
    // Blend our transarent white with DST.  If SRC, make DST transparent, hide original DST.
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE);
    glBlendFunc(GL_ZERO, GL_SRC_ALPHA);
    
    [super draw];
    
    // Reset blend & data source.
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}


-(float) width {
    
    return [self contentSize].width;
}


-(float) height {
    
    return [self contentSize].height;
}


-(void) dealloc {
    
    [[explosion parent] remove:explosion];
    [explosion release];
    explosion = nil;
    
    [[flames parent] remove:flames];
    [flames release];
    flames = nil;
    
    [super dealloc];
}


@end
