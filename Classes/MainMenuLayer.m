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

@property (nonatomic, readwrite, retain) CCMenuItem *info;
@property (nonatomic, readwrite, retain) CCMenuItem *config;
@property (nonatomic, readwrite, retain) CCMenuItem *continueGame;
@property (nonatomic, readwrite, retain) CCMenuItem *stopGame;
@property (nonatomic, readwrite, retain) CCMenuItem *newGame;

@end

@implementation MainMenuLayer

@synthesize info = _info, config = _config, continueGame = _continueGame, stopGame = _stopGame, newGame = _newGame;

-(id) init {

    if(!(self = [super initWithDelegate:self logo:nil items:
                 self.newGame       = [CCMenuItemFont itemFromString:l(@"menu.new")
                                                              target:self selector:@selector(newGame:)],
                 self.continueGame  = [CCMenuItemFont itemFromString:l(@"menu.continue.unpause")
                                                              target:self selector:@selector(continueGame:)],
                 self.stopGame      = [CCMenuItemFont itemFromString:l(@"menu.end")
                                                              target:self selector:@selector(stopGame:)],
                 [MenuItemSpacer spacerSmall],
                 self.info          = [CCMenuItemFont itemFromString:l(@"menu.information")
                                                              target:self selector:@selector(information:)],
#ifndef LITE
                 self.config        = [CCMenuItemFont itemFromString:l(@"menu.configuration")
                                                              target:self selector:@selector(options:)],
#endif
                 nil]))
        return self;

    return self;
}


- (void)onEnter {
    
    [self reset];
    
    [super onEnter];
}


-(void) reset {

    BOOL gameIsOn = [[GorillasAppDelegate get].gameLayer checkGameStillOn];//, gameWasOn = [self.continueGame isEnabled];
    
    //if(gameIsOn != gameWasOn)
        //TODO self.menu = nil;

    [self.newGame setIsEnabled:!gameIsOn];
    [self.continueGame setIsEnabled:gameIsOn];
    [self.stopGame setIsEnabled:gameIsOn];
}


-(void) newGame: (id)sender {
    
#ifdef LITE
    [[GorillasAppDelegate get].gameLayer configureGameWithMode:GorillasModeClassic
                                                     playerIDs:[NSArray arrayWithObject:[GKLocalPlayer localPlayer].playerID]
                                                           ais:1];
    [[GorillasAppDelegate get].gameLayer startGame];
#else
    [[GorillasAppDelegate get] showNewGame];
#endif    
}


-(void) continueGame: (id)sender {
    
    [[GorillasAppDelegate get].gameLayer setPaused:NO];
}


-(void) stopGame: (id)sender {
    
    [[GorillasAppDelegate get].gameLayer stopGame];
}


-(void) information: (id)sender {
    
    [[GorillasAppDelegate get] showInformation];
}


-(void) options: (id)sender {
    
    [[GorillasAppDelegate get] showConfiguration];
}


-(void) dealloc {

    self.newGame = nil;
    self.continueGame = nil;
    self.stopGame = nil;
    self.info = nil;
    self.config = nil;

    [super dealloc];
}


@end
