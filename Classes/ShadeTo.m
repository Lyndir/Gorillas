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
//  ShadeTo.m
//  Gorillas
//
//  Created by Maarten Billemont on 22/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "ShadeTo.h"
#import "GorillasAppDelegate.h"


@implementation ShadeTo


+(ShadeTo *) actionWithDuration:(ccTime)_duration color:(long)_color {
    
    return [[[ShadeTo alloc] initWithDuration:_duration color:_color] autorelease];
}


-(ShadeTo *) initWithDuration:(ccTime)_duration color:(long)_color {
    
    if(!(self = [super initWithDuration: _duration]))
        return self;
    
    endCol = _color;
    
    return self;
}


-(void) startWithTarget:(CocosNode *)aTarget {
    
    [super startWithTarget:aTarget];
    
    if(![target conformsToProtocol:@protocol(CocosNodeRGBA)])
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"ShadeTo action target does not conform to CocosNodeRGBA" userInfo:nil];
    
    startCol    = [(CocosNode< CocosNodeRGBA> *) target r] << 24
                | [(CocosNode< CocosNodeRGBA> *) target g] << 16
                | [(CocosNode< CocosNodeRGBA> *) target b] << 8
                | [(CocosNode< CocosNodeRGBA> *) target opacity];
}


-(void) update: (ccTime) dt {
    
    const GLubyte *s = (GLubyte *)&startCol, *e = (GLubyte *)&endCol;
    
    [(id)target setRGB: (int) (s[3] * (1 - dt)) + (int) (e[3] * dt)
                      : (int) (s[2] * (1 - dt)) + (int) (e[2] * dt)
                      : (int) (s[1] * (1 - dt)) + (int) (e[1] * dt)];
    [(id<CocosNodeRGBA>)target setOpacity: (int) (s[0] * (1 - dt)) + (int) (e[0] * dt)];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
