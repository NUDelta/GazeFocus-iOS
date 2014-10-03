//
//  ViewController.m
//  GazeFocus
//
//  Created by Zak Allen on 10/2/14.
//  Copyright (c) 2014 Tuko Apps. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CLLocationCoordinate2D panoramaNear = {42.056685, -87.677118};
    
    GMSPanoramaView *panoView_;
    panoView_ = [GMSPanoramaView panoramaWithFrame:self.view.bounds
                                    nearCoordinate:panoramaNear];
    panoView_.camera = [GMSPanoramaCamera cameraWithHeading:0 pitch: 0 zoom:1];
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(42.056817, -87.676748);
    
    
    [panoView_ animateToCamera:[GMSPanoramaCamera cameraWithHeading:60 pitch: 0 zoom:1] animationDuration:4];
    
    // Create a marker at the House

    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    
    marker.icon = [UIImage imageNamed:@"redbox"];
    
    // Add the marker to a GMSPanoramaView object named panoView_
    marker.panoramaView = panoView_;
    
    UIView* roundedView = [[UIView alloc] initWithFrame: CGRectMake((self.view.center.x)-150, (self.view.center.y)+100, 300, 200)];
    roundedView.layer.cornerRadius = 5.0;
    roundedView.layer.masksToBounds = YES;
    roundedView.layer.backgroundColor =[UIColor whiteColor].CGColor;
    
    UILabel *question = [[UILabel alloc] initWithFrame:CGRectMake(95, 10, 300, 20)];
    [question setText:@"Is this Ford?"];
    [question setTextColor:[UIColor blackColor]];
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
    button.frame = CGRectMake(75.0, 45.0, 160.0, 40.0);
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
    button2.frame = CGRectMake(75.0, 95.0, 160.0, 40.0);
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
    button3.frame = CGRectMake(75.0, 145.0, 160.0, 40.0);
    [roundedView addSubview:button3];
    
    [self.view insertSubview:roundedView atIndex:1];
    [self.view insertSubview:panoView_ atIndex:0];
}

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

- (float)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}


@end
