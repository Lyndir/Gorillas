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
//  BananaLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 08/11/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "BananaLayer.h"


@implementation BananaLayer

@synthesize clearedGorilla;


-(id) init {
    
    if(!(self = [super initWithFile:@"banana.png"]))
        return self;
    
    return self;
}


-(float) width {
    
    return [self contentSize].width;
}


-(float) height {
    
    return [self contentSize].height;
}


@end
