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
            [[GorillasAppDelegate get].uiLayer message:NSLocalizedString(@"message.nextplayer", @"Next player ..")];

            if ([GorillasConfig get].voice)
                [[GorillasAudioController get] playEffectNamed:@"Next_Player"];
            
            [self performSelector:@selector(nextTurn) withObject:nil afterDelay:2];
            return;
        }
        
        [self nextTurn];
    }
}


-(void) nextTurn {
    
    [[GorillasAppDelegate get].hudLayer dismissMessage];
    
    [[GorillasAppDelegate get].gameLayer.buildingsLayer nextGorilla];

    if ([[GorillasAppDelegate get].gameLayer.activeGorilla human]) {
        [[GorillasAppDelegate get].uiLayer message:NSLocalizedString(@"message.nextplayer.go", @"Go ..")];
        
        if ([GorillasConfig get].voice)
            [[GorillasAudioController get] playEffectNamed:@"Go"];
    }
}


+(ThrowController *) get {
    
    static ThrowController *sharedThrowController = nil;
    if(sharedThrowController == nil)
        sharedThrowController = [[ThrowController alloc] init];

    return sharedThrowController;
}

@end
