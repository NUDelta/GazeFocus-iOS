//
//  WelcomeViewController.c
//  Location
//
//  Created by Zak Allen on 10/11/14.
//  Copyright (c) 2014 Location. All rights reserved.
//
#import <GoogleMaps/GoogleMaps.h>
#import "NoTaskViewController.h"
#import "LocationViewController.h"

@interface NoTaskViewController ()<GMSMapViewDelegate>

@end

@implementation NoTaskViewController

GMSMapView *mapView_;
BOOL firstLocationUpdate_;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView* noTaskViewN = [[UIView alloc] initWithFrame: CGRectMake(5, 20, 150, 40)];
    noTaskViewN.layer.cornerRadius = 5.0;
    noTaskViewN.layer.borderWidth = 1;
    noTaskViewN.layer.borderColor = [UIColor grayColor].CGColor;
    noTaskViewN.layer.masksToBounds = YES;
    noTaskViewN.layer.backgroundColor =[UIColor whiteColor].CGColor;
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    [name setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"userName"]];
    [name setTextColor:[UIColor blackColor]];
    name.numberOfLines = 0;
    [name setTextAlignment:NSTextAlignmentCenter];
    [name setBackgroundColor:[UIColor clearColor]];
    [name setFont:[UIFont fontWithName: @"Trebuchet MS" size: 20.0f]];
    [noTaskViewN addSubview: name];
    
    UIView* noTaskViewS = [[UIView alloc] initWithFrame: CGRectMake([UIScreen mainScreen].bounds.size.width - 155, 20, 150, 40)];
    noTaskViewS.layer.cornerRadius = 5.0;
    noTaskViewS.layer.borderWidth = 1;
    noTaskViewS.layer.borderColor = [UIColor grayColor].CGColor;
    noTaskViewS.layer.masksToBounds = YES;
    noTaskViewS.layer.backgroundColor =[UIColor whiteColor].CGColor;
    
    UILabel *score = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    [score setText:[NSString stringWithFormat:@"Score: %d", [[NSUserDefaults standardUserDefaults] integerForKey:@"score"]]];
    [score setTextColor:[UIColor blackColor]];
    score.numberOfLines = 0;
    [score setTextAlignment:NSTextAlignmentCenter];
    [score setBackgroundColor:[UIColor clearColor]];
    [score setFont:[UIFont fontWithName: @"Trebuchet MS" size: 20.0f]];
    [noTaskViewS addSubview: score];
    
    float y = [UIScreen mainScreen].bounds.size.height - 100;
    UIView* noTaskView = [[UIView alloc] initWithFrame: CGRectMake((self.view.center.x)-125, y, 250, 80)];
    noTaskView.layer.cornerRadius = 5.0;
    noTaskView.layer.borderWidth = 1;
    noTaskView.layer.borderColor = [UIColor grayColor].CGColor;
    noTaskView.layer.masksToBounds = YES;
    noTaskView.layer.backgroundColor =[UIColor whiteColor].CGColor;
    
    UILabel *question = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 80)];
    [question setText:@"Go to these locations\nto get a task"];
    [question setTextColor:[UIColor blackColor]];
    question.numberOfLines = 0;
    [question setTextAlignment:NSTextAlignmentCenter];
    [question setBackgroundColor:[UIColor clearColor]];
    [question setFont:[UIFont fontWithName: @"Trebuchet MS" size: 20.0f]];
    [noTaskView addSubview: question];

    
    float latCur = [[NSUserDefaults standardUserDefaults] floatForKey:@"latCur"];
    float lngCur = [[NSUserDefaults standardUserDefaults] floatForKey:@"lngCur"];
    
    if (latCur == 0 && lngCur == 0){
        latCur = 42.056093;
        lngCur = -87.675593;
    }
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latCur
                                                            longitude:lngCur
                                                                 zoom:17];
    
    
    mapView_ = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    mapView_.myLocationEnabled = YES;
    
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    [self.view insertSubview:noTaskViewS atIndex:3];
    [self.view insertSubview:noTaskViewN atIndex:2];
    [self.view insertSubview:noTaskView atIndex:1];
    [self.view insertSubview:mapView_ atIndex:0];
    
    
    
    mapView_.delegate = self;
    
    NSString *serverAddressMap = [NSString stringWithFormat:@"http://gaze-prod.herokuapp.com/api/v1/tasks?username=%@&lat=%f&lng=%f", [[NSUserDefaults standardUserDefaults] stringForKey:@"userName"], latCur, lngCur];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverAddressMap]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
    
    if (jsonArray[0][@"error"]) {
        NSLog(@"Error: invalid username");
        [self.navigationController popViewControllerAnimated:TRUE];

    } else {
//        NSLog(@"Array: %@", jsonArray);
        for (id object in jsonArray) {
            float latTask = [[object objectForKey:@"lat"] floatValue];
            float lngTask = [[object objectForKey:@"lng"] floatValue];
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.title = object[@"question"];
//            marker.snippet = @"click here to answer";
            NSNumber *taskId = object[@"id"];
            marker.userData = taskId;
            marker.position = CLLocationCoordinate2DMake(latTask, lngTask);
            marker.map = mapView_;

        }
    }

}


//- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
//    NSLog(@"User clicked. %@", marker.title);
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure"
//                                                    message:@"Your current location show that you are not close enough to answer the question. Do you still wish to answer?"
//                                                   delegate:self
//                                          cancelButtonTitle:@"No"
//                                          otherButtonTitles:@"Yes", nil];
//    [alert show];
//    [[NSUserDefaults standardUserDefaults] setFloat:marker.position.latitude forKey:@"latTask"];
//    [[NSUserDefaults standardUserDefaults] setFloat:marker.position.longitude forKey:@"lngTask"];
//    [[NSUserDefaults standardUserDefaults] setFloat:marker.position.latitude - 0.0001 forKey:@"latCur"];
//    [[NSUserDefaults standardUserDefaults] setFloat:marker.position.longitude forKey:@"lngCur"];
//    [[NSUserDefaults standardUserDefaults] setInteger:marker.userData forKey:@"taskId"];
//    [[NSUserDefaults standardUserDefaults] setObject:marker.title forKey:@"question"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    NSLog(@"Button Index =%ld",buttonIndex);
//    if (buttonIndex == 0)
//    {
//        NSLog(@"You have clicked No");
//    }
//    else if(buttonIndex == 1)
//    {
//        NSLog(@"You have clicked GOO");
//        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"task"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        LocationViewController *myNewVC = [[LocationViewController alloc] init];
//
//        // do any setup you need for myNewVC
//
//        [self presentModalViewController:myNewVC animated:YES];
//    }
//}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:17];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
