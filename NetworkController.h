//
//  NetworkController.h
//  Tube Man Boxing
//
//  Created by Cheebs on 26/11/12.
//
//

#import <Foundation/Foundation.h>
#import "GameKit/GameKit.h"
#import "MessageWriter.h"

typedef enum
{
    NetworkStateNotAvailable,
    NetworkStatePendingAuthentication,
    NetworkStateAuthenticated,
    NetworkStateConnectingToServer,
    NetworkStateConnected,
    NetworkStatePendingMatchStatus,
    NetworkStateReceivedMatchStatus,
}NetworkState;

typedef enum {
    MessagePlayerConnected = 0,
    MessageNotInMatch,
} MessageType;

@protocol NetworkControlerDelegate
-(void)stateChanged:(NetworkState)newState;
@end

@interface NetworkController : NSObject <NSStreamDelegate>
{
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    id <NetworkControlerDelegate> delegate;
    NetworkState state;
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    BOOL inputOpened;
    BOOL outputOpened;
    NSMutableData *outputBuffer;
    BOOL okToWrite;
}
@property (assign, readonly) BOOL gameCenterAvailable;
@property (assign, readonly) BOOL userAuthenticated;
@property (assign) id <NetworkControlerDelegate> delegate;
@property (assign, readonly) NetworkState state;
@property (retain) NSInputStream *inputStream;
@property (retain) NSOutputStream *outputStream;
@property (assign) BOOL inputOpened;
@property (assign) BOOL outputOpened;
@property (retain) NSMutableData *outputBuffer;
@property (assign) BOOL okToWrite;


+(NetworkController *) sharedNetworkController;
-(void) authenticateLocalUser;
@end
