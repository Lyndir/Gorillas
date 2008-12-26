//
//  FancyLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/12/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "FancyLayer.h"


@implementation FancyLayer

@synthesize opacity, contentSize, outerPadding, padding, innerRatio, color;


- (id)init {
    
    if(!(self = [super init]))
        return self;
    
    int barHeight   = 0;
    if(![[UIApplication sharedApplication] isStatusBarHidden]) {
        if([[Director sharedDirector] landscape])
            barHeight   = [[UIApplication sharedApplication] statusBarFrame].size.width;
        else
            barHeight   = [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    
    CGSize winSize  = [[Director sharedDirector] winSize].size;
    contentSize     = CGSizeMake(winSize.width, winSize.height - barHeight);
    outerPadding    = 5.0f;
    padding         = 50.0f;
    color           = 0x000000dd;
    opacity         = color & 0x000000ff;
    innerRatio      = 1.0f / padding;
    
    [self update];
    
    return self;
}


-(void) update {
    
    int inner = contentSize.height * innerRatio;
    
    /*
     pos.x + pad                                pos.x + width - pad - inner
     |                                             |
     v                                             v
     .   2+10--------------------------------------9         <- pos.y + pad
     /                                           \
     /                                             \
     /                                               \
     3                                                 8     <- pos.y + pad + inner
     |                                                 |
     |                        1                        |
     |                                                 |
     4                                                 7     <- pos.y + height - pad - inner
     \                                               /
     \                                             /
     \                                           /
     5-----------------------------------------6         <- pos.y + height - pad
     ^                                             ^
     |                                             |
     pos.x + pad + inner                           pos.x + width - pad
     */
    if(vertices)
        free(vertices);
    if(colors)
        free(colors);
    vertices        = malloc(sizeof(GLfloat) * 10 * 2);
    vertices[0]     = contentSize.width / 2;                                    // 1
    vertices[1]     = contentSize.height / 2;
    vertices[2]     = position.x + outerPadding + inner;                        // 2
    vertices[3]     = position.y + outerPadding;
    vertices[4]     = position.x + outerPadding;                                // 3
    vertices[5]     = position.y + outerPadding + inner;
    vertices[6]     = position.x + outerPadding;                                // 4
    vertices[7]     = position.y + contentSize.height - outerPadding - inner;
    vertices[8]     = position.x + outerPadding + inner;                        // 5
    vertices[9]     = position.y + contentSize.height - outerPadding;
    vertices[10]    = position.x + contentSize.width - outerPadding - inner;    // 6
    vertices[11]    = position.y + contentSize.height - outerPadding;
    vertices[12]    = position.x + contentSize.width - outerPadding;            // 7
    vertices[13]    = position.y + contentSize.height - outerPadding - inner;
    vertices[14]    = position.x + contentSize.width - outerPadding;            // 8
    vertices[15]    = position.y + outerPadding + inner;
    vertices[16]    = position.x + contentSize.width - outerPadding - inner;    // 9
    vertices[17]    = position.y + outerPadding;
    vertices[18]    = position.x + outerPadding + inner;                        // 10
    vertices[19]    = position.y + outerPadding;

    const GLubyte *colorBytes = (GLubyte *)&color;
    colors = malloc(sizeof(GLubyte) * 10 * 4);
    for(int i = 0; i < 10; ++i) {
        colors[i * 4 + 0] = colorBytes[3];
        colors[i * 4 + 1] = colorBytes[2];
        colors[i * 4 + 2] = colorBytes[1];
        colors[i * 4 + 3] = colorBytes[0];
    }
}


- (void)draw {
    
    // Tell OpenGL about our data.
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
	glEnableClientState(GL_COLOR_ARRAY);
	
	glDrawArrays(GL_TRIANGLE_FAN, 0, 10);
    
    // Reset data source.
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}


- (void)setColor: (long)c {
    
    color = c;
    
    const GLubyte *colorBytes = (GLubyte *)&color;
    opacity = colorBytes[0];

    [self update];
}


- (void)setOpacity: (GLubyte)o {
    
    opacity = o;
    color = (color & 0xffffff00) | opacity;
    
    [self update];
}


@end
