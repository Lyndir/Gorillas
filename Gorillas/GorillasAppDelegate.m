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
//  GorillasAppDelegate.m
//  Gorillas
//
//  Created by Maarten Billemont on 18/10/08.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//

#import "GorillasAppDelegate.h"
#import "CityTheme.h"
#import "ccMacros.h"
#import "LocalyticsSession.h"
#import "TestFlight.h"
#import <Crashlytics/Crashlytics.h>
#import <StoreKit/StoreKit.h>

@interface GorillasAppDelegate()<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property(nonatomic, readwrite, strong) GameLayer *gameLayer;
@property(nonatomic, readwrite, strong) MainMenuLayer *mainMenuLayer;
@property(nonatomic, readwrite, strong) BuyPlusLayer *buyPlusLayer;
@property(nonatomic, readwrite, strong) ConfigurationSectionLayer *configLayer;
@property(nonatomic, readwrite, strong) GameConfigurationLayer *gameConfigLayer;
@property(nonatomic, readwrite, strong) AVConfigurationLayer *avConfigLayer;
@property(nonatomic, readwrite, strong) NetController *netController;
@property(nonatomic, readwrite, strong) NSDictionary *products;

@property(nonatomic, strong) PearlAlert *purchasingActivity;
- (NSDictionary *)testFlightInfo;
- (NSString *)testFlightToken;

- (NSDictionary *)crashlyticsInfo;
- (NSString *)crashlyticsAPIKey;

- (NSDictionary *)localyticsInfo;
- (NSString *)localyticsKey;

@end

@implementation GorillasAppDelegate

+ (void)initialize {

    [GorillasConfig get];
#ifdef DEBUG
    [[PearlLogger get] setPrintLevel:PearlLogLevelDebug];
#endif
}

- (void)preSetup {

    @try {
        NSString *apiKey = [self crashlyticsAPIKey];
        if ([apiKey length]) {
            dbg(@"Initializing Crashlytics");
#ifndef APPSTORE
            [Crashlytics sharedInstance].debugMode = YES;
#endif
            [Crashlytics startWithAPIKey:apiKey afterDelay:0];
            [[Crashlytics sharedInstance] setUserName:@"Anonymous"];
            [[PearlLogger get] registerListener:^BOOL(PearlLogMessage *message) {
#ifdef APPSTORE
                if (message.level >= PearlLogLevelInfo)
                    CLSLog(@"%@", message);
#else
                if (message.level >= PearlLogLevelDebug)
                    CLSLog( @"%@", message );
#endif

                return YES;
            }];
        }
    }
    @catch (id exception) {
        err(@"Crashlytics: %@", exception);
    }
    @try {
        NSString *token = [self testFlightToken];
        if ([token length]) {
            inf(@"Initializing TestFlight");
            [TestFlight addCustomEnvironmentInformation:@"Anonymous" forKey:@"username"];
            [TestFlight setOptions:@{
                    @"logToConsole" : @NO,
                    @"logToSTDERR"  : @NO
            }];
            [TestFlight takeOff:token];
            [[PearlLogger get] registerListener:^BOOL(PearlLogMessage *message) {
#ifdef APPSTORE
                if (message.level >= PearlLogLevelInfo)
                    TFLog(@"%@", message);
#else
                if (message.level >= PearlLogLevelDebug)
                    TFLog( @"%@", message );
#endif

                return YES;
            }];
        }
    }
    @catch (id exception) {
        err(@"TestFlight: %@", exception);
    }
    @try {
        NSString *key = [self localyticsKey];
        if ([key length]) {
            dbg(@"Initializing Localytics");
            [[LocalyticsSession sharedLocalyticsSession] startSession:key];
            [[PearlLogger get] registerListener:^BOOL(PearlLogMessage *message) {
                if (message.level >= PearlLogLevelError)
                    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Problem" attributes:
                            @{
                                    @"level"   : [[NSString alloc] initWithUTF8String:PearlLogLevelStr( message.level )],
                                    @"message" : message.message
                            }];

                return YES;
            }];
        }
    }
    @catch (id exception) {
        err(@"Localytics exception: %@", exception);
    }

    [super preSetup];

    // Build the splash scene.
    CCScene *splashScene = [CCScene node];
    CCSprite *splash = [PearlCCSplash node];
    [splashScene addChild:splash];

    // Build the game scene.
    self.gameLayer = [GameLayer node];
    CCSprite *frame = [CCSprite spriteWithFile:@"frame.png"];
    frame.anchorPoint = CGPointZero;
    [self.uiLayer addChild:frame z:1];
    [self.uiLayer addChild:self.gameLayer];

    // Show the splash screen, this starts the main loop in the current thread.
    [[CCDirector sharedDirector] pushScene:splashScene];

    // Game Center setup.
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
        if (error)
        wrn(@"Game Center unavailable: %@", error);

        dbg(@"Local player alias: %@", [GKLocalPlayer localPlayer].alias);
        [TestFlight addCustomEnvironmentInformation:[GKLocalPlayer localPlayer].alias forKey:@"username"];
        [[Crashlytics sharedInstance] setUserName:[GKLocalPlayer localPlayer].alias];
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.mainMenuLayer reset];
        } );
    }];

    // StoreKit setup.
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:@[ GORILLAS_PLUS ]]];
    productsRequest.delegate = self;
    [productsRequest start];

    self.netController = [NetController new];
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {

        if (acceptedInvite)
            dispatch_async( dispatch_get_main_queue(), ^{
                [self.netController beginInvite:acceptedInvite];
            } );

        else if (playersToInvite)
            dispatch_async( dispatch_get_main_queue(), ^{
                [self showMainMenuForPlayers:playersToInvite];
            } );
    };
}

- (GHUDLayer *)hudLayer {

    if (!_hudLayer)
        _hudLayer = [[GHUDLayer alloc] init];

    return (GHUDLayer *)super.hudLayer;
}

- (void)hudMenuPressed {

    [self showMainMenu];
}

- (void)showMainMenu {

    if (!self.mainMenuLayer)
        self.mainMenuLayer = [MainMenuLayer node];

    if (![self isLastLayerShowing] || ![self isLayerShowing:self.mainMenuLayer]) {
        [self popAllLayers];
        [self pushLayer:self.mainMenuLayer];
    }
}

- (void)showMainMenuForPlayers:(NSArray *)aPlayersToInvite {

    if (!self.mainMenuLayer)
        self.mainMenuLayer = [MainMenuLayer node];
    self.mainMenuLayer.playersToInvite = aPlayersToInvite;

    [self pushLayer:self.mainMenuLayer];
}

- (void)showUpgrade {

    if (!self.buyPlusLayer)
        self.buyPlusLayer = [BuyPlusLayer node];

    [self pushLayer:self.buyPlusLayer];
}

- (void)showConfiguration {

    if (!self.configLayer)
        self.configLayer = [ConfigurationSectionLayer node];

    [self pushLayer:self.configLayer];
}

- (void)showGameConfiguration {

    if (!self.gameConfigLayer)
        self.gameConfigLayer = [GameConfigurationLayer node];

    [self pushLayer:self.gameConfigLayer];
}

- (void)showAVConfiguration {

    if (!self.avConfigLayer)
        self.avConfigLayer = [AVConfigurationLayer node];

    [self pushLayer:self.avConfigLayer];
}

- (void)pushLayer:(PearlCCShadeLayer *)layer hidden:(BOOL)hidden {

    [self.gameLayer setPaused:YES];

    [super pushLayer:layer hidden:hidden];
}

- (void)didUpdateConfigForKey:(SEL)configKey fromValue:(id)value {

    [super didUpdateConfigForKey:configKey fromValue:value];

    if (configKey == @selector(cityTheme)) {
        dbg(@"City Theme changed to: %@", [GorillasConfig get].cityTheme);
        [[CityTheme getThemes][[GorillasConfig get].cityTheme] apply];
    }
}

- (void)didPushLayer:(PearlCCShadeLayer *)layer hidden:(BOOL)hidden {

    self.gameLayer.paused = YES;

    [super didPushLayer:layer hidden:hidden];
}

- (void)didPopLayer:(PearlCCShadeLayer *)layer anyLeft:(BOOL)anyLeft {

    if (!anyLeft)
        self.gameLayer.paused = NO;

    [super didPopLayer:layer anyLeft:anyLeft];
}


#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    BOOL plusAvailable = NO;
    NSMutableDictionary *products = [NSMutableDictionary dictionaryWithCapacity:[response.products count]];
    for (SKProduct *product in response.products) {
        products[product.productIdentifier] = product;
        if ([product.productIdentifier isEqualToString:GORILLAS_PLUS])
            plusAvailable = YES;
    }

    self.products = products;
    self.plusAvailable = plusAvailable;
}


#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {

    for (SKPaymentTransaction *transaction in transactions)
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                self.purchasingActivity = [PearlAlert showActivityWithTitle:PearlString( @"Purchasing %@",
                        ((SKProduct *)(self.products)[transaction.payment.productIdentifier]).localizedTitle )];
                break;
            case SKPaymentTransactionStateFailed:
                err(@"In-App Purchase failed: %@", transaction.error);
                [self.purchasingActivity cancelAlertAnimated:YES];
                if ([transaction.payment.productIdentifier isEqualToString:GORILLAS_PLUS])
                    [GorillasConfig get].plusEnabled = @NO;
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchased:
                [self.purchasingActivity cancelAlertAnimated:YES];
                if ([transaction.payment.productIdentifier isEqualToString:GORILLAS_PLUS])
                    [GorillasConfig get].plusEnabled = @YES;
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self.purchasingActivity cancelAlertAnimated:YES];
                if ([transaction.originalTransaction.payment.productIdentifier isEqualToString:GORILLAS_PLUS])
                    [GorillasConfig get].plusEnabled = @YES;
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    [GorillasConfig flush];
}


#pragma mark - TestFlight

- (NSDictionary *)testFlightInfo {

    static NSDictionary *testFlightInfo = nil;
    if (testFlightInfo == nil)
        testFlightInfo = [[NSDictionary alloc] initWithContentsOfURL:
                [[NSBundle mainBundle] URLForResource:@"TestFlight" withExtension:@"plist"]];

    return testFlightInfo;
}

- (NSString *)testFlightToken {

    return NSNullToNil([[self testFlightInfo] valueForKeyPath:@"Team Token"]);
}


#pragma mark - Crashlytics

- (NSDictionary *)crashlyticsInfo {

    static NSDictionary *crashlyticsInfo = nil;
    if (crashlyticsInfo == nil)
        crashlyticsInfo = [[NSDictionary alloc] initWithContentsOfURL:
                [[NSBundle mainBundle] URLForResource:@"Crashlytics" withExtension:@"plist"]];

    return crashlyticsInfo;
}

- (NSString *)crashlyticsAPIKey {

    return NSNullToNil([self crashlyticsInfo][@"API Key"]);
}



#pragma mark - Localytics

- (NSDictionary *)localyticsInfo {

    static NSDictionary *localyticsInfo = nil;
    if (localyticsInfo == nil)
        localyticsInfo = [[NSDictionary alloc] initWithContentsOfURL:
                [[NSBundle mainBundle] URLForResource:@"Localytics" withExtension:@"plist"]];

    return localyticsInfo;
}

- (NSString *)localyticsKey {

#ifdef DEBUG
    return NSNullToNil([[self localyticsInfo] valueForKeyPath:@"Key.development"]);
#else
    return NSNullToNil([[self localyticsInfo] valueForKeyPath:@"Key.distribution"]);
#endif
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];

    [super applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];

    [super applicationWillEnterForeground:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {

    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];

    [super applicationWillTerminate:application];
}

- (void)applicationWillResignActive:(UIApplication *)application {

    if (!self.gameLayer.paused)
        [self showMainMenu];

    [super applicationWillResignActive:application];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {

    [super applicationDidReceiveMemoryWarning:application];

    if (self.mainMenuLayer && ![self.mainMenuLayer parent]) {
        [self.mainMenuLayer stopAllActions];
        self.mainMenuLayer = nil;
    }
    if (self.buyPlusLayer && ![self.buyPlusLayer parent]) {
        [self.buyPlusLayer stopAllActions];
        self.buyPlusLayer = nil;
    }
    if (self.configLayer && ![self.configLayer parent]) {
        [self.configLayer stopAllActions];
        self.configLayer = nil;
    }
    if (self.gameConfigLayer && ![self.gameConfigLayer parent]) {
        [self.gameConfigLayer stopAllActions];
        self.gameConfigLayer = nil;
    }
    if (self.avConfigLayer && ![self.avConfigLayer parent]) {
        [self.avConfigLayer stopAllActions];
        self.avConfigLayer = nil;
    }
}

+ (GorillasAppDelegate *)get {

    return (GorillasAppDelegate *)[UIApplication sharedApplication].delegate;
}

@end
