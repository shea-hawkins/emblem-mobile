#import "Emblem-Swift.h"
#import "SimpleViewController.h"

@implementation SimpleViewController

//@synthesize data;

- (void) viewDidLoad {
    [super viewDidLoad];
    UISwipeGestureRecognizer *swipeleft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleMySwipeLeftGesture:)];
    swipeleft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *swiperight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleMySwipeRightGesture:)];
    swiperight.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:swipeleft];
    [self.view addGestureRecognizer:swiperight];
    
    //NSLog(data);
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)changeArtPressed:(id)sender {
    //TODO: call getEntrySegueFromARViewcontroller
    NSString* segueIdentifer = [ChangeArtTableViewController getEntrySegueFromARViewController];
    [self performSegueWithIdentifier: segueIdentifer sender:nil];
}

- (IBAction)unwindFromLibaryToARVC:(UIStoryboardSegue *)segue {
    NSLog(@"unwindFromLibraryToARVC");
}

- (IBAction)unwindFromChangeArtToARVC:(UIStoryboardSegue *)segue {
    NSLog(@"unwindFromChangeArtToARVC");
}

- (void) receiveArt:(UIImage*) sender {
    self.currentArt = sender;
    
}

-(void)handleMySwipeLeftGesture:(UISwipeGestureRecognizer *)gestureRecognizer {
    
    [self performSegueWithIdentifier:@"ARToChangeArtViewControllerSegue" sender:nil];
}

-(void)handleMySwipeRightGesture:(UISwipeGestureRecognizer *)gestureRecognizer {
    
    [self performSegueWithIdentifier:@"ARToLibraryViewControllerSegue" sender:nil];
}

+ (NSString *) getEntrySegueFromMapView {
    return @"MapToSimpleViewControllerSegue";
    
}

+ (NSString *) getUnwindSegueFromLibraryView {
    return @"UnwindToARVCSegue";
}

+ (NSString *) getUnwindSegueFromChangeArtView {
    return @"UnwindFromChangeArtToARVCSegue";
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString: @"ARtoAddArtTableViewControllerSegue"]) {
//        UINavigationController *navCont = (UINavigationController *)[segue destinationViewController];
//        ChangeArtTableViewController *vc = (ChangeArtTableViewController *)[navCont topViewController];
//        vc.delegate = self;
//    } else if ([[segue identifier] isEqualToString: @"ARtoAddArtScrollViewSegue"]) {
//        UINavigationController *navCont = (UINavigationController *)[segue destinationViewController];
//        ScrollViewController *vc = (ScrollViewController *)[navCont topViewController];
//        //vc.delegate = self;
//    }
    
}


@end