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


+(PanAction *) actionWithNode: (CocosNode *)initNode subNodes: (NSMutableArray *)initSubNodes nodeWidth: (float)width duration: (ccTime)seconds {

    return [[[PanAction alloc] initWithNode:initNode subNodes:initSubNodes nodeWidth:width duration:seconds] autorelease];
}


-(PanAction *) initWithNode: (CocosNode *)initNode subNodes: (NSMutableArray *)initSubNodes nodeWidth: (float)width duration: (ccTime)seconds {

    if(!(self = [super initWithDuration:seconds position:cpv(-width, 0)]))
        return self;
    
    node = initNode;
    subNodes = [initSubNodes retain];
    nodeWidth = width;
    cancelled = false;
    
    return self;
}


-(void) update: (ccTime) dt {
    
    [super update: dt];
    
    if ([self isDone]) {
        ResettableLayer *firstNode = [subNodes objectAtIndex:0];
        [firstNode reset];
    
        float x = [(CocosNode *)[subNodes lastObject] position].x + nodeWidth;
        [firstNode setPosition:cpv(x, 0)];
    
        [subNodes removeObject:firstNode];
        [subNodes addObject:firstNode];
    
        if(!cancelled)
            [self start];
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
