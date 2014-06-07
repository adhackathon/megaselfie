//
//  ViewController.m
//  Simple Specific Location Template
//

#import "SpecificLocationViewController.h"
#import "ESTBeaconManager.h"

@interface SpecificLocationViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion *region;
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;

@end

@implementation SpecificLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // setup Estimote beacon manager
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    // create sample region object (you can additionaly pass major / minor values)
    
    ESTBeaconRegion * region1 = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID major:7285 minor:31172 identifier:@"Region1"];
    
    // start looking for estimtoe beacons in regions
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: is invoked
    [self.beaconManager startRangingBeaconsInRegion:region1];
    [self.beaconManager startMonitoringForRegion:region1];
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    // Checks if there is any beacons available and find the closests one, then shows the proximity.
    if (beacons.count > 0)
    {
        self.regionLabel.text = region.identifier;
    }
}

- (void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(ESTBeaconRegion *)region
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif) {
        localNotif.alertBody = NSLocalizedString(@"You wanna take a Mega Selfie ?", nil);
        localNotif.alertAction = NSLocalizedString(@"Yes!", nil);
        localNotif.soundName = @"alarmsound.caf";
        localNotif.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
