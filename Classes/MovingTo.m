//
//  MovingTo.m
//  Gorillas
//
//  Created by Maarten Billemont on 03/11/10.
//  Copyright 2010 lhunath (Maarten Billemont). All rights reserved.
//

#import "MovingTo.h"


@implementation MovingTo

- (id)initWithDuration:(ccTime)t position:(CGPoint)p {
	if(!(self = [super initWithDuration:t position:p]))
        return self;
    
    stepDuration = t;
    
	return self;
}

- (void)updatePosition:(CGPoint)pos {
    
    endPosition = pos;
	startPosition = [(CCNode*)target_ position];
	delta = ccpSub( endPosition, startPosition );
    duration_ = elapsed_ + stepDuration;
    dbg(@"startPosition: %@", NSStringFromCGPoint(startPosition));
    dbg(@"endPosition: %@", NSStringFromCGPoint(endPosition));
    dbg(@"delta: %@", NSStringFromCGPoint(delta));
    dbg(@"elapsed: %f", elapsed_);
    dbg(@"duration: %f", duration_);
    dbg(@"duration left: %f", duration_ - elapsed_);
}

-(void) update: (ccTime) t {
    
    [super update:t];
}

@end
