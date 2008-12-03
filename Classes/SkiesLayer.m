//
//  SkiesLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "SkiesLayer.h"
#import "SkyLayer.h"
#import "PanAction.h"


@implementation SkiesLayer


-(id) init {
    
    if (!(self = [super init]))
		return self;
    
    const float w = [[Director sharedDirector] winSize].size.width;
    
    NSMutableArray *skies = [[NSMutableArray alloc] init];
    for (int i = 0; i < 3; ++i) {
        const float x = i * w - w;
        
        const SkyLayer *sky =  [SkyLayer node];
        [skies addObject: sky];
        
        [sky setPosition: cpv(x, 0)];
        [self add: sky z:1];
    }
    
    [self do: [PanAction actionWithNode: self subNodes: skies nodeWidth: w duration: [[GorillasConfig get] starSpeed]]];
    [skies release];
    
    return self;
}


-(void) draw {
    
    glClearColor(0.0f, 0.0f, (float)0xb7 / 0xff, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
}


@end
