//
//  ShadeTo.h
//  Gorillas
//
//  Created by Maarten Billemont on 22/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface ShadeTo : IntervalAction {

    long startCol, endCol;
}

+(ShadeTo *) actionWithColor: (long)nColorr duration: (ccTime)nDuration;
-(ShadeTo *) initWithColor: (long)nColor duration: (ccTime)nDuration;

@end
