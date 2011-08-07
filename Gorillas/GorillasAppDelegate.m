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
#import "RootViewController.h"
#import "Splash.h"
#import "Resettable.h"
#import "DebugLayer.h"
#import "CityTheme.h"
#import "ccMacros.h"


static NSString *PHPlacementMoreGames  = @"more_games";

@interface CCDirector (Reveal)

-(void) startAnimation;

@end

@interface GorillasAppDelegate ()

@property (nonatomic, readwrite, retain) GameLayer                      *gameLayer;
@property (nonatomic, readwrite, retain) MainMenuLayer                   *mainMenuLayer;
@property (nonatomic, readwrite, retain) ConfigurationSectionLayer      *configLayer;
@property (nonatomic, readwrite, retain) GameConfigurationLayer         *gameConfigLayer;
@property (nonatomic, readwrite, retain) AVConfigurationLayer           *avConfigLayer;
@property (nonatomic, readwrite, retain) ModelsConfigurationLayer       *modelsConfigLayer;

@property (nonatomic, readwrite, retain) NetController                  *netController;
@property (nonatomic, readwrite, retain) PHNotificationView             *notifierView;

- (NSString *)phToken;
- (NSString *)phSecret;

@end

@implementation GorillasAppDelegate
@synthesize gameLayer = _gameLayer;
@synthesize mainMenuLayer = _mainMenuLayer;
@synthesize configLayer = _configLayer, gameConfigLayer = _gameConfigLayer, avConfigLayer = _avConfigLayer, modelsConfigLayer = _modelsConfigLayer;
@synthesize netController = _netController;
@synthesize notifierView = _notifierView;

+ (void)initialize {
    
    [[Logger get] setAutoprintLevel:LogLevelDebug];
    [GorillasConfig get];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    // Game Center setup.
    self.netController = [[NetController new] autorelease];
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error){
        if (error)
            wrn(@"Game Center unavailable: %@", error);
        
        [self.mainMenuLayer reset];
    }];
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
        [self.gameLayer performSelectorOnMainThread:@selector(stopGame) withObject:nil waitUntilDone:YES];
        
        if (acceptedInvite)
            [self.netController performSelectorOnMainThread:@selector(beginInvite:) withObject:acceptedInvite waitUntilDone:NO];
        
        else if(playersToInvite)
            [self performSelectorOnMainThread:@selector(showMainMenuForPlayers:) withObject:playersToInvite waitUntilDone:NO];
    };
    
	// Build the splash scene.
    CCScene *splashScene = [CCScene node];
    CCSprite *splash = [Splash node];
    [splashScene addChild:splash];
    
    // Build the game scene.
	self.gameLayer = [GameLayer node];
    CCSprite *frame = [CCSprite spriteWithFile:@"frame.png"];
    frame.anchorPoint = CGPointZero;
    [self.uiLayer addChild:frame z:1];
    [self.uiLayer addChild:self.gameLayer];
    
    // Show the splash screen, this starts the main loop in the current thread.
    [[CCDirector sharedDirector] pushScene:splashScene];
    [self showMainMenu];
    
    // PlayHaven setup.
    @try {
        [[PHPublisherOpenRequest requestForApp:[self phToken] secret:[self phSecret]] send];
    }
    @catch (NSException *exception) {
        err(@"PlayHaven exception: %@", exception);
    }
    
    do {
#if ! TARGET_IPHONE_SIMULATOR
        @try {
#endif
            [[CCDirector sharedDirector] startAnimation];
#if ! TARGET_IPHONE_SIMULATOR
        }
        @catch (NSException * e) {
            err(@"=== Exception Occurred! ===");
            err(@"Name: %@; Reason: %@; Context: %@.\n", [e name], [e reason], [e userInfo]);
            [self.hudLayer message:[e reason] duration:5 isImportant:YES];
        }
#endif
    } while ([[CCDirector sharedDirector] runningScene]);
    
    return NO;
}


-(GHUDLayer *) hudLayer {
    
    if(!_hudLayer)
        _hudLayer = [[GHUDLayer alloc] init];
    
    return (GHUDLayer *)super.hudLayer;
}


- (void)hudMenuPressed {
    
    [self showMainMenu];
}

-(void) showMainMenu {
    
    if(!self.mainMenuLayer)
        self.mainMenuLayer = [MainMenuLayer node];
    
    [self pushLayer:self.mainMenuLayer];
}


-(void) showMainMenuForPlayers:(NSArray *)aPlayersToInvite {
    
    if(!self.mainMenuLayer)
        self.mainMenuLayer = [MainMenuLayer node];
    self.mainMenuLayer.playersToInvite = aPlayersToInvite;
    
    [self pushLayer:self.mainMenuLayer];
}


-(void) showConfiguration {
    
    if(!self.configLayer)
        self.configLayer = [ConfigurationSectionLayer node];
    
    [self pushLayer:self.configLayer];
}


-(void) showGameConfiguration {
    
    if(!self.gameConfigLayer)
        self.gameConfigLayer = [GameConfigurationLayer node];
    
    [self pushLayer:self.gameConfigLayer];
}


-(void) showAVConfiguration {
    
    if(!self.avConfigLayer)
        self.avConfigLayer = [AVConfigurationLayer node];
    
    [self pushLayer:self.avConfigLayer];
}


-(void) showModelsConfiguration {
    
    if(!self.modelsConfigLayer)
        self.modelsConfigLayer = [ModelsConfigurationLayer node];
    
    [self pushLayer:self.modelsConfigLayer];
}


- (void)moreGames {
    
    [[PHPublisherContentRequest requestForApp:[self phToken] secret:[self phSecret]
                                    placement:PHPlacementMoreGames delegate:self] send];
}


- (void)pushLayer: (ShadeLayer *)layer hidden:(BOOL)hidden {
    
    [self.gameLayer setPaused:YES];
    
    [super pushLayer:layer hidden:hidden];
}

- (void)didUpdateConfigForKey:(SEL)configKey fromValue:(id)value {
    
    [super didUpdateConfigForKey:configKey fromValue:value];
    
    if (configKey == @selector(cityTheme)) {
        dbg(@"City Theme changed to: %@", [GorillasConfig get].cityTheme);
        [[[CityTheme getThemes] objectForKey:[GorillasConfig get].cityTheme] apply];
    }
    
    if (configKey == @selector(playerModel)) {
        dbg(@"Model changed");
        [self.gameLayer reset];
    }
}

- (void)didPushLayer:(ShadeLayer *)layer hidden:(BOOL)hidden {
    
    self.gameLayer.paused = YES;
    
    if (!self.notifierView)
        self.notifierView = [[[PHNotificationView alloc] initWithApp:[self phToken] secret:[self phSecret]
                                                           placement:PHPlacementMoreGames] autorelease];
    
    if (self.notifierView.superview && layer != self.mainMenuLayer)
        [self.notifierView removeFromSuperview];
    
    else if (self.notifierView) {
        if (layer == self.mainMenuLayer) {
            self.notifierView.center = ccp(380, 260);
            [[CCDirector sharedDirector].openGLView addSubview:self.notifierView];
#if DEBUG
            [self.notifierView test];
#else
            [self.notifierView refresh];
#endif
        }
    }
    
    [super didPushLayer:layer hidden:hidden];
}

- (void)didPopLayer:(ShadeLayer *)layer anyLeft:(BOOL)anyLeft {
    
    if (self.notifierView.superview && layer == self.mainMenuLayer)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.notifierView removeFromSuperview];
        });
    
    else if (self.notifierView) {
        if ([self isLayerShowing:self.mainMenuLayer]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.notifierView.center = ccp(100, 330);
                [[CCDirector sharedDirector].openGLView addSubview:self.notifierView];
            });
        }
    }
    
    if (!anyLeft)
        self.gameLayer.paused = NO;
    
    [super didPopLayer:layer anyLeft:anyLeft];
}


#pragma mark - PlayHavenSDK

static NSDictionary *playHavenInfo = nil;

- (NSString *)phToken {
    
    if (playHavenInfo == nil)
        playHavenInfo = [[NSDictionary alloc]initWithContentsOfURL:
                         [[NSBundle mainBundle] URLForResource:@"PlayHaven" withExtension:@"plist"]];
    
    return [playHavenInfo valueForKeyPath:@"Token"];
}

- (NSString *)phSecret {
    
    return [playHavenInfo valueForKeyPath:@"Secret"];
}

-(void)request:(PHPublisherContentRequest *)request contentWillDisplay:(PHContent *)content {
    
    [self.notifierView clear];
    
    [[CCDirector sharedDirector] pause];
}

-(void)requestContentDidDismiss:(PHPublisherContentRequest *)request {
    
    [[CCDirector sharedDirector] resume];
}

-(void)request:(PHPublisherContentRequest *)request didFailWithError:(NSError *)error {
    
    err(@"PlayHavenSDK request: %@, couldn't load content: %@", request, error);
}

-(void)request:(PHPublisherContentRequest *)request contentDidFailWithError:(NSError *)error {
    
    err(@"PlayHavenSDK request: %@, couldn't load view: %@", request, error);
    [[CCDirector sharedDirector] resume];
}


-(void) applicationWillResignActive:(UIApplication *)application {
    
    if(!self.gameLayer.paused)
        [self showMainMenu];
    
    [super applicationWillResignActive:application];
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    [super applicationDidReceiveMemoryWarning:application];
    
    if(self.mainMenuLayer && ![self.mainMenuLayer parent]) {
        [self.mainMenuLayer stopAllActions];
        self.mainMenuLayer = nil;
    }
    if(self.configLayer && ![self.configLayer parent]) {
        [self.configLayer stopAllActions];
        self.configLayer = nil;
    }
    if(self.gameConfigLayer && ![self.gameConfigLayer parent]) {
        [self.gameConfigLayer stopAllActions];
        self.gameConfigLayer = nil;
    }
    if(self.avConfigLayer && ![self.avConfigLayer parent]) {
        [self.avConfigLayer stopAllActions];
        self.avConfigLayer = nil;
    }
    if(self.modelsConfigLayer && ![self.modelsConfigLayer parent]) {
        [self.modelsConfigLayer stopAllActions];
        self.modelsConfigLayer = nil;
    }
}


- (void)dealloc {
    
    self.gameLayer          = nil;
    self.mainMenuLayer      = nil;
    self.configLayer        = nil;
    self.gameConfigLayer    = nil;
    self.avConfigLayer      = nil;
    self.modelsConfigLayer  = nil;
    
    [super dealloc];
}


+(GorillasAppDelegate *) get {
    
    return (GorillasAppDelegate *) [UIApplication sharedApplication].delegate;
}


@end
