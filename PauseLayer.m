//
//  PauseLayer.m
//  Tube Man Boxing
//
//  Created by Alex Mordue on 23/12/12.
//  Copyright 2012
//

#import "PauseLayer.h"
#import "SimpleAudioEngine.h"

@implementation PauseLayer

-(id) init
{
    if (self = [super init])
    {
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // use an action to move sprites/menu - need one for each for some reason...
        CCMoveTo* move = [CCMoveTo actionWithDuration:3 position:CGPointMake(size.width / 2, size.height/2)];
        CCMoveTo* move1 = [CCMoveTo actionWithDuration:3 position:CGPointMake(size.width / 2, size.height/2)];
        CCEaseElasticOut* ease = [CCEaseElasticOut actionWithAction:move period:0.5f];
        CCEaseElasticOut* ease1 = [CCEaseElasticOut actionWithAction:move1 period:0.5f];
        
        //Menu background
        CCSprite* bg = [CCSprite spriteWithSpriteFrameName:@"textbox.png"];
        bg.position = CGPointMake(-size.width, size.height/2);
        [bg runAction:ease1];
        [self addChild:bg z:1];
        
        // set CCMenuItemFont default properties
        [CCMenuItemFont setFontName:@"Helvetica"];
        [CCMenuItemFont setFontSize:32];
        
        // create a few labels with text and selector
        CCMenuItemFont* item1 = [CCMenuItemFont itemFromString:@"Paused"];
        [item1.label setColor:ccBLACK];
        
        // create the menu using the items
        CCMenu* menu = [CCMenu menuWithItems:item1, nil];
        menu.position = CGPointMake(-(size.width / 2), size.height/2);
        [self addChild:menu z:2];
        
        // calling one of the align methods is important, otherwise all labels will occupy the same location
        [menu alignItemsVerticallyWithPadding:10];
        [menu runAction:ease];

    }
    return self;
}

-(void) soundButtonPressed:(id)sender
{
    //If sound on
    SimpleAudioEngine* audio = [SimpleAudioEngine sharedEngine];
    if (audio.mute == NO)
        audio.mute = YES;
    else
        audio.mute = NO;
    
    //Update the image/text!
}

-(void) dealloc
{
    [super dealloc];
}

@end
