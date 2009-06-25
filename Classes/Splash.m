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
//  Splash.m
//  Gorillas
//
//  Created by Maarten Billemont on 09/01/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "Splash.h"
#import "GorillasAppDelegate.h"


@interface SplashTransition : ZoomFlipYTransition

@end

@implementation SplashTransition

- (id)initWithGameScene:(Scene *)gameScene {

    if (!(self = [super initWithDuration:[[GorillasConfig get] transitionDuration]
                                   scene:gameScene
                             orientation:kOrientationDownOver]))
        return nil;
    
    return self;
}

- (void)finish {
    
    [super finish];
    
#ifdef LITE
    [[GorillasAppDelegate get].gameLayer configureGameWithMode:GorillasModeClassic humans:1 ais:1];
    [[GorillasAppDelegate get].gameLayer startGame];
#else
    [[GorillasAppDelegate get] showMainMenu];
    [[GorillasAppDelegate get].gameLayer.buildingsLayer startPanning];
#endif
}

@end



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
    
    [self performSelector:@selector(switchScene) withObject:nil afterDelay:2];
}


-(void) switchScene {
    
    @synchronized(self) {
        if(switching)
            return;
        switching = YES;

        Scene *gameScene = [[Scene alloc] init];
        [gameScene addChild:[[GorillasAppDelegate get] uiLayer]];
        
        // Build a transition scene from the splash scene to the game scene.
        TransitionScene *transitionScene = [[SplashTransition alloc] initWithGameScene:gameScene];
        
        [gameScene release];
        
        // Start the scene and bring up the menu.
        [[Director sharedDirector] replaceScene:transitionScene];
        [transitionScene release];
    }
}


@end
