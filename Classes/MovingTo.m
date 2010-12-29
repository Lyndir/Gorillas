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
    
	return self;
}

- (void)updatePosition:(CGPoint)pos {

    dbg(@"before: %@ -> %@, %f/%f", NSStringFromCGPoint(startPosition), NSStringFromCGPoint(endPosition), elapsed_, duration_);
    endPosition = pos;
	startPosition = [(CCNode*)target_ position];
	delta = ccpSub( endPosition, startPosition );
    elapsed_ = 0;
    dbg(@"after: %@ -> %@, %f/%f", NSStringFromCGPoint(startPosition), NSStringFromCGPoint(endPosition), elapsed_, duration_);
}

@end
