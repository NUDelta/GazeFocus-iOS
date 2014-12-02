//
//  WelcomeViewController.c
//  Location
//
//  Created by Zak Allen on 10/11/14.
//  Copyright (c) 2014 Location. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UILabel *taken;

@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    self.username.delegate = self;
    
    [super viewDidLoad];
}
- (IBAction)startApp:(id)sender {
    
    NSLog(@"Current username: %@", self.username.text);
    
    NSString *serverAddressLike = [NSString stringWithFormat:@"http://gaze-prod.herokuapp.com/api/v1/users/new?user[username]=%@", self.username.text];
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
        NSLog(@"%@", @"Username taken");
        [self.taken setHidden:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.taken setHidden:YES];
        });
    }else{
        NSString *valueToSave = self.username.text;
        NSInteger user_id = [[json objectForKey:@"id"] intValue];
        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"userName"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"score"];
        [[NSUserDefaults standardUserDefaults] setInteger:user_id forKey:@"userId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSegueWithIdentifier:@"WelcomeToTask" sender:sender];
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)username
{
    [username resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
