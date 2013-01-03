//
//  OpponentSprite.h
//  Tube Man Boxing
//
//  Created by Cheebang on 27/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface OpponentSprite : CCSprite
{
    CGPoint startPos;
    BOOL inflated;
    BOOL alive;
    int health;
    ccTime totalTime;
    ccTime nextShotTime;
    //FighterState state;
}

@property (readonly, nonatomic) BOOL inflated;
@property (readonly, nonatomic) int health;
+(id) opponent;
-(void) gotHit;
@end
