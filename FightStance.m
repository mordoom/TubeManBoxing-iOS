//
//  FightStance.m
//  Tube Man Boxing
//
//  Created by Alex Mordue on 26/07/12.
//  Copyright (c) 2012
//

#import "FightStance.h"

@implementation FightStance
@synthesize frames, duration, highAttack, lowAttack, damage, hitTime;

-(id) initStance:(int)stanceFrames :(float)stanceDuration :(NSString*)stanceHigh :(NSString*)stanceLow :(int)dmg :(float)hit
{
    if (self = [super init])
    {
        self.frames = [NSNumber numberWithInt:stanceFrames];
        self.duration = [NSNumber numberWithFloat:stanceDuration];
        self.damage = [NSNumber numberWithInt:dmg];
        self.highAttack = stanceHigh;
        self.lowAttack = stanceLow;
        self.hitTime = [NSNumber numberWithDouble:hit];
    }
    
    return self;
}

+(id) stanceWithNoOfFrames:(int)stanceFrames duration:(float)stanceDuration
      highAttack:(NSString *)stanceHigh lowAttack:(NSString *)stanceLow damage:(int)dmg hitTime:(float)hit
{
    return [[[self alloc] initStance:stanceFrames : stanceDuration :stanceHigh :stanceLow :dmg :hit] autorelease];
}

-(void) dealloc
{
    [frames release];
    [duration release];
    [damage release];
    [highAttack release];
    [lowAttack release];
    [hitTime release];
    [super dealloc];
}

@end
