/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
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
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
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
    
    NSLog(@"real endcol: %08x", nColor);
    endCol = nColor;
    
    return self;
}


-(void) start {
    
    [super start];
    
    GLubyte *colors  = malloc(sizeof(GLubyte) * 4);
    colors[3] = [(TextureNode *)target r];
    colors[2] = [(TextureNode *)target g];
    colors[1] = [(TextureNode *)target b];
    colors[0] = [(TextureNode *)target opacity];
    
    long color = *colors;
    
    NSLog(@"start: %02x%02x%02x%02x - new start: %08x", [(TextureNode *)target r], [(TextureNode *)target g], [(TextureNode *)target b], [(TextureNode *)target opacity], color);
    startCol = color;
}


-(void) update: (ccTime) dt {

    /*[(TextureNode *)target setRGB: startCol[3] * (1 - dt) + endCol[3] * dt
                                 : startCol[2] * (1 - dt) + endCol[3] * dt
                                 : startCol[1] * (1 - dt) + endCol[3] * dt];
    [(TextureNode *)target setOpacity: startCol[0] * (1 - dt) + endCol[0] * dt];*/
}


@end
