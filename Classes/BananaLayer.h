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
//  BananaLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 08/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "Throw.h"


@interface BananaLayer : Layer {

    BOOL                    clearedGorilla, focussed;
    
    GorillasProjectileModel model;
    GorillasPlayerType      type;

    Sprite                  *banana;
    Throw                   *throwAction;
}

-(void) throwFrom: (CGPoint)r0 withVelocity: (CGPoint)v;
-(BOOL) throwing;

-(void) setModel:(GorillasProjectileModel)aModel type:(GorillasPlayerType)aType;

@property (nonatomic, readwrite) BOOL                       clearedGorilla;
@property (nonatomic, readwrite) BOOL                       focussed;
@property (nonatomic, readonly) GorillasProjectileModel     model;
@property (nonatomic, readonly) Sprite                      *banana;
@property (nonatomic, readonly) Throw                       *throwAction;

@end
