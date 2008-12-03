//
//  Throw.h
//  Gorillas
//
//  Created by Maarten Billemont on 22/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface Throw : IntervalAction {

    @private
    BOOL running;
    cpVect v;
    cpVect r0;
}

+(Throw *) actionWithVelocity: (cpVect)velocity startPos: (cpVect)startPos;
-(Throw *) initWithVelocity: (cpVect)velocity startPos: (cpVect)startPos;

@end
