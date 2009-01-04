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
//  GorillaLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 07/11/08.
//  Copyright 2008, lhunath (Maarten Billemont). All rights reserved.
//

#import "GorillaLayer.h"
#import "Utility.h"
#import "GorillasConfig.h"


@implementation GorillaLayer

@synthesize human, alive, name;


-(id) init {
    
    if(!(self = [super initWithFile:@"gorilla.png"]))
        return self;
    
    [self setScale:[[GorillasConfig get] cityScale]];
    
    return self;
}


-(BOOL) hitsGorilla: (cpVect)pos {
    
    return  pos.x >= position.x - [self contentSize].width  / 2 &&
            pos.y >= position.y - [self contentSize].height / 2 &&
            pos.x <= position.x + [self contentSize].width  / 2 &&
            pos.y <= position.y + [self contentSize].height / 2;
}


-(CGSize) contentSize {
    
    return CGSizeMake([super contentSize].width * [self scale], [super contentSize].height * [self scale]);
}


-(void) dealloc {
    
    [name release];
    name = nil;
    
    [super dealloc];
}


@end
