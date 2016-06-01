//
//  nextViewController.m
//  appBasketball
//
//  Created by iMac on 5/31/16.
//  Copyright © 2016 Marshall. All rights reserved.
//

#import "nextViewController.h"
#import "ViewController.h"
#import "AppState.h"
#import "Constants.h"
#import "MeasurementHelper.h"
@import Firebase;
@import FirebaseDatabase;

@interface nextViewController (){
    
    FIRDatabaseHandle _refHandle;
}


@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *messages;
//@property (strong, nonatomic) FIRStorageReference *storageRef;
//@property (nonatomic, strong) FIRRemoteConfig *remoteConfig;

@end

@implementation nextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _clientTable.delegate = self;
    _clientTable.dataSource = self;
    
    _ref = [[FIRDatabase database]reference];
    // Do any additional setup after loading the view.
    _msglength = 10;
    _messages = [[NSMutableArray alloc] init];
    [_clientTable registerClass:UITableViewCell.self forCellReuseIdentifier:@"tableViewCell"];
    
    [self configureDatabase];
    [self configureStorage];
    [self configureRemoteConfig];
    [self fetchConfig];
    [self loadAd];
    [self logViewLoaded];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
}

- (void)configureDatabase {
}

- (void)configureStorage {
}

- (void)configureRemoteConfig {
}

- (void)fetchConfig {
}
- (void)logViewLoaded {
}

- (void)loadAd {
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string {
    NSString *text = textField.text;
    if (!text) {
        return YES;
    }
    long newLength = text.length + string.length - range.length;
    return (newLength <= _msglength);
}

- (void)viewWillAppear:(BOOL)animated {
    [_messages removeAllObjects];
    _refHandle = [[_ref child:@"messages"]observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [_messages addObject:snapshot];
        [_clientTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_messages.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationAutomatic];
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [_ref removeObserverWithHandle:_refHandle];

}


// UITextViewDelegate protocol methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendMessage:@{MessageFieldstext: textField.text}];
    textField.text = @"";
    return YES;
}

- (void)sendMessage:(NSDictionary *)data {
    NSMutableDictionary *mdata = [data mutableCopy];
    mdata[MessageFieldsname] = [AppState sharedInstance].displayName;
    NSURL *photoUrl = AppState.sharedInstance.photoUrl;
    if (photoUrl) {
        mdata[MessageFieldsphotoUrl] = [photoUrl absoluteString];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // Dequeue cell
    UITableViewCell *cell = [_clientTable dequeueReusableCellWithIdentifier:@"tableViewCell" forIndexPath:indexPath];
    
    // Unpack message from Firebase DataSnapshot
    FIRDataSnapshot *messageSnapshot = _messages[indexPath.row];
    NSDictionary<NSString *, NSString *> *message = messageSnapshot.value;
    NSString *name = message[MessageFieldsname];
    NSString *text = message[MessageFieldstext];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", name, text];
    //cell.imageView.image = [UIImage imageNamed: @"ic_account_circle"];
    NSString *photoUrl = message[MessageFieldsphotoUrl];
    if (photoUrl) {
        NSURL *url = [NSURL URLWithString:photoUrl];
        if (url) {
            NSData *data = [NSData dataWithContentsOfURL:url];
            if (data) {
                cell.imageView.image = [UIImage imageWithData:data];
            }
        }
    }
    return cell;
}



- (IBAction)signOutButton:(id)sender {
    
    FIRAuth *firebaseAuth = [FIRAuth auth];
    NSError *signOutError;
    BOOL status = [firebaseAuth signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    }
    [AppState sharedInstance].signedIn = false;
    [self performSegueWithIdentifier:SeguesFpToSignIn sender:nil];
    
}
- (IBAction)didSendMessage:(id)sender {
    
    [self textFieldShouldReturn:_textField];

}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDestructive handler:nil];
        [alert addAction:dismissAction];
        [self presentViewController:alert animated: true completion: nil];
    });
}

@end
