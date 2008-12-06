//
//  PanAction.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "PanAction.h"
#import "BuildingLayer.h"


@implementation PanAction


+(PanAction *) actionWithSubNodes: (NSMutableArray *)nSubNodes duration: (ccTime)nDuration padding: (int) nPadding {

    return [[[PanAction alloc] initWithSubNodes:nSubNodes duration:nDuration padding:nPadding] autorelease];
}


-(PanAction *) initWithSubNodes: (NSMutableArray *)nSubNodes duration: (ccTime)nDuration padding: (int)nPadding {

    if(!(self = [super initWithDuration:nDuration position:cpv(-[(id<CocosNodeSize>)[subNodes objectAtIndex:0] contentSize].width - nPadding, 0)]))
        return self;
    
    subNodes = [nSubNodes retain];
    padding = nPadding;
    cancelled = false;
    
    return self;
}


-(void) update: (ccTime) dt {
    
    [super update: dt];
    
    if ([self isDone]) {
        ResettableLayer *firstNode = [subNodes objectAtIndex:0];
        [firstNode reset];
    
        float x = [(CocosNode *)[subNodes lastObject] position].x + [(id<CocosNodeSize>)[subNodes lastObject] contentSize].width + padding;
        [firstNode setPosition:cpv(x, 0)];
    
        [subNodes removeObject:firstNode];
        [subNodes addObject:firstNode];
    
        if(!cancelled) {
            delta = cpv(-[(id<CocosNodeSize>)[subNodes objectAtIndex:0] contentSize].width - padding, 0);
            [self start];
        }
    }
}


-(void) cancel {
    
    cancelled = true;
}


-(void) dealloc {
    
    [super dealloc];
    
    [subNodes release];
}


@end
