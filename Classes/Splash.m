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
//  Splash.m
//  Gorillas
//
//  Created by Maarten Billemont on 09/01/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
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
        [gameScene add: [[GorillasAppDelegate get] uiLayer]];
        
        // Build a transition scene from the splash scene to the game scene.
        TransitionScene *transitionScene = [[ZoomFlipYTransition alloc] initWithDuration:[[GorillasConfig get] transitionDuration]
                                                                                   scene:gameScene
                                                                             orientation:kOrientationDownOver];
        [gameScene do:[Sequence actions:
                       [DelayTime actionWithDuration:0.5f],
                       [CallFunc actionWithTarget:[GorillasAppDelegate get] selector:@selector(showMainMenu)],
                       nil]];
        [gameScene release];
        
        // Start the scene and bring up the menu.
        [[Director sharedDirector] replaceScene:transitionScene];
        [transitionScene release];
    }
}


@end
