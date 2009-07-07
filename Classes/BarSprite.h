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

    CGFloat             age;
    NSUInteger          bodyFrame, bodyFrames;
    
    BOOL                animatedTargetting;
    ccTime              smoothTimeElapsed;
    CGPoint             target;
    
    CGPoint             current;
    CGFloat             currentLength;
    
    CGSize              textureSize;
}


#pragma mark ###############################
#pragma mark Lifecycle

- (id) initWithHead:(NSString *)bundleHeadReference body:(NSString *)bundleBodyReference withFrames:(NSUInteger)bodyFrameCount tail:(NSString *)bundleTailReference animatedTargetting:(BOOL)anAnimatedTargetting;


@property (readwrite, assign) CGPoint   target;
@property (readwrite, assign) CGSize    textureSize;

@end
