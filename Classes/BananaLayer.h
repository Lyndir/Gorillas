//
//  BananaLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 08/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface BananaLayer : Sprite {

    BOOL clearedGorilla;
}

@property (readwrite) BOOL clearedGorilla;

@end
