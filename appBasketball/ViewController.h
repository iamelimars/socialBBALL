//
//  ViewController.h
//  appBasketball
//
//  Created by iMac on 5/31/16.
//  Copyright © 2016 Marshall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate>

-(IBAction)didTapSignIn:(id)sender;
-(IBAction)didTapSignUp:(id)sender;
-(IBAction)didRequestPasswordReset:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *myEmailField;
@property (weak, nonatomic) IBOutlet UITextField *myPasswordField;


@end

