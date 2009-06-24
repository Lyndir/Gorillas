//
//  ThrowController.m
//  Gorillas
//
//  Created by Maarten Billemont on 02/04/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "ThrowController.h"
#import "GorillaLayer.h"
#import "GorillasAppDelegate.h"


@implementation ThrowController


-(void) throwEnded {

    @synchronized(self) {
        NSUInteger liveHumans = 0;
        for(GorillaLayer *gorilla in [GorillasAppDelegate get].gameLayer.gorillas)
            if(gorilla.human && gorilla.alive)
                ++liveHumans;
        
        if([GorillasAppDelegate get].gameLayer.activeGorilla.human && liveHumans > 1) {
            [[GorillasAudioController get] playEffectNamed:@"Next_Player"];
            [[GorillasAppDelegate get].uiLayer message:NSLocalizedString(@"message.nextplayer", @"Next player ..")];
            [[GorillasAppDelegate get].uiLayer message:NSLocalizedString(@"message.nextplayer.go", @"Go ..") callback:self :@selector(nextTurn)];
            return;
        }
        
        [self nextTurn];
    }
}


-(void) nextTurn {
    
    [[GorillasAppDelegate get].hudLayer dismissMessage];
    
    [[GorillasAppDelegate get].gameLayer.buildingsLayer nextGorilla];
}


+(ThrowController *) get {
    
    static ThrowController *sharedThrowController = nil;
    if(sharedThrowController == nil)
        sharedThrowController = [[ThrowController alloc] init];

    return sharedThrowController;
}

@end
