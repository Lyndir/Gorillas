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
//  ModelsConfigurationLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 31/03/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import "ModelsConfigurationLayer.h"
#import "GorillasAppDelegate.h"


@implementation ModelsConfigurationLayer


-(id) init {

    if(!(self = [super init]))
        return self;

    // Models Content.
    modelSprites = [[NSMutableArray alloc] initWithCapacity:2];
    modelTitles = [[NSMutableArray alloc] initWithCapacity:2];

    [modelSprites addObject:[NSNumber numberWithUnsignedInt:GorillasPlayerModelGorilla]];
    [modelTitles addObject:NSLocalizedString(@"model.gorilla", @"Mean Gorilla")];

    [modelSprites addObject:[NSNumber numberWithUnsignedInt:GorillasPlayerModelEasterBunny]];
    [modelTitles addObject:NSLocalizedString(@"model.bunny", @"Easter Bunny")];
    
    [modelSprites addObject:[NSNumber numberWithUnsignedInt:GorillasPlayerModelBanana]];
    [modelTitles addObject:NSLocalizedString(@"model.banana", @"Vengeful Banana")];
    
    
    // Controls.
    [MenuItemFont setFontSize:[[GorillasConfig get] largeFontSize]];
    MenuItem *back     = [MenuItemFont itemFromString:@"   <   "
                                               target: self
                                             selector: @selector(back:)];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    
    backMenu = [[Menu menuWithItems:back, nil] retain];
    [backMenu setPosition:cpv([[GorillasConfig get] fontSize], [[GorillasConfig get] fontSize])];
    [backMenu alignItemsHorizontally];
    [self addChild:backMenu];
    
    [MenuItemFont setFontSize:15];
    modelNext = [[MenuItemFont itemFromString:@"                              " target:self selector:@selector(next:)] retain];
    [MenuItemFont setFontSize:26];
    modelCurr = [[MenuItemFont itemFromString:@"                              "] retain];
    [modelCurr setIsEnabled:NO];
    modelMenu = [[Menu menuWithItems:modelCurr, modelNext, nil] retain];
    [modelMenu alignItemsHorizontally];
    [modelMenu setPosition:cpv(modelMenu.position.x, contentSize.height - padding + 10)];
    [self addChild:modelMenu];
    [MenuItemFont setFontSize:[[GorillasConfig get] fontSize]];
    
    CGSize winSize = [[Director sharedDirector] winSize];
    prevModelSprite = [[GorillaLayer alloc] initWithName:@"" type:GorillasPlayerTypeHuman];
    currModelSprite = [[GorillaLayer alloc] initWithName:@"" type:GorillasPlayerTypeHuman];
    nextModelSprite = [[GorillaLayer alloc] initWithName:@"" type:GorillasPlayerTypeHuman];
    [prevModelSprite setPosition:cpv(winSize.width / 2 - winSize.width, winSize.height / 2)];
    [currModelSprite setPosition:cpv(winSize.width / 2, winSize.height / 2)];
    [nextModelSprite setPosition:cpv(winSize.width / 2 + winSize.width, winSize.height / 2)];

    swipeLayer = [[SwipeLayer alloc] initWithTarget:self selector:@selector(swiped:)];
    [self addChild:swipeLayer];
    [swipeLayer addChild:prevModelSprite];
    [swipeLayer addChild:currModelSprite];
    [swipeLayer addChild:nextModelSprite];
    [swipeLayer setSwipeAreaFrom:cpv(50, [GorillasConfig get].fontSize * 2)
                              to:cpv(winSize.width - 50, winSize.height - [GorillasConfig get].fontSize * 2)];
    
    return self;
}


-(void) onEnter {
    
    [super onEnter];
    
    for(model = 0; model < [modelSprites count]; ++model)
        if([[modelSprites objectAtIndex:model] unsignedIntValue] == [GorillasConfig get].playerModel)
            break;

    [self flipPage];
    
}


-(void) swiped:(BOOL)forward {
    
    model = (model + [modelSprites count] + (forward? 1: -1)) % [modelSprites count];
    
    [self flipPage];
}


-(void) flipPage {
    
    NSUInteger count = [modelSprites count];
    NSUInteger prevModel = (model + count - 1) % count;
    NSUInteger currModel = model;
    NSUInteger nextModel = (model + 1) % count;

    [swipeLayer setPosition:cpvzero];
    
    [prevModelSprite setModel:[[modelSprites objectAtIndex:prevModel] unsignedIntValue]];
    [currModelSprite setModel:[[modelSprites objectAtIndex:currModel] unsignedIntValue]];
    [nextModelSprite setModel:[[modelSprites objectAtIndex:nextModel] unsignedIntValue]];
    
    [currModelSprite cheer];
    [[GorillasConfig get] setPlayerModel:[currModelSprite model]];
    
    [modelCurr setString:[modelTitles objectAtIndex:currModel]];
    [modelNext setString:[modelTitles objectAtIndex:nextModel]];
}


-(void) next: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    model = (model + 1) % [modelSprites count];
    [self flipPage];
}


-(void) skip: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    model = (model + 2) % [modelSprites count];
    [self flipPage];
}


-(void) back: (id) sender {
    
    [[GorillasAudioController get] clickEffect];
    [[GorillasAppDelegate get] popLayer];
}


-(void) dealloc {
    
    [backMenu release];
    backMenu = nil;
    
    [nextMenu release];
    nextMenu = nil;
    
    [modelSprites release];
    modelSprites = nil;

    [super dealloc];
}


@end
