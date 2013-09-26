/*
 * This file is part of Gorillas.
 *
 *  Gorillas is open software: you can use or modify it under the
 *  terms of the Java Research License or optionally a more
 *  permissive Commercial License.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  You should have received a copy of the Java Research License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://stuff.lhunath.com/COPYING>.
 */

//
//  HolesLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 04/01/09.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "HolesLayer.h"

@interface HolesLayer()

@property(nonatomic) BOOL dirty;
@end

@implementation HolesLayer { GLuint holeVertexObject; }

-(id) init {
    
    if(!(self = [super init]))
        return self;
    
    texture     = [[[CCTextureCache sharedTextureCache] addImage: @"hole.png"] retain];
    holes       = calloc( sizeof(glPoint), 0 );
    holeCount   = 0;
    
    self.scale  = GorillasModelScale(1.2f, texture.contentSize.width);
    self.shaderProgram = [PearlGLShaders pointSpriteShader];

    glGenVertexArrays( 1, &holeVertexObject );
    ccGLBindVAO( holeVertexObject );

    glEnableVertexAttribArray( kPearlGLVertexAttrib_Size );
    glGenBuffers( 1, &holeVertexBuffer );
    glBindBuffer( GL_ARRAY_BUFFER, holeVertexBuffer );
    glBufferData( GL_ARRAY_BUFFER, (GLsizei)(sizeof(glPoint) * holeCount), holes, GL_DYNAMIC_DRAW );
    glEnableVertexAttribArray( kCCVertexAttrib_Position );
    glVertexAttribPointer( kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, sizeof(glPoint), (GLvoid *)offsetof(glPoint, p));
    glEnableVertexAttribArray( kPearlGLVertexAttrib_Size );
    glVertexAttribPointer( kPearlGLVertexAttrib_Size, 2, GL_FLOAT, GL_FALSE, sizeof(glPoint), (GLvoid *)offsetof(glPoint, s));
    glEnableVertexAttribArray( kCCVertexAttrib_Color );
    glVertexAttribPointer( kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(glPoint), (GLvoid *)offsetof(glPoint, c));
    ccGLBindVAO( 0 );
    glBindBuffer( GL_ARRAY_BUFFER, 0 );
    glDisableVertexAttribArray( kPearlGLVertexAttrib_Size );
    CHECK_GL_ERROR_DEBUG();

    return self;
}


-(BOOL)isHoleAtWorld: (CGPoint)worldPos {
    
    CGPoint posPx = [self convertToNodeSpace:worldPos]; //ccpMult([self convertToNodeSpace:worldPos], CC_CONTENT_SCALE_FACTOR());
    CGFloat d = powf(texture.contentSize.width / 4, 2);
    for(NSUInteger h = 0; h < holeCount; ++h) {
        CGFloat x = holes[h].p.x - posPx.x, y = holes[h].p.y - posPx.y;
        if ((powf(x, 2) + powf(y, 2)) < d)
            return YES;
    }
    
    return NO;
} 


-(void) addHoleAtWorld:(CGPoint)worldPos {
    
    holes = realloc(holes, sizeof(glPoint) * ++holeCount);
    holes[holeCount - 1].p = [self convertToNodeSpace:worldPos]; //ccpMult([self convertToNodeSpace:worldPos], CC_CONTENT_SCALE_FACTOR());
    holes[holeCount - 1].c = ccc4l(0xffffffffUL);
    holes[holeCount - 1].s = texture.contentSize.width * self.scale * CC_CONTENT_SCALE_FACTOR(); // Scale seems to not affect pointsize.

    self.dirty = YES;
}


-(void) draw {

    if (!holeCount)
        return;

    [super draw];

    CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"HolesLayer - draw");
    if (self.dirty) {
        glBindBuffer( GL_ARRAY_BUFFER, holeVertexBuffer );
        glBufferData( GL_ARRAY_BUFFER, (GLsizei)(sizeof(glPoint) * holeCount), holes, GL_DYNAMIC_DRAW );
        glBindBuffer( GL_ARRAY_BUFFER, 0 );
        self.dirty = NO;
    }

    CC_NODE_DRAW_SETUP();
    ccGLBindVAO( holeVertexObject );

////    // Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
////    //glEnableClientState(GL_COLOR_ARRAY);
////    //glEnableClientState(GL_VERTEX_ARRAY);
////    glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
////    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
////    //glEnable(GL_TEXTURE_2D);
////    glEnable(GL_POINT_SPRITE_OES);
//    ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color);
//    glEnableVertexAttribArray(kPearlGLVertexAttrib_Size);

    // Blend our transarent white with DST.  If SRC, make DST transparent, hide original DST.
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE);
    ccGLBlendFunc(GL_ZERO, GL_SRC_ALPHA);

    ccGLBindTexture2D(texture.name);

//    glBindBuffer(GL_ARRAY_BUFFER, holeVertexBuffer);
//    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, sizeof(glPoint), (GLvoid *) offsetof(glPoint, p));
//    glVertexAttribPointer(kPearlGLVertexAttrib_Size, 2, GL_FLOAT, GL_FALSE, sizeof(glPoint), (GLvoid *) offsetof(glPoint, s));
//    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(glPoint), (GLvoid *) offsetof(glPoint, c));

    glDrawArrays(GL_POINTS, 0, (GLsizei)holeCount);

    // unbind VBO buffer
//    glBindBuffer(GL_ARRAY_BUFFER, 0);
//    glDisableVertexAttribArray(kPearlGLVertexAttrib_Size);

    // Reset blend & data source.
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
//    ccGLBlendFunc( CC_BLEND_SRC, CC_BLEND_DST );


//    //glDisableClientState(GL_COLOR_ARRAY);
//    //glDisableClientState(GL_VERTEX_ARRAY);
//    glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
//    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
//    //glDisable(GL_TEXTURE_2D);
//    glDisable(GL_POINT_SPRITE_OES);

    CHECK_GL_ERROR_DEBUG();
    CC_INCREMENT_GL_DRAWS(1);
    CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"HolesLayer - draw");
}


-(void) dealloc {
    
    glDeleteVertexArrays( 1, &holeVertexObject );
    glDeleteBuffers(1, &holeVertexBuffer);
    CHECK_GL_ERROR_DEBUG();
    
    [super dealloc];
}


@end
