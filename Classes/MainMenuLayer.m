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
//  MainMenuLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "MainMenuLayer.h"
#import "GorillasAppDelegate.h"
#import "MenuItemSpacer.h"


@interface MainMenuLayer ()

-(void) newGame: (id)sender;
-(void) continueGame: (id)sender;
-(void) stopGame: (id)sender;
-(void) information: (id)sender;
-(void) options: (id)sender;

@end

@implementation MainMenuLayer


-(id) init {

    if(!(self = [super init]))
        return self;
    
    info                = [[MenuItemFont alloc] initFromString:NSLocalizedString(@"entries.information", @"Information")
                                                        target:self selector:@selector(information:)];
    config              = [[MenuItemFont alloc] initFromString:NSLocalizedString(@"entries.configuration", @"Configuration")
                                                        target:self selector:@selector(options:)];
    continueGame        = [[MenuItemFont alloc] initFromString:NSLocalizedString(@"entries.continue.unpause", @"Continue Game")
                                                        target:self selector:@selector(continueGame:)];
    stopGame            = [[MenuItemFont alloc] initFromString:NSLocalizedString(@"entries.end", @"End Game")
                                                        target:self selector:@selector(stopGame:)];
    newGame             = [[MenuItemFont alloc] initFromString:NSLocalizedString(@"entries.new", @"New Game")
                                                        target:self selector:@selector(newGame:)];

    return self;
}


-(void) onEnter {
    
    [self reset];

    [super onEnter];
}


-(void) reset {

#ifdef LITE
    config.isEnabled    = NO;
#endif
    if(menu) {
        [menu removeAllChildrenWithCleanup:YES];
        [self removeChild:menu cleanup:YES];
        [menu release];
        menu = nil;
    }
    
    if([[GorillasAppDelegate get].gameLayer checkGameStillOn]) {
        menu = [[Menu menuWithItems:
                 continueGame, stopGame, [MenuItemSpacer small],
                 info, config,
                 nil] retain];
    }
    else {
        menu = [[Menu menuWithItems:
                 newGame, [MenuItemSpacer small],
                 info, config,
                 nil] retain];
    }
    
    [menu alignItemsVertically];
    [self addChild:menu];
}


-(void) newGame: (id)sender {
    
    [[GorillasAudioController get] clickEffect];
#ifdef LITE
    [[GorillasAppDelegate get].gameLayer configureGameWithMode:GorillasModeClassic humans:1 ais:1];
    [[GorillasAppDelegate get].gameLayer startGame];
#else
    [[GorillasAppDelegate get] showNewGame];
#endif    
}


-(void) continueGame: (id)sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get].gameLayer setPaused:NO];
}


-(void) stopGame: (id)sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get].gameLayer stopGame];
}


-(void) information: (id)sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showInformation];
}


-(void) options: (id)sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showConfiguration];
}


-(void) dealloc {
    
    [menu release];
    menu = nil;

    [super dealloc];
}


@end
