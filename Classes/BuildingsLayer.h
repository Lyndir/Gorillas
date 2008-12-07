//
//  BuildingsLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "PanAction.h"
#import "GorillaLayer.h"
#import "BananaLayer.h"
#import "Resettable.h"
//#define _DEBUG_

@interface BuildingsLayer : Layer <Resettable> {

    @private
    PanAction *panAction;
    
    NSMutableArray *gorillas;
    NSMutableArray *buildings;
    NSMutableArray *explosions;

    cpVect aim;
    BananaLayer *banana;
    GorillaLayer *activeGorilla;
    GorillaLayer *hitGorilla;
    
#ifdef _DEBUG_
    int dbgTraceStep;
    int dbgPathMaxInd;
    int dbgPathCurInd;
    cpVect *dbgPath;
    int dbgAIMaxInd;
    int dbgAICurInd;
    GorillaLayer **dbgAI;
    cpVect *dbgAIVect;
#endif
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) startGameWithGorilla: (GorillaLayer *)gorillaA andGorilla: (GorillaLayer *)gorillaB;
-(void) stopGame;

-(void) startPanning;
-(void) stopPanning;

-(BOOL) mayThrow;
-(void) throwFrom: (cpVect) r0 withVelocity: (cpVect) v;

-(BOOL) hitsBuilding: (cpVect)pos;
-(void) explodeAt: (cpVect)point;

-(void) nextGorilla;
-(void) removeGorilla: (GorillaLayer *)gorilla;

@end
