//
//  CCAnimationHelper.h
//  Tube Man Boxing
//
//  Created by Alex Mordue on 20/01/12.
//  Copyright 2012
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCAnimation (Helper)
+(CCAnimation*) animationWithFile:(NSString*)name frameCount:(int)frameCount delay:(float)delay;
+(CCAnimation*) animationWithFrame:(NSString*)frame frameCount:(int)frameCount delay:(float)delay;
@end
