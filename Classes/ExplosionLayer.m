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
#import "GorillasAppDelegate.h"


@implementation ExplosionLayer

@synthesize hole;


-(id) initHitsGorilla:(BOOL)gorillaHit {
    
    if(!(self = [super init]))
        return self;
    
    hitsGorilla = gorillaHit;
    heavy = hitsGorilla || (random() % 100 > 90);

    hole = [[HoleLayer alloc] init];
    [hole setScale:[[GorillasConfig get] cityScale]];
    
    return self;
}


-(void) onEnter {
    
    [super onEnter];
    
    int explosionParticles = random() % 50 + 300;
    if(heavy)
        explosionParticles += 400;
    
    [explosion release];
    explosion = [[ParticleSun alloc] initWithTotalParticles:explosionParticles];
    
    [explosion setPosition:cpvzero];
    //[explosion setPosition:[self position]];
    [explosion setSize:(heavy? 20: 15) * [self scale]];
    [explosion setSizeVar:5 * [self scale]];
    [explosion setSpeed:10];
    [explosion setPosVar:cpv([self contentSize].width * 0.2f,
                             [self contentSize].height * 0.2f)];
    [explosion do:[Sequence actions:
                   [DelayTime actionWithDuration:heavy? 0.6f: 0.2f],
                   [CallFunc actionWithTarget:self selector:@selector(stop:)],
                   nil]];

    [self add:explosion z:1];
}


-(void) onExit {
    
    [super onExit];
    
    [[[[GorillasAppDelegate get] gameLayer] windLayer] unregisterSystem:explosion];
    [explosion release];
    explosion = nil;
    
    [[[[GorillasAppDelegate get] gameLayer] windLayer] unregisterSystem:flames];
    [flames release];
    flames = nil;
}


-(void) stop:(id)sender {
    
    [explosion stopSystem];
    
    if(!hitsGorilla && [[GorillasConfig get] effects]) {
        int flameParticles = random() % 20 + 5;
        if(heavy)
            flameParticles = 80;
        
        flames = [[ParticleFire alloc] initWithTotalParticles:flameParticles];
        
        [flames setPosition:cpvzero];
        //[flames setAngleVar:90];
        [flames setSize:heavy? 10: 4];
        [flames setSizeVar:5];
        [flames setPosVar:cpv([self contentSize].width / 4, [self contentSize].height / 4)];
        [flames setSpeed:8];
        [flames setSpeedVar:10];
        [flames setLife:heavy? 2: 1];
        ccColorF startColor;
        startColor.r = 0.9f;
        startColor.g = 0.6f;
        startColor.b = 0.0f;
        startColor.a = 0.9f;
        [flames setStartColor:startColor];
        ccColorF startColorVar;
        startColorVar.r = 0.1f;
        startColorVar.g = 0.2f;
        startColorVar.b = 0.0f;
        startColorVar.a = 0.1f;
        [flames setStartColorVar:startColorVar];
        [flames setEmissionRate:[flames emissionRate] * 1.5f];
        
        [[[[GorillasAppDelegate get] gameLayer] windLayer] registerSystem:flames affectAngle:false];
        [self add:flames z:1];
    }
}


-(BOOL) hitsExplosion: (cpVect)pos {
    
    return ((position.x - pos.x) * (position.x - pos.x) +
            (position.y - pos.y) * (position.y - pos.y) ) < powf([self contentSize].width, 2) / 9;
}


-(void) setPosition:(cpVect)pos {
    
    [super setPosition:pos];
    [hole setPosition:position];
}


-(CGSize) contentSize {
    
    return CGSizeMake([hole contentSize].width * [self scale], [hole contentSize].height * [self scale]);
}


-(void) dealloc {
    
    [hole release];
    hole = nil;
    
    [explosion release];
    explosion = nil;
    
    [flames release];
    flames = nil;
    
    [super dealloc];
}


@end
