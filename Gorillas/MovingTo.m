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

    endPosition_ = pos;
    startPosition_ = [(CCNode*)target_ position];
    delta_ = ccpSub( endPosition_, startPosition_ );
    elapsed_ = 0;
}

@end
