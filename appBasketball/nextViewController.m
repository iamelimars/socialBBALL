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
@import FirebaseStorage;
@import GoogleMobileAds;
static NSString* const kBannerAdUnitID = @"ca-app-pub-3940256099942544/2934735716";


@interface nextViewController (){
    
    FIRDatabaseHandle _refHandle;
}

@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *messages;
@property (strong, nonatomic) FIRStorageReference *storageRef;
@property (nonatomic, strong) FIRRemoteConfig *remoteConfig;

@end

@implementation nextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _clientTable.delegate = self;
    _clientTable.dataSource = self;
    
    _ref = [[FIRDatabase database]reference];
    _remoteConfig = [FIRRemoteConfig remoteConfig];
    // Create Remote Config Setting to enable developer mode.
    // Fetching configs from the server is normally limited to 5 requests per hour.
    // Enabling developer mode allows many more requests to be made per hour, so developers
    // can test different config values during development.
    FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] initWithDeveloperModeEnabled:YES];
    _remoteConfig.configSettings = remoteConfigSettings;
    
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
    long expirationDuration = 3600;
    // If in developer mode cacheExpiration is set to 0 so each fetch will retrieve values from
    // the server.
    if (self.remoteConfig.configSettings.isDeveloperModeEnabled) {
        expirationDuration = 0;
    }
    
    // cacheExpirationSeconds is set to cacheExpiration here, indicating that any previously
    // fetched and cached config would be considered expired because it would have been fetched
    // more than cacheExpiration seconds ago. Thus the next fetch would go to the server unless
    // throttling is in progress. The default expiration duration is 43200 (12 hours).
    [self.remoteConfig fetchWithExpirationDuration:expirationDuration completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            NSLog(@"Config fetched!");
            [_remoteConfig activateFetched];
            _msglength = _remoteConfig[@"friendly_msg_length"].numberValue.intValue;
            NSLog(@"Friendly msg length config: %d", _msglength);
        } else {
            NSLog(@"Config not fetched");
            NSLog(@"Error %@", error);
        }
    }];
    
}
- (void)logViewLoaded {
}

- (void)loadAd {
    self.bannerView.adUnitID = kBannerAdUnitID;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
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
    //Push datat to firebase database
    [[[_ref child:@"messages"]childByAutoId]setValue:mdata];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    NSURL *referenceUrl = info[UIImagePickerControllerReferenceURL];
    PHFetchResult* assets = [PHAsset fetchAssetsWithALAssetURLs:@[referenceUrl] options:nil];
    PHAsset *asset = [assets firstObject];
    [asset requestContentEditingInputWithOptions:nil
                               completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
                                   NSURL *imageFile = contentEditingInput.fullSizeImageURL;
                                   NSString *filePath = [NSString stringWithFormat:@"%@/%lld/%@", [FIRAuth auth].currentUser.uid, (long long)([[NSDate date] timeIntervalSince1970] * 1000.0), [referenceUrl lastPathComponent]];
                                   FIRStorageMetadata *metadata = [FIRStorageMetadata new];
                                   metadata.contentType = @"image/jpeg";
                                   [[_storageRef child:filePath]
                                    putFile:imageFile metadata:metadata
                                    completion:^(FIRStorageMetadata *metadata, NSError *error) {
                                        if (error) {
                                            NSLog(@"Error uploading: %@", error);
                                            return;
                                        }
                                        [self sendMessage:@{MessageFieldsimageUrl:
                                                                [_storageRef child:metadata.path].description}];
                                    }
                                    ];
                               }];
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
    NSString *imageUrl = message[MessageFieldsimageUrl];
    if (imageUrl) {
        if ([imageUrl hasPrefix:@"gs://"]) {
            [[[FIRStorage storage] referenceForURL:imageUrl] dataWithMaxSize:INT64_MAX
                                                                  completion:^(NSData *data, NSError *error) {
                                                                      if (error) {
                                                                          NSLog(@"Error downloading: %@", error);
                                                                          return;
                                                                      }
                                                                      cell.imageView.image = [UIImage imageWithData:data];
                                                                  }];
        } else {
            cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"sent by: %@", name];
    } else {
        NSString *text = message[MessageFieldstext];
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", name, text];
        cell.imageView.image = [UIImage imageNamed: @"ic_account_circle"];
        cell.backgroundColor = [UIColor clearColor];
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
    }    return cell;
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

- (IBAction)didTapCameraButton:(id)sender {
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:picker animated:YES completion:NULL];
    
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
