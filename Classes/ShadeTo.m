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
//  ShadeTo.m
//  Gorillas
//
//  Created by Maarten Billemont on 22/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "ShadeTo.h"
#import "GorillasConfig.h"
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


-(void) start {
    
    if(![target conformsToProtocol:@protocol(CocosNodeRGB)])
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"ShadeTo action target does not cinform to CocosNodeRGB" userInfo:nil];
    if(![target conformsToProtocol:@protocol(CocosNodeOpacity)])
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"ShadeTo action target does not conform to CocosNodeOpacity" userInfo:nil];
    
    startCol    = [(CocosNode< CocosNodeRGB> *)     target r] << 24
                | [(CocosNode< CocosNodeRGB> *)     target g] << 16
                | [(CocosNode< CocosNodeRGB> *)     target b] << 8
                | [(CocosNode< CocosNodeOpacity> *) target opacity];
    
    [super start];
}


-(void) update: (ccTime) dt {
    
    const GLubyte *s = (GLubyte *)&startCol, *e = (GLubyte *)&endCol;
    
    [(id)target setRGB: (int) (s[3] * (1 - dt)) + (int) (e[3] * dt)
                      : (int) (s[2] * (1 - dt)) + (int) (e[2] * dt)
                      : (int) (s[1] * (1 - dt)) + (int) (e[1] * dt)];
    [(id<CocosNodeOpacity>)target setOpacity: (int) (s[0] * (1 - dt)) + (int) (e[0] * dt)];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
