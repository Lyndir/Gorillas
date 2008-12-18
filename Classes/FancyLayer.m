//
//  FancyLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/12/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "FancyLayer.h"


@implementation FancyLayer

@synthesize opacity, contentSize, padding, innerRatio, color;


- (id)init {
    
    if(!(self = [super init]))
        return self;
    
    int barHeight   = 0;
    if(![[UIApplication sharedApplication] isStatusBarHidden])
        if([[Director sharedDirector] landscape])
            barHeight   = [[UIApplication sharedApplication] statusBarFrame].size.width;
        else
            barHeight   = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    CGSize winSize  = [[Director sharedDirector] winSize].size;
    contentSize     = CGSizeMake(winSize.width, winSize.height - barHeight);
    padding         = 20;
    color           = 0x000000dd;
    opacity         = color & 0x000000ff;
    innerRatio      = 1.0f / 30;
    
    return self;
}


- (void)draw {
    
    int inner = contentSize.height * innerRatio;

    /*
     pos.x + pad                             pos.x + width - pad * 2 - inner
        |                                          |
        v                                          v
        .   3--------------------------------------5+10        <- pos.y + pad
           /                                        \
          /                                          \
         /                                            \
        1                                              9      <- pos.y + pad + inner
        |                                              |
        |                                              |
        2                                              7+8      <- pos.y + height - pad * 2 - inner
         \                                            /
          \                                          /
           \                                        /
            4--------------------------------------6          <- pos.y + height - pad * 2
            ^                                          ^
            |                                          |
      pos.x + pad + inner                        pos.x + width - pad * 2
     */
    const GLfloat vertices[10 * 2] = {
        position.x + padding,                               position.y + padding + inner,                       // 1
        position.x + padding,                               position.y + contentSize.height - padding - inner,  // 2
        position.x + padding + inner,                       position.y + padding,                               // 3
        position.x + padding + inner,                       position.y + contentSize.height - padding,          // 4
        position.x + contentSize.width - padding - inner,   position.y + padding,                               // 5
        position.x + contentSize.width - padding - inner,   position.y + contentSize.height - padding,          // 6
        position.x + contentSize.width - padding,           position.y + contentSize.height - padding - inner,  // 7
        position.x + contentSize.width - padding,           position.y + contentSize.height - padding - inner,  // 8
        position.x + contentSize.width - padding,           position.y + padding + inner,                       // 9
        position.x + contentSize.width - padding - inner,   position.y + padding,                               // 10
    };
    const GLubyte *colorBytes = (GLubyte *)&color;
    const GLubyte colors[10 * 4] = {
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
        colorBytes[3], colorBytes[2], colorBytes[1], colorBytes[0],
    };
    
    // Tell OpenGL about our data.
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glEnableClientState(GL_COLOR_ARRAY);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 10);
    
    // Reset data source.
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}


- (void)setColor: (long)c {
    
    color = c;
    
    const GLubyte *colorBytes = (GLubyte *)&color;
    opacity = colorBytes[0];
}


- (void)setOpacity: (GLubyte)o {
    
    opacity = o;
    color = (color & 0xffffff00) | opacity;
}


@end
