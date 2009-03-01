//
//  GameConfiguration.h
//  Gorillas
//
//  Created by Maarten Billemont on 28/02/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GameConfiguration : NSObject {

    NSString *name;
    NSString *description;
    
    GorillasMode mode;
    NSUInteger sHumans, mHumans, sAis, mAis;
}

+(id) configurationWithName:(NSString *)_name description:(NSString *)_description
                       mode:(GorillasMode)_mode
                    sHumans:(NSUInteger)_sHumans mHumans:(NSUInteger)_mHumans
                       sAis:(NSUInteger)_sAis mAis:(NSUInteger)_mAis;

-(id) initWithName:(NSString *)_name description:(NSString *)_description
              mode:(GorillasMode)_mode
           sHumans:(NSUInteger)_sHumans mHumans:(NSUInteger)_mHumans
              sAis:(NSUInteger)_sAis mAis:(NSUInteger)_mAis;

@property (readonly) NSString   *name;
@property (readonly) NSString   *description;
@property (readonly) NSUInteger mode;
@property (readonly) NSUInteger sHumans;
@property (readonly) NSUInteger mHumans;
@property (readonly) NSUInteger sAis;
@property (readonly) NSUInteger mAis;

@end
