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
//  WindLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 25/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "Resettable.h"


@interface WindLayer : Layer <CocosNodeOpacity, Resettable> {

    long            color;
    float           wind, bar;
    float           windIncrement;
    ccTime          elapsed, incrementDuration;
    
    NSMutableArray  *systems, *affectAngles;
    Sprite          *head, *body, *tail;
}

-(void) registerSystem:(ParticleSystem *)system affectAngle:(BOOL)affectAngle;
-(void) unregisterSystem:(ParticleSystem *)system;

@property (nonatomic, readonly) float wind;
@property (nonatomic, readwrite) long color;
@property (nonatomic, readwrite) GLubyte opacity;

@end
