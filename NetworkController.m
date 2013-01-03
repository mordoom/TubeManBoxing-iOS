//
//  NetworkController.m
//  Tube Man Boxing
//
//  Created by Cheebs on 26/11/12.
//
//

#import "NetworkController.h"

@interface NetworkController (PrivateMethods)
- (BOOL)writeChunk;
@end

@implementation NetworkController
@synthesize gameCenterAvailable, userAuthenticated, delegate, state, inputStream,
outputStream, inputOpened, outputOpened, okToWrite, outputBuffer;
static NetworkController* instanceOfNC = nil;

+(NetworkController*) sharedNetworkController
{
    if (!instanceOfNC)
    {
        instanceOfNC = [[NetworkController alloc] init];
    }
    return instanceOfNC;
}

-(BOOL) isGameCenterAvailable
{
    //Check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // Test if device is running iOS 4.1 or higher
    NSString* reqSysVer = @"4.1";
    NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
    bool isOSVer41 = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && isOSVer41);
}

-(void)setState:(NetworkState)newState
{
    self.state = newState;
    
    if (delegate)
    {
        [delegate stateChanged:self.state];
    }
}

-(id) init
{
    if (self = [super init])
    {
        [self setState:state];
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable)
        {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                       selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                       object:nil];
        }
    }
    
    return self;
}

#pragma mark - Message sending / receiving

- (void)sendData:(NSData *)data {
    
    if (outputBuffer == nil) return;
    
    int dataLength = data.length;
    dataLength = htonl(dataLength);
    [outputBuffer appendBytes:&dataLength length:sizeof(dataLength)];
    [outputBuffer appendData:data];
    if (okToWrite) {
        [self writeChunk];
        NSLog(@"Wrote message");
    } else {
        NSLog(@"Queued message");
    }
}

- (void)sendPlayerConnected:(BOOL)continueMatch {
    [self setState:NetworkStatePendingMatchStatus];
    
    MessageWriter * writer = [[[MessageWriter alloc] init] autorelease];
    [writer writeByte:MessagePlayerConnected];
    [writer writeString:[GKLocalPlayer localPlayer].playerID];
    [writer writeString:[GKLocalPlayer localPlayer].alias];
    [writer writeByte:continueMatch];
    [self sendData:writer.data];
}

#pragma mark - Server communication

- (void)connect
{
    self.outputBuffer = [NSMutableData data];
    [self setState:NetworkStateConnectingToServer];
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    //Replace with own server url ie. meetjimroast?
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"www.tmb.meetjimroast.com", 1955, &readStream, &writeStream);
    inputStream = (NSInputStream *)readStream;
    outputStream = (NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    [outputStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

- (void)disconnect {
    
    [self setState:NetworkStateConnectingToServer];
    
    if (inputStream != nil) {
        self.inputStream.delegate = nil;
        [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [inputStream close];
        self.inputStream = nil;
    }
    if (outputStream != nil) {
        self.outputStream.delegate = nil;
        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream close];
        self.outputStream = nil;
        self.outputBuffer = nil;
    }
}

- (void)reconnect {
    [self disconnect];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self connect];
    });
}

- (void)inputStreamHandleEvent:(NSStreamEvent)eventCode {
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            NSLog(@"Opened input stream");
            inputOpened = YES;
            if (inputOpened && outputOpened && state == NetworkStateConnectingToServer) {
                [self setState:NetworkStateConnected];
                [self sendPlayerConnected:true];
            }
        }
        case NSStreamEventHasBytesAvailable: {
            if ([inputStream hasBytesAvailable]) {
                NSLog(@"Input stream has bytes...");
                // TODO: Read bytes
            }
        } break;
        case NSStreamEventHasSpaceAvailable: {
            assert(NO); // should never happen for the input stream
        } break;
        case NSStreamEventErrorOccurred: {
            NSLog(@"Stream open error, reconnecting");
            [self reconnect];
        } break;
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
}

// Add above outputStreamHandleEvent
- (BOOL)writeChunk {
    int amtToWrite = MIN(outputBuffer.length, 1024);
    if (amtToWrite == 0) return FALSE;
    
    NSLog(@"Amt to write: %d/%d", amtToWrite, outputBuffer.length);
    
    int amtWritten = [self.outputStream write:outputBuffer.bytes maxLength:amtToWrite];
    if (amtWritten < 0) {
        [self reconnect];
    }
    int amtRemaining = outputBuffer.length - amtWritten;
    if (amtRemaining == 0) {
        self.outputBuffer = [NSMutableData data];
    } else {
        NSLog(@"Creating output buffer of length %d", amtRemaining);
        self.outputBuffer = [NSMutableData dataWithBytes:outputBuffer.bytes+amtWritten length:amtRemaining];
    }
    NSLog(@"Wrote %d bytes, %d remaining.", amtWritten, amtRemaining);
    okToWrite = FALSE;
    return TRUE;
}

- (void)outputStreamHandleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            NSLog(@"Opened output stream");
            outputOpened = YES;
            if (inputOpened && outputOpened && state == NetworkStateConnectingToServer) {
                [self setState:NetworkStateConnected];
                // TODO: Send message to server
                [self sendPlayerConnected:true];
            }
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            NSLog(@"Ok to send");
            // In outputStreamHandleVent, in NSStreamEventHasSpaceAvailable case
            BOOL wroteChunk = [self writeChunk];
            if (!wroteChunk) {
                okToWrite = TRUE;
            }
        } break;
        case NSStreamEventErrorOccurred: {
            NSLog(@"Stream open error, reconnecting");
            [self reconnect];
        } break;
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (aStream == inputStream) {
            [self inputStreamHandleEvent:eventCode];
        } else if (aStream == outputStream) {
            [self outputStreamHandleEvent:eventCode];
        }
    });
}

-(void) authenticationChanged
{
    if ([GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated)
    {
        NSLog(@"Authentication changed: player auth");
        [self setState:NetworkStateAuthenticated];
        userAuthenticated = YES;
        [self connect];
    }
    else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated)
    {
        NSLog(@"Authentication changed: player not auth");
        [self setState:NetworkStateNotAvailable];
        userAuthenticated = NO;
        [self disconnect];
    }
}

-(void)authenticateLocalUser
{
    if (!gameCenterAvailable)
        return;
    
    NSLog(@"Authenticating local user...");
    if (![GKLocalPlayer localPlayer].isAuthenticated)
    {
        [self setState:NetworkStatePendingAuthentication];
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    }
    else
    {
        NSLog(@"already authenticated!");
    }
}
@end
