/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#import <UIKit/UIKit.h>
#import "SampleAppMenuViewController.h"

@interface ImageTargetsViewController : UIViewController <SampleAppMenuDelegate> {
    
    BOOL switchToTarmac;
    BOOL switchToStonesAndChips;
    
    // menu options
    BOOL extendedTrackingEnabled;
    BOOL continuousAutofocusEnabled;
    BOOL flashEnabled;
    BOOL frontCameraEnabled;
}

+ (NSString*) getEntrySegueFromMapView;

@property (nonatomic, strong) UITapGestureRecognizer * tapGestureRecognizer;
@property (nonatomic, readwrite) BOOL showingMenu;

@end
