//
//  SkiesLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "Resettable.h"


@interface SkiesLayer : Layer <Resettable> {

    NSMutableArray *skies;
}

@end
