#import "Emblem-Swift.h"
#import "SimpleViewController.h"

@implementation SimpleViewController

//@synthesize data;

- (void) viewDidLoad {
    [super viewDidLoad];
    //NSLog(data);
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)changeArtPressed:(id)sender {
    //TODO: somehow call getEntrySegueFromARViewcontroller
//    NSString* segueIdentifer = ChangeArtTableViewController. getEntrySegueFromARViewController;
    [self performSegueWithIdentifier: @"ARtoAddArtTableViewControllerSegue" sender:nil];
}

- (void) receiveArt:(UIImage*) sender {
    self.currentArt = sender;
    
}


+ (NSString *) getEntrySegueFromMapView {
    return @"MapToSimpleViewControllerSegue";
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString: @"ARtoAddArtTableViewControllerSegue"]) {
        ChangeArtTableViewController *vc = (ChangeArtTableViewController *)[segue destinationViewController];
        vc.delegate = self;
    }
}


@end