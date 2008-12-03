//
//  HUDLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 10/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "HUDLayer.h"
#import "GorillasAppDelegate.h"
#import "GorillasConfig.h"
#import "Utility.h"


@implementation HUDLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;

    width = [[Director sharedDirector] winSize].size.width;
    height = ([[GorillasConfig get] fixedFloors] - 1) * ([[GorillasConfig get] windowHeight] + [[GorillasConfig get] windowPadding]) + [[GorillasConfig get] windowPadding];
    position = cpv(0, -height);

    menuButton = [MenuItemFont itemFromString:@"                              " target:self selector:@selector(menuButton:)];
    
    menuMenu = [[Menu menuWithItems:menuButton, nil] retain];
    [menuMenu setPosition:cpv([menuMenu position].x, 0)];
    
    return self;
}


-(void) setMenuTitle: (NSString *)title {
    
    [[menuButton label] setString:title];
}


-(void) reveal {

    if(revealed)
        return;
    
    revealed = true;
    [self do:[MoveBy actionWithDuration:[[GorillasConfig get] transitionDuration] position:cpv(0, height)]];
    [self add:menuMenu];
}


-(void) dismiss {
    
    if(!revealed)
        return;
    
    revealed = false;
    [self do:[Sequence actions:
                  [MoveBy actionWithDuration:[[GorillasConfig get] transitionDuration] position:cpv(0, -height)],
                  [CallFunc actionWithTarget:self selector:@selector(gone)],
                  nil]];
}


-(void) gone {
    
    [self remove:menuMenu];
}


-(void) menuButton: (id) caller {
    
    [[GorillasAppDelegate get] showMainMenu];
}


-(BOOL) hitsHud: (cpVect)pos {
    
    return  pos.x >= position.x         &&
            pos.y >= position.y         &&
            pos.x <= position.x + width &&
            pos.y <= position.y + height;
}


-(void) draw {
    
    [Utility drawBoxFrom:cpv(0, 0) size:cpv(width, height) color:[[GorillasConfig get] shadeColor]];
}


-(void) dealloc {
    
    [super dealloc];
    
    [menuButton release];
    [menuMenu release];
}


@end
