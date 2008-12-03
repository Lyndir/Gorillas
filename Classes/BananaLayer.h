//
//  BananaLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 08/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


@interface BananaLayer : Sprite /* Layer */ {

    BOOL clearedGorilla;
    
    /*GLfloat *vertices;
    GLubyte *colors;*/
}

@property (readwrite) BOOL clearedGorilla;
@property (readonly) float width;
@property (readonly) float height;

@end
