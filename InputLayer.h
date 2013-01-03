//
//  InputLayer.h
//  TMB
//
//  Created by Alex Mordue on 12/01/12.
//  Copyright 2012
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//Sneaky Input headers
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"
#import "SneakyExtensions.h"

@interface InputLayer : CCLayer
{
    SneakyButton* deflateButton;
    SneakyButton* highAttackButton;
    SneakyButton* lowAttackButton;
    SneakyButton* specialAttackButton;
    SneakyButton* pauseButton;
    BOOL multiplayer;
    ccTime totalTime;
    ccTime nextShotTime;
}
-(void)turnOnMultiplayer;
@end
