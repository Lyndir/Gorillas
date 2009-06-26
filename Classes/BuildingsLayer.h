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
//  BuildingsLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "PanAction.h"
#import "GorillaLayer.h"
#import "BananaLayer.h"
#import "Resettable.h"
#import "ExplosionsLayer.h"
#import "HolesLayer.h"
//#define _DEBUG_

@interface BuildingsLayer : Layer <Resettable> {

    PanAction           *panAction;
    Label               *msgLabel, *leftInfoLabel, *rightInfoLabel;
    
    NSMutableArray      *buildings;
    HolesLayer          *holes;
    ExplosionsLayer     *explosions;

    cpVect              aim;
    BananaLayer         *bananaLayer;
    GorillaLayer        *hitGorilla;
    
    cpVect              *throwHistory;
    NSMutableArray      *throwHints;
    
    SystemSoundID       goEffect;
    
#ifdef _DEBUG_
    NSUInteger          dbgTraceStep;
    NSUInteger          dbgPathMaxInd;
    NSUInteger          dbgPathCurInd;
    cpVect              *dbgPath;
    NSUInteger          dbgAIMaxInd;
    NSUInteger          dbgAICurInd;
    GorillaLayer        **dbgAI;
    cpVect              *dbgAIVect;
#endif
}

-(void) startGame;
-(void) stopGame;

-(void) startPanning;
-(void) stopPanning;

-(BOOL) mayThrow;

-(void) miss;
-(BOOL) hitsGorilla: (cpVect)pos;
-(BOOL) hitsBuilding: (cpVect)pos;
-(void) explodeAt: (cpVect)point isGorilla:(BOOL)isGorilla;
-(void) throwFrom:(GorillaLayer *)gorilla withVelocity:(cpVect)v;
-(void) nextGorilla;

-(void) message: (NSString *)msg on: (CocosNode<CocosNodeSize> *)node;
-(cpVect) calculateThrowFrom:(cpVect)r0 to:(cpVect)rt errorLevel:(cpFloat)l;

-(cpFloat) left;
-(cpFloat) right;

@property (nonatomic, readonly) BananaLayer *bananaLayer;
@property (nonatomic, readonly) GorillaLayer *hitGorilla;

@end
