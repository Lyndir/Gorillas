//
//  BarSprite.h
//  Gorillas
//
//  Created by Maarten Billemont on 27/06/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BarSprite : Layer {

@private
    Texture2D           *head, **body, *tail;
    NSUInteger          bodyFrame, bodyFrames;
    
    CGPoint              halfToHead;
    CGFloat             halfLength;
    
    CGSize              textureSize;
}


#pragma mark ###############################
#pragma mark Lifecycle

- (id) initWithHead:(NSString *)bundleHeadReference body:(NSString *)bundleBodyReference withFrames:(NSUInteger)bodyFrameCount tail:(NSString *)bundleTailReference;


#pragma mark ###############################
#pragma mark Behaviors

- (void)updateWithOrigin:(CGPoint)o target:(CGPoint)t;

@property (readwrite) CGSize    textureSize;

@end
