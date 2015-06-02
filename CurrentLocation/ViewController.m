//
//  ViewController.m
//  CurrentLocation
//
//  Created by Pradip on 6/1/15.
//  Copyright (c) 2015 Pradip. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>

@interface ViewController ()<CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *btnGetLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblLatitude;
@property (strong, nonatomic) IBOutlet UILabel *lblLongitude;
@property (strong, nonatomic) IBOutlet UILabel *lblAccuracy;
@property (strong, nonatomic) IBOutlet UILabel *lblAltitude;
@property (strong, nonatomic) IBOutlet UILabel *lblAltitudeAccuracy;
@property (strong, nonatomic) IBOutlet UILabel *lblAddress;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnGetLocationTouched:(id)sender {
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    
    NSString *currentLatitude = [[NSString alloc]
                                 initWithFormat:@"Latitude = %+.6f",
                                 newLocation.coordinate.latitude];
    self.lblLatitude.text = currentLatitude;
    
    NSString *currentLongitude = [[NSString alloc]
                                  initWithFormat:@"Longitude = %+.6f",
                                  newLocation.coordinate.longitude];
    self.lblLongitude.text = currentLongitude;
    
    NSString *currentHorizontalAccuracy =
    [[NSString alloc]
     initWithFormat:@"Accuracy = %+.6f",
     newLocation.horizontalAccuracy];
    self.lblAccuracy.text = currentHorizontalAccuracy;
    
    NSString *currentAltitude = [[NSString alloc]
                                 initWithFormat:@"Altitude = %+.6f",
                                 newLocation.altitude];
    self.lblAltitude.text = currentAltitude;
    
    NSString *currentVerticalAccuracy =
    [[NSString alloc]
     initWithFormat:@"Altitude Accuracy = %+.6f",
     newLocation.verticalAccuracy];
    self.lblAltitudeAccuracy.text = currentVerticalAccuracy;
    
    [self ReversGeocode:newLocation];
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error
{
}

- (void) ReversGeocode: (CLLocation *)newLocation {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation
                   completionHandler:^(NSArray *placemarks,
                                       NSError *error) {
                       if (error) {
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                       }
                       if (placemarks && placemarks.count > 0) {
                           CLPlacemark *placemark = placemarks[0];
                           NSDictionary *addressDictionary = placemark.addressDictionary;
                           NSString *address = [addressDictionary objectForKey: (NSString *)kABPersonAddressStreetKey];
                           NSString *city = [addressDictionary objectForKey: (NSString *)kABPersonAddressCityKey];
                           NSString *state = [addressDictionary objectForKey: (NSString *)kABPersonAddressStateKey];
                           NSString *zip = [addressDictionary objectForKey: (NSString *)kABPersonAddressZIPKey];
                           self.lblAddress.text = [NSString localizedStringWithFormat: @"%@ %@ %@ %@", address,city, state, zip];
                       }
                   }];
}
@end
