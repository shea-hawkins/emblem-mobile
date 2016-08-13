
#import <UIKit/UIKit.h>
#import "ARImageView.h"

@interface SimpleViewController : UIViewController

@property (nonatomic, weak) NSString* data;
@property (nonatomic, strong) ARImageView* imgView;


+ (NSString*) getEntrySegueFromMapView;

- (void)showLoadingAnimation;


@end
