//
//  MessageWriter.m
//  Tube Man Boxing
//
//  Created by Cheebs on 28/12/12.
//
//

#import "MessageWriter.h"

@implementation MessageWriter
@synthesize data;
- (id)init {
    if ((self = [super init])) {
        data = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)writeBytes:(void *)bytes length:(int)length {
    [data appendBytes:bytes length:length];
}

- (void)writeByte:(unsigned char)value {
    [self writeBytes:&value length:sizeof(value)];
}

- (void)writeInt:(int)intValue {
    int value = htonl(intValue);
    [self writeBytes:&value length:sizeof(value)];
}

- (void)writeString:(NSString *)value {
    const char * utf8Value = [value UTF8String];
    int length = strlen(utf8Value) + 1; // for null terminator
    [self writeInt:length];
    [self writeBytes:(void *)utf8Value length:length];
}

- (void)dealloc {
    [data release];
    [super dealloc];
}
@end
