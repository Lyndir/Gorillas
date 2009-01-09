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


+(ShadeTo *) actionWithColor: (long)nColor duration: (ccTime)nDuration {
    
    return [[[ShadeTo alloc] initWithColor: nColor duration: nDuration] autorelease];
}


-(ShadeTo *) initWithColor: (long)nColor duration: (ccTime)nDuration {
    
    if(!(self = [super initWithDuration:nDuration]))
        return self;
    
    endCol = nColor;
    
    return self;
}


-(void) start {
    
    if(![target respondsToSelector:@selector(setRGB:::)])
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"ShadeTo action target does not respond to setRGB:::" userInfo:nil];
    if(![target conformsToProtocol:@protocol(CocosNodeOpacity)])
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"ShadeTo action target does not conform to CocosNodeOpacity" userInfo:nil];
        
    startCol    = [(TextureNode *)target r] << 24
                | [(TextureNode *)target g] << 16
                | [(TextureNode *)target b] << 8
                | [(TextureNode *)target opacity];
    
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
