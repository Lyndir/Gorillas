//
//  Splash.m
//  Gorillas
//
//  Created by Maarten Billemont on 09/01/09.
//  Copyright 2009 Lin.k. All rights reserved.
//

#import "Splash.h"
#import "GorillasAppDelegate.h"


@implementation Splash


-(id) init {
    
    if(!(self = [super initWithFile:@"splash.png"]))
        return self;
    
    [self setPosition:cpv([self contentSize].width / 2, [self contentSize].height / 2)];
    
    switching = NO;
    
    return self;
}


-(void) onEnter {
    
    [super onEnter];
    
    [self schedule:@selector(switchScene:)];
}


-(void) switchScene: (ccTime)dt {
    
    @synchronized(self) {
        if(switching)
            return;
        
        switching = YES;
        [self unschedule:@selector(switchScene:)];

        Scene *gameScene = [[Scene alloc] init];
        [gameScene add: [[GorillasAppDelegate get] gameLayer]];
        
        // Build a transition scene from the splash scene to the game scene.
        TransitionScene *transitionScene = [[ZoomFlipYTransition alloc] initWithDuration:[[GorillasConfig get] transitionDuration]
                                                                                   scene:gameScene
                                                                             orientation:kOrientationDownOver];
        [gameScene release];
        
        // Start the scene and bring up the menu.
        [[Director sharedDirector] replaceScene:transitionScene];
        [transitionScene release];
        
        // Open up the main menu.
        [[GorillasAppDelegate get] showMainMenu];
    }
}


@end
