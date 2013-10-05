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
//  BuyPlusLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 26/10/08.
//  Copyright 2008-2009, lhunath (Maarten Billemont). All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "BuyPlusLayer.h"
#import "GorillasAppDelegate.h"
#import "MenuItemDescription.h"

@implementation BuyPlusLayer

- (id)init {

    SKProduct *product = (SKProduct *)([GorillasAppDelegate get].products)[GORILLAS_PLUS];
    NSNumberFormatter *priceFormatter = [NSNumberFormatter new];
    [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [priceFormatter setLocale:product.priceLocale];

    if (!(self = [super initWithDelegate:self logo:nil items:
            [PearlCCMenuItemBlock itemWithSize:60],
            [MenuItemDescription itemWithString:product.localizedDescription],
            [CCMenuItemFont itemWithString:[priceFormatter stringFromNumber:product.price] target:self selector:@selector(buy:)],
            nil]))
        return self;

    self.colorGradient = ccc4l( 0x00000000 );
    self.opacity = 0x00;
    self.outerPadding = PearlMarginMake( 0, 0, 0, 0 );
    self.innerRatio = 0;
    self.background = [CCSprite spriteWithFile:@"buy-plus.png"];

    [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification object:nil queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      if ([[GorillasConfig get].plusEnabled boolValue]) if ([[GorillasAppDelegate get]
                                                              isLayerShowing:self])
                                                          [[GorillasAppDelegate get] popLayer];
                                                  }];

    return self;
}

- (void)buy:(id)sender {

    [[SKPaymentQueue defaultQueue] addPayment:
            [SKPayment paymentWithProduct:([GorillasAppDelegate get].products)[GORILLAS_PLUS]]];
}

- (void)back:(id)sender {

    [[GorillasAppDelegate get] popLayer];
}

@end
