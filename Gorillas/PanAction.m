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
#import "PearlResettable.h"


@implementation PanAction


+(PanAction *) actionWithSubNodes: (NSMutableArray *)nSubNodes duration: (ccTime)nDuration padding: (int) nPadding {

    return [[[PanAction alloc] initWithSubNodes:nSubNodes duration:nDuration padding:nPadding] autorelease];
}


-(PanAction *) initWithSubNodes: (NSMutableArray *)nSubNodes duration: (ccTime)nDuration padding: (int)nPadding {

    CCNode *firstNode = [nSubNodes objectAtIndex:0];
    if(!(self = [super initWithDuration:nDuration position:ccp(-([firstNode contentSize].width + nPadding), 0)]))
        return self;
    
    subNodes = [nSubNodes retain];
    padding = nPadding;
    cancelled = NO;
    
    return self;
}


-(void) update: (ccTime) dt {
    
    [super update: dt];
    
    if ([self isDone]) {
        CCNode<PearlResettable> *firstNode = [subNodes objectAtIndex:0];
        CCNode *lastNode = [subNodes lastObject];
        
        float x = [lastNode position].x + [lastNode contentSize].width + padding;

        [firstNode reset];
        [firstNode setPosition:ccp(x, 0)];
    
        [subNodes removeObject:firstNode];
        [subNodes addObject:firstNode];
    
        if(!cancelled) {
            CCNode *newFirstNode = [subNodes objectAtIndex:0];
            _positionDelta = ccp(-[newFirstNode contentSize].width - padding, 0);
            [self startWithTarget:self.target];
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
