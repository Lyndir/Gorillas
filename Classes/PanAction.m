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
//  PanAction.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "PanAction.h"
#import "BuildingLayer.h"


@implementation PanAction


+(PanAction *) actionWithSubNodes: (NSMutableArray *)nSubNodes duration: (ccTime)nDuration padding: (int) nPadding {

    return [[[PanAction alloc] initWithSubNodes:nSubNodes duration:nDuration padding:nPadding] autorelease];
}


-(PanAction *) initWithSubNodes: (NSMutableArray *)nSubNodes duration: (ccTime)nDuration padding: (int)nPadding {

    CocosNode<CocosNodeSize> *firstNode = [nSubNodes objectAtIndex:0];
    if(!(self = [super initWithDuration:nDuration position:cpv(-[firstNode contentSize].width - nPadding, 0)]))
        return self;
    
    subNodes = [nSubNodes retain];
    padding = nPadding;
    cancelled = NO;
    
    return self;
}


-(void) update: (ccTime) dt {
    
    [super update: dt];
    
    if ([self isDone]) {
        CocosNode<Resettable> *firstNode = [subNodes objectAtIndex:0];
        CocosNode<CocosNodeSize> *lastNode = [subNodes lastObject];
        
        float x = [lastNode position].x + [lastNode contentSize].width + padding;

        [firstNode reset];
        [firstNode setPosition:cpv(x, 0)];
    
        [subNodes removeObject:firstNode];
        [subNodes addObject:firstNode];
    
        if(!cancelled) {
            CocosNode<CocosNodeSize> *newFirstNode = [subNodes objectAtIndex:0];
            delta = cpv(-[newFirstNode contentSize].width - padding, 0);
            [self start];
        }
    }
}


-(void) cancel {
    
    cancelled = YES;
}


-(void) dealloc {
    
    [subNodes release];
    subNodes = nil;
    
    [super dealloc];
}


@end
