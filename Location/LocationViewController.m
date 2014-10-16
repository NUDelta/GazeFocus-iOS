//
//  LocationViewController.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "LocationViewController.h"

@interface LocationViewController ()

@end

@implementation LocationViewController

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:)
                                                 name:@"refreshView" object:nil];

    
	// Do any additional setup after loading the view, typically from a nib.
   
        
    float latCur = [[NSUserDefaults standardUserDefaults] floatForKey:@"latCur"];
    float lngCur = [[NSUserDefaults standardUserDefaults] floatForKey:@"lngCur"];
    float latTask = [[NSUserDefaults standardUserDefaults] floatForKey:@"latTask"];
    float lngTask = [[NSUserDefaults standardUserDefaults] floatForKey:@"lngTask"];
    
    CLLocationCoordinate2D panoramaNear = {latCur, lngCur};
    
    GMSPanoramaView *panoView_;
    panoView_ = [GMSPanoramaView panoramaWithFrame:self.view.bounds
                                    nearCoordinate:panoramaNear];
    panoView_.camera = [GMSPanoramaCamera cameraWithHeading:0 pitch: 0 zoom:1];
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(latTask, lngTask);
    
    float fLat = degreesToRadians(panoramaNear.latitude);
    float fLng = degreesToRadians(panoramaNear.longitude);
    float tLat = degreesToRadians(position.latitude);
    float tLng = degreesToRadians(position.longitude);
    
    float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree < 0) {
        degree = 360+degree;
    }
    
    [panoView_ animateToCamera:[GMSPanoramaCamera cameraWithHeading:degree pitch: -10 zoom:1] animationDuration:4];
    
    // Create a marker at the House
    
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    
    marker.icon = [UIImage imageNamed:@"redbox"];
    
    // Add the marker to a GMSPanoramaView object named panoView_
    marker.panoramaView = panoView_;
    
    UIView* roundedView = [[UIView alloc] initWithFrame: CGRectMake((self.view.center.x)-125, (self.view.center.y)+50, 250, 200)];
    roundedView.layer.cornerRadius = 5.0;
    roundedView.layer.masksToBounds = YES;
    roundedView.layer.backgroundColor =[UIColor whiteColor].CGColor;
    
    UILabel *question = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 250, 30)];
    [question setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"question"]];
    [question setTextColor:[UIColor blackColor]];
    [question setTextAlignment:NSTextAlignmentCenter];
    [question setBackgroundColor:[UIColor clearColor]];
    [question setFont:[UIFont fontWithName: @"Trebuchet MS" size: 20.0f]];
    [roundedView addSubview: question];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    [button addTarget:self
    //               action:@selector(aMethod:)
    //     forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor colorWithRed:0.521569
                                             green:0.768627
                                              blue:0.254902 alpha:1];
    button.layer.cornerRadius = 10;
    button.tintColor = [UIColor whiteColor];
    [button setTitle:@"Yes" forState:UIControlStateNormal];
    button.frame = CGRectMake(45.0, 45.0, 160.0, 40.0);
    [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    button.tag=0;
    [roundedView addSubview:button];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    [button addTarget:self
    //               action:@selector(aMethod:)
    //     forControlEvents:UIControlEventTouchUpInside];
    button2.backgroundColor = [UIColor colorWithRed:0.921569
                                              green:0.468627
                                               blue:0.154902 alpha:1];
    button2.layer.cornerRadius = 10;
    button2.tintColor = [UIColor whiteColor];
    [button2 setTitle:@"No" forState:UIControlStateNormal];
    button2.frame = CGRectMake(45.0, 95.0, 160.0, 40.0);
    [button2 addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    button2.tag=1;
    [roundedView addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    [button addTarget:self
    //               action:@selector(aMethod:)
    //     forControlEvents:UIControlEventTouchUpInside];
    button3.backgroundColor = [UIColor colorWithRed:0.151569
                                              green:0.768627
                                               blue:0.94902 alpha:1];
    button3.layer.cornerRadius = 10;
    button3.tintColor = [UIColor whiteColor];
    [button3 setTitle:@"Maybe" forState:UIControlStateNormal];
    button3.frame = CGRectMake(45.0, 145.0, 160.0, 40.0);
    [button3 addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    button3.tag=2;
    [roundedView addSubview:button3];
    
    [self.view insertSubview:roundedView atIndex:3];
    [self.view insertSubview:panoView_ atIndex:2];

}


-(void)buttonSelected:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    NSLog(@"buttonSelectd: %ld",(long)button.tag);
    //implement your code what you want.
    NSString *answer = @"yes";
    if (button.tag == 1){
        answer = @"no";
    }else if (button.tag == 2) {
        answer = @"maybe";
    }
    
    NSString *serverAddressLike = [NSString stringWithFormat:@"http://gaze-prod.herokuapp.com/api/v1/answers/new?answer[user_id]=%ld&answer[task_id]=%ld&answer[value]=%@", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"userId"], (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"taskId"], answer];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverAddressLike]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
    //NSLog(@"%@", urlResponse);
    NSLog(@"%@", json);
    if (json == nil){
        NSLog(@"%@", @"Error in submitting answer");
    }else{
        NSLog(@"%@", @"Answer submitted!");
        
        UIView* roundedView2 = [[UIView alloc] initWithFrame: CGRectMake((self.view.center.x)-125, (self.view.center.y)+50, 250, 200)];
        roundedView2.layer.cornerRadius = 5.0;
        roundedView2.layer.masksToBounds = YES;
        roundedView2.layer.backgroundColor =[UIColor whiteColor].CGColor;
        
        UILabel *question = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 250, 100)];
        question.numberOfLines = 0;
        [question setText:@"Thanks for submitting! Enjoy your day."];
        [question setTextColor:[UIColor blackColor]];
        [question setTextAlignment:NSTextAlignmentCenter];
        [question setBackgroundColor:[UIColor clearColor]];
        [question setFont:[UIFont fontWithName: @"Trebuchet MS" size: 20.0f]];
        [roundedView2 addSubview: question];
        
        [self.view insertSubview:roundedView2 atIndex:4];
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"task"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIApplication *app = [UIApplication sharedApplication];
            [app performSelector:@selector(suspend)];
        });
        
    }

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
