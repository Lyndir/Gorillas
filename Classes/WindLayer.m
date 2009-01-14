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
//  WindLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "WindLayer.h"
#import "Utility.h"
#import "GorillasConfig.h"
#import "GorillasAppDelegate.h"


@implementation WindLayer

@synthesize color, wind;


- (id) init {
    
	if (!(self = [super init]))
        return self;
    
    systems = [[NSMutableArray alloc] init];
    affectAngles = [[NSMutableArray alloc] init];
    
    [self reset];
    
	return self;
}


-(void) reset {

    wind = (random() % 100) / 100.0f - 0.5f;

    for(uint i = 0; i < [systems count]; ++i) {
        ParticleSystem *system = [systems objectAtIndex:i];
        
        if([[affectAngles objectAtIndex:i] boolValue])
            [system setAngle:270 + 45 * wind];
        
        [system setGravity:cpv(wind * 100 / [system life], [system gravity].y)];
    }
}


-(void) registerSystem:(ParticleSystem *)system affectAngle:(BOOL)affectAngle {
    
    if(!system)
        return;
    
    [systems addObject:system];
    [affectAngles addObject:[NSNumber numberWithBool:affectAngle]];
    
    if(affectAngle)
        [system setAngle:270 + 45 * wind];
    [system setGravity:cpv(wind * 100 / [system life], [system gravity].y)];
}


-(void) unregisterSystem:(ParticleSystem *)system {
    
    if(!system)
        return;
    
    [systems removeObject:system];
}


-(void) draw {

    float windRange = (5 * [[GorillasConfig get] windModifier]);
    CGSize winSize = [[Director sharedDirector] winSize].size;
    
    const cpVect from = cpv(winSize.width / 2, winSize.height - [[GorillasConfig get] smallFontSize]);
    cpVect prev = from;
    
    const cpVect by[] = {
        prev = cpvadd(prev, cpv(windRange * wind,           0     )),
        prev = cpvadd(prev, cpv((wind < 0? 1: -1) * 3,      +3    )),
        prev = cpvadd(prev, cpv(0,                          -3 * 2)),
        prev = cpvadd(prev, cpv((wind < 0? -1: 1) * 3,      +3    )),
    };
    drawLinesTo(from, by, 4, color, 2);
}


-(GLubyte) opacity {
    
    const GLubyte *colorBytes = (GLubyte *)&color;
    return colorBytes[0];
}


-(void) setOpacity:(GLubyte)opacity {
    
    color = (color & 0xffffff00) | opacity;
}


-(void) dealloc {
    
    [systems release];
    systems = nil;
    
    [affectAngles release];
    affectAngles = nil;
    
    [super dealloc];
}


@end
