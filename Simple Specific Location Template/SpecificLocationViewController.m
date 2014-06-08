//
//  ViewController.m
//  Simple Specific Location Template
//

#import "SpecificLocationViewController.h"
#import "ESTBeaconManager.h"
#import "MBProgressHUD.h"
#import "Colours.h"

#import "UIImage+ResizeMagick.h"
#import "AFNetworking.h"

#import <QuartzCore/QuartzCore.h>

@interface SpecificLocationViewController () <ESTBeaconManagerDelegate>
{
    UIView *_approvalView;
    
    UIButton *_takePicture;
    UIButton *_sendPicture;
    
    UIImageView *_selfie;
    UIImageView *_welcome;
    UIImageView *_foundSeat;
    
    MBProgressHUD *_hud;
    
    BOOL _pictureTaken;
    BOOL _viewStateBeaconNearby;
}

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion *region;

@end

@implementation SpecificLocationViewController

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _takePicture = [UIButton buttonWithType:UIButtonTypeCustom];
    [_takePicture setImage:[UIImage imageNamed:@"takePicture_nonActive"] forState:UIControlStateNormal];
    [_takePicture setImage:[UIImage imageNamed:@"takePicture_active"] forState:UIControlStateHighlighted];
    [_takePicture addTarget:self action:@selector(takeSelfie) forControlEvents:UIControlEventTouchUpInside];
    _takePicture.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_takePicture];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_takePicture]-(105)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_takePicture)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_takePicture
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    _foundSeat = [[UIImageView alloc] init];
    _foundSeat.translatesAutoresizingMaskIntoConstraints = NO;
    _foundSeat.image = [UIImage imageNamed:@"foundSeat"];
    _foundSeat.hidden = YES;
    [self.view addSubview:_foundSeat];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_foundSeat]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_foundSeat)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_foundSeat
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self buildUpApprovalView];
}

- (void)buildUpApprovalView
{
    _approvalView = [[UIView alloc] init];
    _approvalView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _approvalView.backgroundColor = [UIColor whiteColor];
    _approvalView.hidden = YES;
    [self.view addSubview:_approvalView];
    
    _sendPicture = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendPicture setImage:[UIImage imageNamed:@"approval"] forState:UIControlStateNormal];
    [_sendPicture addTarget:self action:@selector(sendSelfie) forControlEvents:UIControlEventTouchUpInside];
    _sendPicture.translatesAutoresizingMaskIntoConstraints = NO;
    [_approvalView addSubview:_sendPicture];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_sendPicture]-(50)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_sendPicture)]];

    
    UIButton *cancelSelfie = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelSelfie setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelSelfie addTarget:self action:@selector(cancelSelfie) forControlEvents:UIControlEventTouchUpInside];
    cancelSelfie.translatesAutoresizingMaskIntoConstraints = NO;
    [_approvalView addSubview:cancelSelfie];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cancelSelfie]-(50)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancelSelfie)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(50)-[_sendPicture]-(>=1)-[cancelSelfie]-(50)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancelSelfie, _sendPicture)]];
    
    _selfie = [[UIImageView alloc] init];
    _selfie.translatesAutoresizingMaskIntoConstraints = NO;
    [_approvalView addSubview:_selfie];
    
    UILabel *lblCancel = [[UILabel alloc] init];
    lblCancel.text = @"AGAIN, PLEASE!";
    lblCancel.translatesAutoresizingMaskIntoConstraints = NO;
    [_approvalView addSubview:lblCancel];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lblCancel]-[cancelSelfie]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblCancel, cancelSelfie)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:lblCancel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:cancelSelfie
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    UILabel *lblOk = [[UILabel alloc] init];
    lblOk.text = @"LOOKS GOOD!";
    lblOk.translatesAutoresizingMaskIntoConstraints = NO;
    [_approvalView addSubview:lblOk];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lblOk]-[_sendPicture]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblOk, _sendPicture)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:lblOk
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_sendPicture
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    id topLayout = self.topLayoutGuide;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLayout]-[_selfie(==210)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_selfie, topLayout)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_approvalView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_selfie
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // setup Estimote beacon manager
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    // create sample region object (you can additionaly pass major / minor values)
    ESTBeaconRegion *region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID major:38147 minor:45030 identifier:@"region"];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    
    // start looking for estimtoe beacons in regions
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: is invoked
    [self.beaconManager startRangingBeaconsInRegion:region];
    
    // setup the title for the controller
    self.navigationItem.title = @"Crout!";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // setup progress until beacon is found
    [self setupHud];
    [self changeStateConnectedToBeacon:NO];
}

- (void)setupHud
{
    if (!_welcome) {
        _welcome = [[UIImageView alloc] init];
        _welcome.translatesAutoresizingMaskIntoConstraints = NO;
        _welcome.image = [UIImage imageNamed:@"welcome"];
        [self.view addSubview:_welcome];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_welcome]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_welcome)]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_welcome
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0]];
    }
    
    _welcome.hidden = NO;
    _foundSeat.hidden = YES;
}

- (void)changeStateConnectedToBeacon:(BOOL)connected
{
    _approvalView.hidden = !connected;
    _takePicture.hidden = !connected;
    
    if (connected) {
        if (_pictureTaken) {
            _approvalView.hidden = NO;
            _takePicture.hidden = YES;
            _foundSeat.hidden = YES;
        } else {
            _approvalView.hidden = YES;
            _takePicture.hidden = NO;
            _foundSeat.hidden = NO;
        }
    }
    
    _viewStateBeaconNearby = connected;
}

- (void)changeStatePictureTaken:(BOOL)pictureTaken
{
    if (pictureTaken) {
        _selfie.image = nil;
        _approvalView.hidden = YES;
        _takePicture.hidden = NO;
        _pictureTaken = NO;
        _foundSeat.hidden = NO;
    } else {
        _selfie.hidden = YES;
        _approvalView.hidden = YES;
        _takePicture.hidden = NO;
        _foundSeat.hidden = NO;
        _pictureTaken = NO;
    }
}

- (void)takeSelfie
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
#if TARGET_IPHONE_SIMULATOR
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
    imagePickerController.editing = YES;
    imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    imagePickerController.delegate = (id)self;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)sendSelfie
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://78.47.196.110:3000"]];
    NSData *imageData = UIImageJPEGRepresentation(_selfie.image, 0.5);
    //NSDictionary *parameters = @{@"username": self.username, @"password" : self.password};
    AFHTTPRequestOperation *op = [manager POST:@"/events/1/selfies" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        [formData appendPartWithFileData:imageData name:@"selfie[image]" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self changeStatePictureTaken:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You rock!" message:@"Woohoo, we got you!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aw, snap!" message:@"Something went wrong, do it again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
    [op start];
}

- (void)cancelSelfie
{
    [self changeStatePictureTaken:NO];
}

#pragma mark - Image picker controller

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // Resize the image from the camera
	UIImage *scaledImage = [image resizedImageByMagick:@"210x210#"];
    
    _selfie.image = scaledImage;
    // Show the photo on the screen
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    _pictureTaken = YES;
    
    [self changeStateConnectedToBeacon:_viewStateBeaconNearby];
    _selfie.hidden = NO;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Beacon methods

- (void)checkBeaconState:(BOOL)found
{
    if (_viewStateBeaconNearby != found) {
        [self changeStateConnectedToBeacon:found];
    }
}

#pragma mark - Beacon delegate methods

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    BOOL found = NO;
    if (beacons.count > 0) {
        for (ESTBeacon *beacon in beacons) {
            if ([beacon.major intValue] == 38147 && [beacon.minor intValue] == 45030) {
                found = YES;
                _welcome.hidden = YES;
                _foundSeat.hidden = NO;
                [self checkBeaconState:found];
            }
        }
    }
    
    if (!found) {
        [self setupHud];
        [self checkBeaconState:found];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
