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


@implementation ConfigurationSectionLayer


-(void) reset {
    
    if(menu) {
        [self removeChild:menu cleanup:YES];
        [menu release];
        menu = nil;
        
        [self removeChild:backMenu cleanup:YES];
        [backMenu release];
        backMenu = nil;
    }
    
    // Section menus.
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *game      = [MenuItemFont itemFromString:NSLocalizedString(@"entries.gameplay", @"Gameplay")
                                                target:self
                                              selector:@selector(game:)];
    MenuItem *av        = [MenuItemFont itemFromString:NSLocalizedString(@"entries.av", @"Audio / Video")
                                                target:self
                                              selector:@selector(av:)];
    MenuItem *models    = [MenuItemFont itemFromString:NSLocalizedString(@"entries.models", @"Models")
                                                target:self
                                              selector:@selector(models:)];
    
    menu = [[Menu menuWithItems:game, av, models, nil] retain];
    [menu alignItemsVertically];
    [self addChild:menu];
    
    
    // Back.
    [MenuItemFont setFontSize:[[GorillasConfig get] largeFontSize]];
    MenuItem *back     = [MenuItemFont itemFromString:@"   <   "
                                               target: self
                                             selector: @selector(back:)];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    
    backMenu = [[Menu menuWithItems:back, nil] retain];
    [backMenu setPosition:ccp([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [backMenu alignItemsHorizontally];
    [self addChild:backMenu];
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
    
    [menu release];
    menu = nil;
    
    [backMenu release];
    backMenu = nil;
    
    [super dealloc];
}


@end
