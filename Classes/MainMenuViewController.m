//
//  MainMenuViewController.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "MainMenuViewController.h"


@implementation MainMenuViewController


- (void) startGame {
    
    [[self getGorillasViewController] showPlayerSelection];
}


- (void) statistics {
    
    [[self getGorillasViewController] showStatistics];
}


- (void) about {
    
    [[self getGorillasViewController] showAbout];
}


@end
