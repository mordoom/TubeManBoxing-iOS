//
//  MessageWriter.h
//  Tube Man Boxing
//
//  Created by Cheebs on 28/12/12.
//
//

#import <Foundation/Foundation.h>

@interface MessageWriter : NSObject
{
    NSMutableData * data;
}

@property (retain, readonly) NSMutableData * data;

- (void)writeByte:(unsigned char)value;
- (void)writeInt:(int)value;
- (void)writeString:(NSString *)value;
@end
