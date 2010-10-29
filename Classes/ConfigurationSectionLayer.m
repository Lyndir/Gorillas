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
//  ConfigurationSectionLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 02/01/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "ConfigurationSectionLayer.h"
#import "GorillasAppDelegate.h"


@interface ConfigurationSectionLayer ()

- (void)game:(id)sender;
- (void)av:(id)sender;
- (void)models:(id)sender;
- (void)back:(id)selector;

@end

@implementation ConfigurationSectionLayer


-(id) init {
    
    if (!(self = [super init]))
        return nil;
    
    // Section menus.
    [CCMenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    [CCMenuItemFont setFontName:[GorillasConfig get].fontName];
    CCMenuItem *game      = [CCMenuItemFont itemFromString:NSLocalizedString(@"entries.gameplay", @"Gameplay")
                                                target:self
                                              selector:@selector(game:)];
    CCMenuItem *av        = [CCMenuItemFont itemFromString:NSLocalizedString(@"entries.av", @"Audio / Video")
                                                target:self
                                              selector:@selector(av:)];
    CCMenuItem *models    = [CCMenuItemFont itemFromString:NSLocalizedString(@"entries.models", @"Models")
                                                target:self
                                              selector:@selector(models:)];
    
    CCMenu *menu = [CCMenu menuWithItems:game, av, models, nil];
    [menu alignItemsVertically];
    [self addChild:menu];
    
    
    // Back.
    [CCMenuItemFont setFontSize:[[GorillasConfig get].largeFontSize intValue]];
    CCMenuItem *back     = [CCMenuItemFont itemFromString:@"   <   "
                                               target: self
                                             selector: @selector(back:)];
    [CCMenuItemFont setFontSize:[[GorillasConfig get].fontSize intValue]];
    
    CCMenu *backMenu = [CCMenu menuWithItems:back, nil];
    [backMenu setPosition:ccp([[GorillasConfig get].fontSize intValue], [[GorillasConfig get].fontSize intValue])];
    [backMenu alignItemsHorizontally];
    [self addChild:backMenu];
    
    return self;
}


- (void)reset {
}


-(void) onEnter {
    
    [self reset];
    
    [super onEnter];
}


-(void) game: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showGameConfiguration];
}


-(void) av: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showAVConfiguration];
}


-(void) models: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] showModelsConfiguration];
}


-(void) back: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {

    [super dealloc];
}


@end
