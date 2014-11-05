//
//  KKNodeViewController.m
//  MultipeerDemo
//
//  Created by mikewang on 14/10/21.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import "KKNodeViewController.h"

#import <sys/utsname.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "KKNearbyViewController.h"



@interface KKNodeViewController () <UITextFieldDelegate,MCNearbyServiceAdvertiserDelegate,KKNearbyViewControllerDelegate>
{
    void (^advertiserInvitationHandler)(BOOL accept, MCSession *session);
}

// @property (nonatomic, strong) void (^advertiserInvitationHandler)(BOOL accept, MCSession *session);


@property (nonatomic, strong) MCPeerID *peerID;

@property (nonatomic, strong) MCSession *session;
//一个 session可以对应多个 目标 peerID.

@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@property (nonatomic, assign) BOOL advertising;

@property (nonatomic, assign) BOOL invitationReceived;

@property (nonatomic, assign) UIToolbar *barGridFooter;

@property (nonatomic, assign) UIBarButtonItem *barItemTalking;

@property (nonatomic, strong) MCPeerID *remotePeerID;


@property (nonatomic,strong) KKNearbyViewController *nearbyViewController;



@end

@implementation KKNodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self configSubview];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configSubview
{
    
    CGFloat width=self.view.bounds.size.width;
    CGFloat height=self.view.bounds.size.height;
    
    
    UILabel *labelName=[[UILabel alloc] initWithFrame:CGRectMake(0, 20, 120, 40)];
    labelName.text=@"display name:";
    labelName.textAlignment=NSTextAlignmentRight;
    
    [self.view addSubview:labelName];
    
    
    UITextField *fieldUsername=[[UITextField alloc] initWithFrame:CGRectMake(120, 20, width-130, 40)];
    fieldUsername.delegate=self;
    fieldUsername.borderStyle=UITextBorderStyleRoundedRect;
    fieldUsername.returnKeyType=UIReturnKeyDone;
    
    [self.view addSubview:fieldUsername];
    
    
    UIToolbar *barGridFooter=[[UIToolbar alloc] initWithFrame:CGRectMake(0, height-44, width, 44)];
    
    // Make BarButton Item
    UIImage *image=[UIImage imageNamed:@"shock"];
    
    UIBarButtonItem *barItemTalking =  [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(catchNearbyPeer:)];
    
    UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
  
    UIBarButtonItem *barItemNearby =  [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(segNearbyPeersView:)];
    
    
    NSArray *barItemsGridFooter=@[barItemNearby,flex1,barItemTalking];
    
    [barGridFooter setItems:barItemsGridFooter];
    
    self.barItemTalking=barItemTalking;
    
    self.barItemTalking.enabled=NO;
    
    [self.view addSubview:barGridFooter];
    
    self.barGridFooter=barGridFooter;
    
    self.invitationReceived=NO;
    
}


// ---- kkaccount app  sync data ---- ///


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segNearby"]) {
        KKNearbyViewController *dest = [segue destinationViewController];
        dest.delegate = self;
    }
    
}


-(void)segNearbyPeersView:(id)sender
{
    [self performSegueWithIdentifier:@"segNearby" sender:sender];
}


-(void)dismissNearbyViewController
{
    

}


//----- talking app ---- //

- (void)configNearbyManagerWithName:(NSString *)name
{
    NSString *nickname;
    
    NSString *uuidStr=[[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    
    if (name.length==0) {
        nickname=[[UIDevice currentDevice] name];
    }
    else
    {
        nickname=name;
    }
    
    // Create myPeerID
    if (!self.peerID) {
         self.peerID = [[MCPeerID alloc] initWithDisplayName:uuidStr];
    }
    
    // Determine device model
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *devType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    // Create DNS-SD TXT record
    
    NSDictionary *info = @{
                           @"nickname":nickname,
                           @"version":[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                           @"build":[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                           @"devtype":devType,
                           @"devname":[[UIDevice currentDevice] name],
                           @"sysname":[[UIDevice currentDevice] systemName],
                           @"sysvers":[[UIDevice currentDevice] systemVersion]
                           };
    
    
    // Setup advertiser
    self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:info serviceType:kServiceType];
    self.advertiser.delegate = self;
    
}






- (void)setAdvertising:(BOOL)value {
    
    if (_advertising==value) {
        return;
    }
    
    
    if (value) {
        [self.advertiser startAdvertisingPeer];
        NSLog(@"Started advertising...");
    }
    else {
        [self.advertiser stopAdvertisingPeer];
        NSLog(@"Stopped advertising");
    }
    _advertising = value;
    
    // Update UI on main thread
    if ([NSThread isMainThread]) {
        //        self.advertiseSwitch.on = value;
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            //            self.advertiseSwitch.on = value;
        });
    }
}


- (void)setInvitationReceived:(BOOL)invitationReceived
{
    _invitationReceived=invitationReceived;
    
    if (invitationReceived) {
        self.barItemTalking.tintColor=[UIColor redColor];
    }
    else
    {
        self.barItemTalking.tintColor=[UIColor blueColor];
    }
}




#pragma mark - MCNearbyServiceAdvertiserDelegate methods

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)remotePeerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler {
    
    
    //只建立单向连接，不建立双向连接。
    
    if ([self.session.connectedPeers containsObject:remotePeerID]) {
        invitationHandler(NO,self.session);
        return;
    }
    
    
    self.invitationReceived=YES;
    
    
    NSDictionary *dicContext=[NSKeyedUnarchiver unarchiveObjectWithData:context];
    
    NSLog(@"Invitation from: %@, info=%@", [dicContext objectForKey:@"nickname"], dicContext);
    
    self.remotePeerID=remotePeerID;
    
    if (self.session==nil) {
        // Create session
        self.session = [[MCSession alloc] initWithPeer:self.peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        // self.session.delegate = self;
        NSLog(@"create Session  %@",self.session);
    }
    
    
    advertiserInvitationHandler=invitationHandler;
    
    return;
    
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    
}



//

- (void)catchNearbyPeer:(id)sender
{

    if (self.peerID==nil) {
        return;
    }
    
    
    
    if (self.connectViewController==nil) {
        self.connectViewController =[[KKConnectViewController alloc] init];
        self.connectViewController.delegate=self;
    }
    
    if (self.session==nil) {
        
        [self presentViewController:self.connectViewController animated:YES completion:^{
            self.connectViewController.peerID=self.peerID;
            self.connectViewController.advertiser=self.advertiser;
            
            self.connectViewController.browsing=YES;

        }];
        
        return;
        
    }
    
    
    
    //-----
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Received Invitation from %@", @"Received Invitation from {Peer}"), self.remotePeerID.displayName]
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *resetAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Reject", @"Reject action")
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction *action)
                                  {
                                      NSLog(@"Reject action");
                                      advertiserInvitationHandler(NO,self.session);
                                      
                                      self.session=nil;
                                      
                                      self.invitationReceived=NO;
                                      
                                  }];
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Accept", @"Accept action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"Accept action");
                                   
                                   advertiserInvitationHandler(YES,self.session);
                                   
                                   [self presentViewController:self.connectViewController animated:YES completion:^{
                                       
                                       self.connectViewController.advertiser=self.advertiser;
                                       
                                       self.connectViewController.session=self.session;
                                       
                                       self.invitationReceived=NO;
                                       
                                   }];
                                   
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:resetAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}


-(void)dismissConnectViewController
{
    
    self.session=nil;
    
    self.invitationReceived=NO;
    
    self.connectViewController=nil;
    
    self.advertiser.delegate=self;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self configNearbyManagerWithName:textField.text];
    
    self.advertising=YES;
    
    self.barItemTalking.enabled=YES;
    
    
    return YES;
    

}



@end

