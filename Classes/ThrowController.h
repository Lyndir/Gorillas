//
//  ThrowController.h
//  Gorillas
//
//  Created by Maarten Billemont on 02/04/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//


@interface ThrowController : NSObject {

}

-(void) nextTurn;
-(void) throwEnded;

+(ThrowController *) get;

@end
