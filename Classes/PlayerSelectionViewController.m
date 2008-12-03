//
//  PlayerSelectionViewController.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "PlayerSelectionViewController.h"


@implementation PlayerSelectionViewController


- (IBAction)back {

    [[self getGorillasViewController] showMainMenu];
}


- (IBAction)start {

    [[self getGorillasViewController] showGame];
}


@end
