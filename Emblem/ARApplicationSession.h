//
//  ApplicationSession.h
//  Emblem
//
//  Created by Humanity on 8/13/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

#ifndef ARApplicationSession_h
#define ARApplicationSession_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define E_INITIALIZING_VUFORIA      100

#define E_INITIALIZING_CAMERA       110
#define E_STARTING_CAMERA           111
#define E_STOPPING_CAMERA           112
#define E_DEINIT_CAMERA             113

#define E_INIT_TRACKERS             120
#define E_LOADING_TRACKERS_DATA     121
#define E_STARTING_TRACKERS         122
#define E_STOPPING_TRACKERS         123
#define E_UNLOADING_TRACKERS_DATA   124
#define E_DEINIT_TRACKERS           125

#define E_CAMERA_NOT_STARTED        150

#define E_INTERNAL_ERROR            -1


@protocol ARApplicationControl

@required
// this method is called to notify the application that the initialization (initAR) is complete
// usually the application then starts the AR through a call to startAR
- (void) onInitARDone:(NSError *)error;

// the application must initialize its tracker(s)
- (bool) doInitTrackers;

// the application must initialize the data associated to its tracker(s)
- (bool) doLoadTrackersData;

// the application must starts its tracker(s)
- (bool) doStartTrackers;

// the application must stop its tracker(s)
- (bool) doStopTrackers;

// the application must unload the data associated its tracker(s)
- (bool) doUnloadTrackersData;

// the application must deinititalize its tracker(s)
- (bool) doDeinitTrackers;

//@optional
//// optional method to handle the Vuforia callback - can be used to swap dataset for instance
//- (void) onVuforiaUpdate: (Vuforia::State *) state;

@end

@interface ARApplicationSession : NSObject

- (id)initWithDelegate:(id<ARApplicationControl>) delegate;

- (void)initAR:(int) VuforiaInitFlags orientation:(UIInterfaceOrientation)ARViewOrientation;

- (bool)startAR:(NSError **)error;

- (bool)pauseAR:(NSError **)error;

- (bool)resumeAR:(NSError **)error;

- (bool)stopAR:(NSError **)error;

- (bool)stopCamera:(NSError **)error;

@property (nonatomic, readwrite) BOOL isRetinaDisplay;
@property (nonatomic, readwrite) BOOL cameraIsStarted;

@property (nonatomic, readwrite) struct tagViewport {
    int posX;
    int posY;
    int sizeX;
    int sizeY;
} viewport;

@end

#endif /* ApplicationSession_h */
