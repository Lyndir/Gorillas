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
//  FancyLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 18/12/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface FancyLayer : Layer <CocosNodeOpacity, CocosNodeSize> {

    GLubyte opacity;
    CGSize  contentSize;
    float   outerPadding;
    float   padding;
    float   innerRatio;
    long    color;
    
    GLuint vertexBuffer;
    GLuint colorBuffer;
}

-(void) update;

@property (readwrite) GLubyte   opacity;
@property (readwrite) CGSize    contentSize;
@property (readwrite) float     outerPadding;
@property (readwrite) float     padding;
@property (readwrite) float     innerRatio;
@property (readwrite) long      color;

@end
