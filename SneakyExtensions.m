//
//  SneakyExtensions.m
//  ScrollingWithJoy
//
//  Created by Steffen Itterheim on 12.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//  Additional code by Alex Mordue, written 27.11.12
//

#import "SneakyExtensions.h"


@implementation SneakyButton (Extension)
+(id) button
{
    SneakyButton* button = [[[SneakyButton alloc] initWithRect:CGRectZero] autorelease];
    button.isHoldable = NO;
	return button;
}

+(id) buttonAtPos:(CGPoint)pos radius:(float)radius
{
    SneakyButton* button = [[[SneakyButton alloc] initWithRect:CGRectZero] autorelease];
    button.position = pos;
    button.radius = radius;
    button.isHoldable = NO;
	return button;
}
@end


@implementation SneakyButtonSkinnedBase (Extension)
+(id) skinnedButton
{
	SneakyButtonSkinnedBase* button = [[[SneakyButtonSkinnedBase alloc] init] autorelease];
    
    //TMB specific buttons
    button.defaultSprite = [CCSprite spriteWithSpriteFrameName:@"default-button.png"];
    button.pressSprite = [CCSprite spriteWithSpriteFrameName:@"default-button.png"];
    button.scale = 2.0f;
    button.defaultSprite.opacity = 30;
    button.pressSprite.color = ccRED;
    
    return button;
}

+(id) skinnedButtonWithVisibility:(bool)vis
{
	SneakyButtonSkinnedBase* button = [SneakyButtonSkinnedBase skinnedButton];
    button.visible = vis;
    
    return button;
}
@end
