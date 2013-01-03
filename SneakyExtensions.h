//
//  SneakyExtensions.h
//  ScrollingWithJoy
//
//  Created by Steffen Itterheim on 12.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

// SneakyInput headers
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"


@interface SneakyButton (Extension)
+(id) button;
+(id) buttonAtPos:(CGPoint)pos radius:(float)radius;
@end

@interface SneakyButtonSkinnedBase (Extension)
+(id) skinnedButton;
+(id) skinnedButtonWithVisibility:(bool)vis;
@end