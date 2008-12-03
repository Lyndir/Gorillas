//
//  MenuLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "ShadeLayer.h"
#import "GorillasAppDelegate.h"


@implementation ShadeLayer


@synthesize showing;


-(id) init {

    if(!(self = [super initWithColor: [[GorillasConfig get] shadeColor]]))
        return self;
    
    [self setOpacity:0];
    
    return self;
}


-(void) reveal {
    
    [[[GorillasAppDelegate get] gameLayer] pause];
    
    [self stopAllActions];
    
    [self do:[Sequence actions:
              [FadeTo actionWithDuration:[[GorillasConfig get] transitionDuration] opacity:[[GorillasConfig get] shadeColor] & 0xff],
              [CallFunc actionWithTarget:self selector:@selector(revealCallback:)],
              nil]];

    showing = true;
}


-(void) revealCallback: (id) sender {
    
    [self ready];
}


-(void) ready {
    
    // Override me.
}


-(void) dismiss {

    [self stopAllActions];
    
    for(CocosNode *child in children) {
        if([child conformsToProtocol:@protocol(CocosNodeOpacity)])
            [child do:[FadeOut actionWithDuration:[[GorillasConfig get] transitionDuration]]];
        else
            [child setVisible:false];
    }
    
    [self do:[Sequence actions:
              [FadeTo actionWithDuration:[[GorillasConfig get] transitionDuration] opacity:0],
              [CallFunc actionWithTarget:self selector:@selector(dismissCallback:)],
              nil]];
    
    showing = false;
}


-(void) dismissCallback: (id) sender {
    
    [self gone];
    
    for(CocosNode *child in children)
        [self remove:child];
    
}


-(void) gone {
    
    // Override me.
}


@end
