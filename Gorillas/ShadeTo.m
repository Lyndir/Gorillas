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


+(ShadeTo *) actionWithDuration:(ccTime)_duration color:(ccColor4B)_color {
    
    return [[[ShadeTo alloc] initWithDuration:_duration color:_color] autorelease];
}


-(ShadeTo *) initWithDuration:(ccTime)aDuration color:(ccColor4B)_color {
    
    if(!(self = [super initWithDuration:aDuration]))
        return self;
    
    endCol = _color;
    
    return self;
}


-(void) startWithTarget:(CCNode *)aTarget {
    
    [super startWithTarget:aTarget];
    
    if(![self.target conformsToProtocol:@protocol(CCRGBAProtocol)]) {
        err(@"ShadeTo action target does not conform to CCRGBAProtocol");
        return;
    }
    
    startCol    = ccc3to4([(CCNode<CCRGBAProtocol> *) self.target color]);
    startCol.a  = [(CCNode<CCRGBAProtocol> *) self.target opacity];
}


-(void) update: (ccTime) dt {
    
    [(id<CCRGBAProtocol>)self.target setColor:ccc3((GLubyte)(startCol.r * (1-dt) + endCol.r * dt),
                                                   (GLubyte)(startCol.g * (1-dt) + endCol.g * dt),
                                                   (GLubyte)(startCol.b * (1-dt) + endCol.b * dt))];
    [(id<CCRGBAProtocol>)self.target setOpacity:(GLubyte)(startCol.a * (1-dt) + endCol.a * dt)];
}


-(void) dealloc {
    
    [super dealloc];
}


@end
