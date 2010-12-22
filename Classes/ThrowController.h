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
//  ThrowController.h
//  Gorillas
//
//  Created by Maarten Billemont on 02/04/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "GorillaLayer.h"


typedef enum {
    ThrowNotEnded,
    ThrowEndHitBuilding,
    ThrowEndHitGorilla,
    ThrowEndOffScreen,
} ThrowEnd;
typedef struct {
    CGPoint     endPoint;
    ThrowEnd    endCondition;
    ccTime      duration;
} Throw;

@interface ThrowController : NSObject {

    Throw                               _throw;
    CCSprite                            *_banana;
}

@property (nonatomic, assign) Throw     throw;
@property (nonatomic, assign) CCSprite  *banana;

-(void) nextTurn;
-(void) throwEnded;

- (void)throwFrom:(GorillaLayer *)gorilla normalizedVelocity:(CGPoint)velocity;

+ (Throw)calculateThrowFrom:(CGPoint)r0 withVelocity:(CGPoint)v afterTime:(ccTime)t;
+ (ThrowController *) get;

@end
