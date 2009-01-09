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
//  ShadeLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "ShadeLayer.h"
#import "GorillasAppDelegate.h"


@implementation ShadeLayer


-(id) init {

    if(!(self = [super init]))
        return self;
    
    [self setColor:[[GorillasConfig get] shadeColor]];
    [self setOpacity:0];
    
    return self;
}


-(void) onEnter {
    
    [super onEnter];
    
    [[[GorillasAppDelegate get] gameLayer] pause];
    
    for(CocosNode *child in children)
        if([child conformsToProtocol:@protocol(CocosNodeOpacity)])
            [child do:[FadeIn actionWithDuration:[[GorillasConfig get] transitionDuration]]];
    
    [self do:[Sequence actions:
              [FadeTo actionWithDuration:[[GorillasConfig get] transitionDuration]
                                 opacity:[[GorillasConfig get] shadeColor] & 0xff],
              [CallFunc actionWithTarget:self
                                selector:@selector(revealCallback:)],
              nil]];
}


-(void) revealCallback: (id) sender {
    
    [self ready];
}


-(void) ready {
    
    // Override me.
}


-(void) dismiss {

    [self stopAllActions];
    
    for(CocosNode *child in children)
        if([child conformsToProtocol:@protocol(CocosNodeOpacity)])
            [child do:[FadeTo actionWithDuration:[[GorillasConfig get] transitionDuration] opacity:0]];
    
    [self do:[Sequence actions:
              [FadeTo actionWithDuration:[[GorillasConfig get] transitionDuration] opacity:0],
              [CallFunc actionWithTarget:self selector:@selector(dismissCallback:)],
              nil]];
}


-(void) dismissCallback: (id) sender {

    [parent removeAndStop:self];
    
    [self gone];
}


-(void) gone {
    
    // Override me.
}


@end
