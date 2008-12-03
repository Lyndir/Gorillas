//
//  ConfirmResetViewController.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "ConfirmResetViewController.h"


@implementation ConfirmResetViewController


- (IBAction) back {
    
    [[self getGorillasViewController] showStatistics];
}


- (IBAction) reset {
    
    [[self getGorillasViewController] showStatistics];
}


@end
