//
//  ConfigurationSectionLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 02/01/09.
//  Copyright 2009 Lin.k. All rights reserved.
//

#import "ConfigurationSectionLayer.h"
#import "GorillasAppDelegate.h"


@implementation ConfigurationSectionLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    // Section menus.
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    [MenuItemFont setFontName:[[GorillasConfig get] fontName]];
    MenuItem *game  = [MenuItemFont itemFromString:@"Gameplay"
                                            target:self
                                          selector:@selector(game:)];
    MenuItem *av    = [MenuItemFont itemFromString:@"Audio / Video"
                                            target:self
                                          selector:@selector(av:)];
    
    menu = [[Menu menuWithItems:game, av, nil] retain];
    [menu alignItemsVertically];
    
    
    // Back.
    MenuItem *back     = [MenuItemFont itemFromString:@"<"
                                               target: self
                                             selector: @selector(mainMenu:)];
    
    backMenu = [[Menu menuWithItems:back, nil] retain];
    [backMenu setPosition:cpv([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [backMenu alignItemsHorizontally];
    
    return self;
}


-(void) reveal {
    
    [super reveal];
    
    [menu do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    [self add:menu];
    [backMenu do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    [self add:backMenu];
}


-(void) game: (id) sender {
    
    [[GorillasAppDelegate get] showGameConfiguration];
}


-(void) av: (id) sender {
    
    [[GorillasAppDelegate get] showAVConfiguration];
}


-(void) mainMenu: (id) sender {
    
    [[GorillasAppDelegate get] showMainMenu];
}


-(void) dealloc {
    
    [menu release];
    menu = nil;
    
    [backMenu release];
    backMenu = nil;
    
    [super dealloc];
}


@end
