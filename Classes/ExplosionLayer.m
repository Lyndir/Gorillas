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
//  ExplosionLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 04/11/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "ExplosionLayer.h"
#import "ExplosionAnimationLayer.h"


@implementation ExplosionLayer


-(id) init {
    
    if(!(self = [super initWithFile:@"hole.png"]))
        return self;
    
    [self add:[ExplosionAnimationLayer get] z:-9];
    
    return self;
}


-(BOOL) hitsExplosion: (cpVect)pos {
    
    return ((position.x - pos.x) * (position.x - pos.x) +
            (position.y - pos.y) * (position.y - pos.y) ) < ([self width] * [self width]) / 9;
}


-(void) draw {
    
    // Blend our transarent white with DST.  If SRC, make DST transparent, hide original DST.
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE);
    glBlendFunc(GL_ZERO, GL_SRC_ALPHA);
    
    [super draw];
    
    // Reset blend & data source.
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}


-(float) width {
    
    return [self contentSize].width;
}


-(float) height {
    
    return [self contentSize].height;
}


@end
