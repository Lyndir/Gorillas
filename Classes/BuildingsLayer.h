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
//  BuildingsLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "PanAction.h"
#import "GorillaLayer.h"
#import "BananaLayer.h"
#import "Resettable.h"
//#define _DEBUG_

@interface BuildingsLayer : Layer <Resettable> {

    PanAction *panAction;
    Label *msgLabel;
    
    NSMutableArray *gorillas;
    NSMutableArray *buildings;
    NSMutableArray *explosions;

    cpVect aim;
    BananaLayer *bananaLayer;
    GorillaLayer *activeGorilla;
    GorillaLayer *hitGorilla;
    
#ifdef _DEBUG_
    NSUInteger dbgTraceStep;
    NSUInteger dbgPathMaxInd;
    NSUInteger dbgPathCurInd;
    cpVect *dbgPath;
    NSUInteger dbgAIMaxInd;
    NSUInteger dbgAICurInd;
    GorillaLayer **dbgAI;
    cpVect *dbgAIVect;
#endif
}

-(void) startGameWithGorilla: (GorillaLayer *)gorillaA andGorilla: (GorillaLayer *)gorillaB;
-(void) stopGame;

-(void) startPanning;
-(void) stopPanning;

-(BOOL) mayThrow;

-(void) miss;
-(BOOL) hitsGorilla: (cpVect)pos;
-(BOOL) hitsBuilding: (cpVect)pos;
-(void) explodeAt: (cpVect)point isGorilla:(BOOL)isGorilla;

-(void) nextGorilla;
-(void) removeGorilla: (GorillaLayer *)gorilla;

-(void) message: (NSString *)msg on: (CocosNode<CocosNodeSize> *)node;

-(float) left;
-(float) right;

@end
