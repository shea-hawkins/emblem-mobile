#import "SimpleViewController.h"
#import "ARImageView.h"

@interface SimpleViewController ()

@property (weak, nonatomic) IBOutlet UIImageView* ARViewPlaceholder;

@end


@implementation SimpleViewController

@synthesize data, imgView;

- (CGRect)getCurrentARViewFrame
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect viewFrame = screenBounds;
    
    return viewFrame;
}

- (void)loadView
{
    self.title = @"ARView";
    
    if (self.ARViewPlaceholder != nil) {
        [self.ARViewPlaceholder removeFromSuperview];
        self.ARViewPlaceholder = nil;
    }
    
    // vapp = [[SampleApplicationSession alloc] initWithDelegate:self];
    
    CGRect viewFrame = [self getCurrentARViewFrame];
    
    imgView = [[ARImageView alloc] initWithFrame:viewFrame];
    [self setView:imgView];
    // Creates the vuforia session
    // VuforiaSamplesAppDelegate *appDelegate = (VuforiaSamplesAppDelegate*)[[UIApplication sharedApplication] delegate];
    // [vapp initAR:Vuforia::GL_20 orientation:self.interfaceOrientation];
    [self showLoadingAnimation];
    
}

- (void) viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Hello World");
    NSLog(data);
}

- (void) showLoadingAnimation {
    CGRect indicatorBounds;
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    int smallerBoundsSize = MIN(mainBounds.size.width, mainBounds.size.height);
    int largerBoundsSize = MAX(mainBounds.size.width, mainBounds.size.height);
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        indicatorBounds = CGRectMake(smallerBoundsSize / 2 - 12, largerBoundsSize / 2 - 12, 24, 24);
    } else {
        indicatorBounds = CGRectMake(largerBoundsSize / 2 - 12, smallerBoundsSize / 2 - 12, 24, 24);
    }
    UIActivityIndicatorView* loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:indicatorBounds];
    loadingIndicator.tag = 1;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [imgView addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

+ (NSString *) getEntrySegueFromMapView {
    return @"MapToSimpleViewControllerSegue";
}

@end
