//
//  FightStance.h
//  Tube Man Boxing
//
//  Created by Alex Mordue on 26/07/12.
//  Copyright (c) 2012
//

#import <Foundation/Foundation.h>

@interface FightStance : NSObject
{
    NSNumber* frames;
    NSNumber* duration;
    NSNumber* damage;
    NSString* highAttack;
    NSString* lowAttack;
    NSNumber* hitTime;
}
@property (nonatomic, retain) NSNumber* frames;
@property (nonatomic, retain) NSNumber* duration;
@property (nonatomic, retain) NSNumber* hitTime;
@property (nonatomic, retain) NSNumber* damage;
@property (nonatomic, retain) NSString* highAttack;
@property (nonatomic, retain) NSString* lowAttack;
+(id) stanceWithNoOfFrames :(int)stanceFrames duration:(float)stanceDuration highAttack:(NSString*)stanceHigh lowAttack:(NSString*)stanceLow damage:(int)dmg hitTime:(float)hit;
@end
