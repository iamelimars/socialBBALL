//
//  ViewController.m
//  appBasketball
//
//  Created by iMac on 5/31/16.
//  Copyright © 2016 Marshall. All rights reserved.
//

#import "ViewController.h"
#import "MeasurementHelper.h"
#import "Constants.h"
#import "AppState.h"
@import Firebase;
@import FirebaseAuth;
@import UIKit;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"abc");
    _myPasswordField.delegate = self;
    _myEmailField.delegate = self;
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    FIRUser *user = [FIRAuth auth].currentUser;
    if (user) {
        //[self signedIn:user];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didTapSignIn:(id)sender{
    // Sign in with credentials
    NSString *email = _myEmailField.text;
    NSString *password = _myPasswordField.text;
    [[FIRAuth auth]signInWithEmail:email
                          password:password
                        completion:^(FIRUser * _Nullable user, NSError * _Nullable error){
                            if (error) {
                                NSLog(@"%@", error.localizedDescription);
                                return;
                            }
                            [self signedIn:user];
                            
                            
                        }];
    
}
-(IBAction)didTapSignUp:(id)sender{
    
    NSString *email = _myEmailField.text;
    NSString *password = _myPasswordField.text;
    [[FIRAuth auth]createUserWithEmail:email
                              password:password
                            completion:^(FIRUser * _Nullable user, NSError * _Nullable error){
                                if (error) {
                                    NSLog(@"%@", error.localizedDescription);
                                    return;
                                }
                                [self setDisplayName:user];
                                
                                
                            }];
  
    
}
-(void)setDisplayName:(FIRUser *)user {
    FIRUserProfileChangeRequest *changeRequest = [user profileChangeRequest];
    
    changeRequest.displayName = [[user.email componentsSeparatedByString:@"@"]objectAtIndex:0];
    [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error){
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            return;
        
        }
        [self signedIn:[FIRAuth auth].currentUser];
    }];
    
}

-(IBAction)didRequestPasswordReset:(id)sender{
    UIAlertController *prompt = [UIAlertController alertControllerWithTitle:nil
                                                                    message:@"Email:"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    __weak UIAlertController *weakPrompt = prompt;
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   UIAlertController *strongPrompt = weakPrompt;
                                   NSString *userInput = strongPrompt.textFields[0].text;
                                   if (!userInput.length)
                                   {
                                       return;
                                   }
                                   [[FIRAuth auth] sendPasswordResetWithEmail:userInput
                                                                   completion:^(NSError * _Nullable error) {
                                                                       if (error) {
                                                                           NSLog(@"%@", error.localizedDescription);
                                                                           return;
                                                                       }
                                                                   }];
                                   
                               }];
    [prompt addTextFieldWithConfigurationHandler:nil];
    [prompt addAction:okAction];
    [self presentViewController:prompt animated:YES completion:nil];

}

-(void)signedIn:(FIRUser *)user{
    
    [MeasurementHelper sendLoginEvent];
    
    [AppState sharedInstance].displayName = user.displayName.length > 0 ? user.displayName : user.email;
    [AppState sharedInstance].photoUrl = user.photoURL;
    [AppState sharedInstance].signedIn = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationKeysSignedIn
                                                        object:nil userInfo:nil];
    [self performSegueWithIdentifier:SeguesSignInToFp sender:nil];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}


@end
