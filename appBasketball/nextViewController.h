//
//  nextViewController.h
//  appBasketball
//
//  Created by iMac on 5/31/16.
//  Copyright © 2016 Marshall. All rights reserved.
//

#import "ViewController.h"
#import "AppState.h"
#import "Constants.h"

@import Photos;

@import Firebase;
@interface nextViewController : ViewController <UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    int _msglength;
}

- (IBAction)signOutButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITableView *clientTable;
- (IBAction)didSendMessage:(id)sender;

@end
