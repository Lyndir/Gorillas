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
//  MenuItemSpacer.m
//  Gorillas
//
//  Created by Maarten Billemont on 02/03/09.
//  Copyright 2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "MenuItemSpacer.h"
#import "GorillasConfig.h"


@implementation MenuItemSpacer

+(id) small {
    
    return [[[MenuItemSpacer alloc] initSmall] autorelease];
}

+(id) normal {
    
    return [[[MenuItemSpacer alloc] initNormal] autorelease];
}

+(id) large {
    
    return [[[MenuItemSpacer alloc] initLarge] autorelease];
}

-(id) initSmall {
    
    return [self initWithHeight:[[GorillasConfig get] smallFontSize]];
}

-(id) initNormal {
    
    return [self initWithHeight:[[GorillasConfig get] fontSize]];
}

-(id) initLarge {
    
    return [self initWithHeight:[[GorillasConfig get] largeFontSize]];
}


-(id) initWithHeight:(cpFloat)_height {
    
    if(!(self = [super initWithTarget:nil selector:nil]))
        return self;
    
    height = _height;
    [self setIsEnabled:false];
    
    return self;
}


-(CGRect) rect {
    
	return CGRectMake(position.x, position.y - height / 2, position.x, position.y + height / 2);
}


-(CGSize) contentSize {
    
	return CGSizeMake(0, height);
}


@end
