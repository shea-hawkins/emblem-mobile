#import "SimpleViewController.h"

@implementation SimpleViewController

@synthesize data;

- (void) viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Hello World");
    //NSLog(data);
    [self addArtPressed];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void) addArtPressed {
    //TODO: somehow call getEntrySegueFromARViewcontroller
   // NSString* segueIdentifer = [AddArtTableViewController getEntrySegueFromARViewController];
    [self performSegueWithIdentifier: @"ARtoAddArtTableViewControllerSegue" sender:nil];
}

+ (NSString *) getEntrySegueFromMapView {
    
    return @"MapToSimpleViewControllerSegue";
}


@end