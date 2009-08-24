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
//  Throw.h
//  Gorillas
//
//  Created by Maarten Billemont on 22/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//



@interface Throw : IntervalAction {

@private
    BOOL            running;
    BOOL            skipped;
    //BOOL            focussed;
    ccTime          recap;
    CGPoint          recapr;
    CGPoint          v;
    CGPoint          r0;
    float           throwSkill;
    
    IntervalAction  *spinAction;
    ParticleSystem  *smoke;
}

+(Throw *) actionWithVelocity: (CGPoint)velocity startPos: (CGPoint)startPos;
-(Throw *) initWithVelocity: (CGPoint)velocity startPos: (CGPoint)startPos;

@property (nonatomic, readwrite) ccTime recap;
//@property (nonatomic, readwrite) BOOL   focussed;

@end
