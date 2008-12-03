//
//  EAGLView.h
//  OGLSpike
//
//  Created by Maarten Billemont on 19/10/08.
//  Copyright Lin.k 2008. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "GorillasConfig.h"
#import "BuildingsLayer.h"


@interface GameLayer : Layer {

    @private
    BOOL paused;
    BOOL running;
    BOOL singlePlayer;
    BuildingsLayer *buildings;
    Label *msgLabel;
}

@property (readonly) BuildingsLayer *buildings;
@property (readonly) BOOL singlePlayer;
@property (readonly) BOOL running;
@property (readonly) BOOL paused;

-(void) pause;
-(void) unpause;

-(void) message: (NSString *)msg;
-(void) endMessage: (id) sender;

-(void) startSinglePlayer;
-(void) startMultiplayer;
-(void) started;

-(void) stopGame;
-(void) stopped;


@end
