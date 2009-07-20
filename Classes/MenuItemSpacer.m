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
//  MenuItemSpacer.m
//  Gorillas
//
//  Created by Maarten Billemont on 02/03/09.
//  Copyright 2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "MenuItemSpacer.h"


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
    
    return [self initWithHeight:[[GorillasConfig get].smallFontSize intValue]];
}

-(id) initNormal {
    
    return [self initWithHeight:[[GorillasConfig get].fontSize intValue]];
}

-(id) initLarge {
    
    return [self initWithHeight:[[GorillasConfig get].largeFontSize intValue]];
}


-(id) initWithHeight:(CGFloat)_height {
    
    if(!(self = [super initWithTarget:nil selector:nil]))
        return self;
    
    height = _height;
    [self setIsEnabled:NO];
    
    return self;
}


-(CGRect) rect {
    
	return CGRectMake(self.position.x, self.position.y - height / 2, self.position.x, self.position.y + height / 2);
}


-(CGSize) contentSize {
    
	return CGSizeMake(0, height);
}


@end
