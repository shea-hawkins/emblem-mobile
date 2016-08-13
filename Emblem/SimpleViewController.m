#import "SimpleViewController.h"

@implementation SimpleViewController

@synthesize data = data;

- (void) viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Hello World");
    NSLog(data);
}
- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

+ (NSString *) getEntrySegueFromMapView {
    return @"MapToSimpleViewControllerSegue";
}

@end