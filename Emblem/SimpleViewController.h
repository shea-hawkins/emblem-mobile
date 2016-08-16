
#import <UIKit/UIKit.h>

@class ChangeArtTableViewController;
@class TestViewController;

@protocol ChangeArtTableViewControllerDelegate<NSObject>
-(void) receiveArt:(UIImage*) sender;
@end


@interface SimpleViewController : UIViewController <ChangeArtTableViewControllerDelegate>
@property (nonatomic, weak) NSString* image;
@property (nonatomic, weak) UIImage* currentArt;
+ (NSString*) getEntrySegueFromMapView;

@end
