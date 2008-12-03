//
//  GorillasViewController.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GorillasViewController.h"
#import "MainMenuViewController.h"
#import "StatisticsViewController.h"
#import "ConfirmResetViewController.h"
#import "PlayerSelectionViewController.h"
#import "AboutViewController.h"
#import "GorillasGameController.h"

#define gUIAnimationKey             @"GorillasUIAnimation"
#define gUIAnimationDuration        .3


@implementation GorillasViewController


- (void)showMainMenu {
    
    [self show:[[MainMenuViewController alloc] initWithNibName:@"MainMenuView" bundle:nil]];
}


- (void)showStatistics {
    
    [self show:[[StatisticsViewController alloc] initWithNibName:@"StatisticsView" bundle:nil]];
}


- (void)showConfirmReset {
    
    [self show:[[ConfirmResetViewController alloc] initWithNibName:@"ConfirmResetView" bundle:nil]];
}


- (void)showPlayerSelection {
    
    [self show:[[PlayerSelectionViewController alloc] initWithNibName:@"PlayerSelectionView" bundle:nil]];
}


- (void)showAbout {
    
    [self show:[[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil]];
}


- (void)showGame {
    
    [self show:[GorillasGameController alloc]];
}


- (void)show:(UIViewController *)newViewController {
    
    if(currentViewController != nil) {
        [currentViewController.view removeFromSuperview];
        [currentViewController release];
    }
    
    currentViewController = newViewController;
    [self.view addSubview:currentViewController.view];
    
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionReveal];
    [animation setDuration:gUIAnimationDuration];
    [[self.view layer] addAnimation:animation forKey:gUIAnimationKey];
}


- (void)viewDidLoad {

    [self showGame];
}


@end
