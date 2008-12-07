//
//  EAGLView.m
//  OGLSpike
//
//  Created by Maarten Billemont on 19/10/08.
//  Copyright Lin.k 2008. All rights reserved.
//


#import "GameLayer.h"
#import "MainMenuLayer.h"
#import "GorillasAppDelegate.h"


@implementation GameLayer


@synthesize buildings, singlePlayer, running, paused;


-(id) init {
    
	if (!(self = [super init]))
		return self;
    
    singlePlayer = false;
    running = false;
    paused = true;
    
    // Sky and buildings.
    skies = [[SkiesLayer alloc] init];
    [self add:skies];
    
    buildings = [[BuildingsLayer alloc] init];
    [self add:buildings];
    
    return self;
}


-(void) reset {

    [skies reset];
    [buildings reset];
}


-(void) pause {
    
    if(!running)
        // Only allow toggling pause state while game is running.
        return;
    
    if(!paused)
        [self message:@"Paused."];
    
    paused = true;
    
    [[GorillasAppDelegate get] hideHud];
}


-(void) unpause {
    
    if(!running)
        // Only allow toggling pause state while game is running.
        return;
    
    if(paused)
        [self message:@"Unpaused!"];

    paused = false;
    
    [[GorillasAppDelegate get] dismissLayer];
    [[GorillasAppDelegate get] revealHud];
}


-(void) message: (NSString *)msg {
    
    if(msgLabel) {
        [msgLabel stopAllActions];
        [self endMessage:self];
    }
    
    CGSize winSize = [[Director sharedDirector] winSize].size;
    msgLabel = [[Label labelWithString:msg dimensions:CGSizeMake(1000, [[GorillasConfig get] fontSize] + 5) alignment:UITextAlignmentCenter fontName:@"Marker Felt" fontSize: [[GorillasConfig get] fontSize]] retain];
    [msgLabel setPosition:cpv(100, winSize.height)];
    [msgLabel do:[Sequence actions:
                    [MoveBy actionWithDuration:1 position:cpv(0, -50)],
                    [FadeOut actionWithDuration:2],
                    [CallFunc actionWithTarget:self selector:@selector(endMessage:)],
                    nil]];
    [self add:msgLabel z:1];
}


-(void) endMessage: (id) sender {
    
    [self remove:msgLabel];
    [msgLabel release];
    msgLabel = nil;
}


-(void) startSinglePlayer {
    
    if(running)
        return;
    
    running = true;
    singlePlayer = true;
    
    [self message:[[GorillasConfig get] levelName]];
    
    GorillaLayer *gorillaA = [GorillaLayer node];
    GorillaLayer *gorillaB = [GorillaLayer node];    
    
    [gorillaA setName:@"Player"];
    [gorillaA setHuman:true];
    
    [gorillaB setName:@"Phone"];
    [gorillaB setHuman:false];
    
    [buildings startGameWithGorilla:gorillaA andGorilla:gorillaB];

    paused = false;
    [self unpause];
}


-(void) startMultiplayer {
    
    if(running)
        return;
    
    GorillaLayer *gorillaA = [GorillaLayer node];
    GorillaLayer *gorillaB = [GorillaLayer node];    
    
    [gorillaA setName:@"Gorilla One"];
    [gorillaA setHuman:true];
    
    [gorillaB setName:@"Gorilla Two"];
    [gorillaB setHuman:true];
    
    [buildings startGameWithGorilla:gorillaA andGorilla:gorillaB];
}


-(void) started {
    
    running = true;
    paused = false;
    
    [self unpause];
}


-(void) stopGame {
    
    if(!running)
        return;
    
    paused = false;
    [self unpause];
    
    [buildings stopGame];
}


-(void) stopped {
    
    paused = true;
    [self pause];
    
    running = false;
    singlePlayer = false;
    
    [[GorillasAppDelegate get] showMainMenu];
}


-(void) dealloc {
    
    [super dealloc];
    
    [msgLabel release];
}


@end
