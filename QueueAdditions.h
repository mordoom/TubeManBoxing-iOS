//
//  NSMutableArray_NSMutableArrayExtension.h
//  Tube Man Boxing
//
//  Created by Alex Mordue on 26/07/12.
//  Copyright (c) 2012
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)
- (id) dequeue;
- (void) enqueue:(id)obj;
@end
