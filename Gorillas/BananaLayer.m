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
//  BananaLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 08/11/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "BananaLayer.h"

@interface BananaLayer(Private)

- (NSString *)modelFile;

@end

@implementation BananaLayer

- (id)init {

    if (!(self = [super init]))
        return self;

    self.model = GorillasProjectileModelBanana;

    self.banana = [CCSprite spriteWithFile:[self modelFile]];
    self.banana.visible = NO;
    self.banana.tag = GorillasTagBananaNotFlying;

    return self;
}

- (void)setModel:(GorillasProjectileModel)aModel type:(GorillasPlayerType)aType {

    self.model = aModel;
    self.type = aType;

    [self.banana setTexture:[[CCTextureCache sharedTextureCache] addImage:[self modelFile]]];
}

- (CCSprite *)bananaForThrowFrom:(GorillaLayer *)gorilla {

    [self setModel:gorilla.projectileModel type:gorilla.type];
    self.banana.position = gorilla.position;
    self.banana.scale = gorilla.scale;

    return self.banana;
}

- (void)onEnter {

    [super onEnter];

    [self addChild:self.banana];
    [self.banana runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1 angle:360]]];
}

- (void)onExit {

    [super onExit];

    [self.banana stopAllActions];
    [self removeChild:self.banana cleanup:YES];
}

- (BOOL)throwing {

    return [self.banana tag] == GorillasTagBananaFlying;
}

- (NSString *)modelFile {

    NSString *modelName, *typeName;
    switch (self.model) {
        case GorillasProjectileModelBanana:
            modelName = @"banana";
            break;
        case GorillasProjectileModelEasterEgg:
            modelName = @"egg";
            break;
        case GorillasProjectileModelGorilla:
            modelName = @"gorilla";
            break;
        default:
            err(@"Active banana model not implemented.");
            return nil;
    }
    switch (self.type) {
        case GorillasPlayerTypeAI:
            typeName = @"ai";
            break;
        case GorillasPlayerTypeHuman:
            typeName = @"human";
            break;
        default:
            err(@"Active gorilla model not implemented.");
            return nil;
    }

    return [NSString stringWithFormat:@"%@-%@.png", modelName, typeName];
}

@end
