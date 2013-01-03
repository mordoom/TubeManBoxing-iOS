//
//  MainMenuLayer.m
//  Tube Man Boxing
//
//  Created by Cheebang on 23/07/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenuLayer.h"
#import "CharacterSelectLayer.h"
#import "ControlsLayer.h"
#import "SimpleAudioEngine.h"
//static ccColor3B menuColor = ccORANGE;

@implementation MainMenuLayer
-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self createMenu];
    [self setIsTouchEnabled:NO];
}

-(void) startGame
{
	// get the menu back
	CCNode* node = [self getChildByTag:100];
	NSAssert([node isKindOfClass:[CCMenu class]], @"node is not a CCMenu!");
    
	CCMenu* menu = (CCMenu*)node;
    
	// lets move the menu out using a sequence
	CGSize size = [[CCDirector sharedDirector] winSize];
	CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:CGPointMake(-(size.width / 2), size.height / 3)];
	CCEaseBackInOut* ease = [CCEaseBackInOut actionWithAction:move];
	CCCallFunc* func = [CCCallFunc actionWithTarget:self selector:@selector(characterSelect:)];
	CCSequence* sequence = [CCSequence actions:ease, func, nil];
	[menu runAction:sequence];
}

-(void) controls:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[ControlsLayer scene]];
}

-(void) showControls
{
	// get the menu back
	CCNode* node = [self getChildByTag:100];
	NSAssert([node isKindOfClass:[CCMenu class]], @"node is not a CCMenu!");
    
	CCMenu* menu = (CCMenu*)node;
    
	// lets move the menu out using a sequence
	CGSize size = [[CCDirector sharedDirector] winSize];
	CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:CGPointMake(-(size.width / 2), size.height / 3)];
	CCEaseBackInOut* ease = [CCEaseBackInOut actionWithAction:move];
	CCCallFunc* func = [CCCallFunc actionWithTarget:self selector:@selector(controls:)];
	CCSequence* sequence = [CCSequence actions:ease, func, nil];
	[menu runAction:sequence];
}

-(void) characterSelect:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[CharacterSelectLayer sceneWithGameType:game rematch:NO]];
}

-(void) menuItem1Touched:(id)sender
{
	CCLOG(@"item 1 touched: %@", sender);
    game = Arcade;
	[self startGame];
}

-(void) menuItem2Touched:(id)sender
{
	CCLOG(@"item 2 touched: %@", sender);
	[self showControls];
}
-(void) menuItem3Touched:(id)sender
{
	CCLOG(@"item 3 touched: %@", sender);
    game = Practice;
	[self startGame];
}
-(void) menuItem4Touched:(id)sender
{
	CCLOG(@"item 4 touched: %@", sender);
    game = Multiplayer;
	[self startGame];
}

-(void) createMenu
{
    // unschedule the selector, we only want this method to be called once
	[self unschedule:_cmd];
	
    //Update the logo image
    CCSprite* logo = (CCSprite*)[self getChildByTag:MainMenuLayerLogoTag];
    CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:@"tubeman-menu.png"];
    [logo setTexture:tex];
    
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	// set CCMenuItemFont default properties
	[CCMenuItemFont setFontName:@"Helvetica"];
	[CCMenuItemFont setFontSize:30];
    
	// create a few labels with text and selector
	CCMenuItemFont* item1 = [CCMenuItemFont itemFromString:@"Start Game" target:self selector:@selector(menuItem1Touched:)];
    CCMenuItemFont* item2 = [CCMenuItemFont itemFromString:@"Controls" target:self selector:@selector(menuItem2Touched:)];
    CCMenuItemFont* item3 = [CCMenuItemFont itemFromString:@"Practice" target:self selector:@selector(menuItem3Touched:)];
	CCMenuItemFont* item4 = [CCMenuItemFont itemFromString:@"Multiplayer" target:self selector:@selector(menuItem4Touched:)];
    
    [item1.label setColor:ccWHITE];
    [item2.label setColor:[item1 color]];
    [item3.label setColor:[item1 color]];
    [item4.label setColor:[item1 color]];
    
	// create the menu using the items
	CCMenu* menu = [CCMenu menuWithItems:item1, item2, item4, item3, nil];
	menu.position = CGPointMake(-(size.width / 2), size.height / 3.5);
	menu.tag = 100;
	[self addChild:menu z:2];
	
	// calling one of the align methods is important, otherwise all labels will occupy the same location
	[menu alignItemsVerticallyWithPadding:10];
	
	// use an action for a neat initial effect - moving the whole menu at once!
	CCMoveTo* move = [CCMoveTo actionWithDuration:3 position:CGPointMake(size.width / 2, size.height / 3.5)];
	CCEaseElasticOut* ease = [CCEaseElasticOut actionWithAction:move period:0.8f];
	[menu runAction:ease];
}

-(id) init
{
    if (self = [super init])
    {
        //Background
        CCSprite * bg = [CCSprite spriteWithFile:@"boxing-ring.png"];
        bg.anchorPoint = CGPointMake(0, 0);
        bg.opacity = 95;
        [self addChild:bg z:0];
        
        CCSprite * logo = [CCSprite spriteWithFile:@"tubeman-logo.png"];
        logo.anchorPoint = CGPointMake(0, 0);
        [self addChild:logo z:1 tag:MainMenuLayerLogoTag];
        
        //Tap to show menu
        [self setIsTouchEnabled:YES];
        
        //Music
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"main.mp3" loop:YES];
    }
    return self;
}

+(id) scene
{
    CCScene* scene = [CCScene node];
	MainMenuLayer* layer = [MainMenuLayer node];
	[scene addChild:layer];
	return scene;
}

@end
