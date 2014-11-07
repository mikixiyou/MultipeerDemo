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

#import "UIExpandingTextView.h"

#import "BubbleView.h"



@interface KKNodeViewController () <UITextFieldDelegate,MCNearbyServiceAdvertiserDelegate,KKNearbyViewControllerDelegate,UIExpandingTextViewDelegate,UITextViewDelegate>
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

@property (nonatomic,strong) UITextView *expandingTextView;

@property (nonatomic,strong) BubbleView *bubble;


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
    
    
    UITextView *textView=[[UITextView alloc] initWithFrame:CGRectMake(10, 180, width-20, 40)];
    textView.delegate=self;
    textView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    textView.layer.borderWidth=1;
    

    textView.font=[UIFont systemFontOfSize:14];
    
    [self.view addSubview:textView];
    
    self.expandingTextView=textView;
    
    
//    self.bubble=[[BubbleView alloc] initWithFrame:CGRectMake(150, 250, 10, 10)];
    
    self.bubble=[[BubbleView alloc] initWithFrame:CGRectMake(50, 250, 200, 200) activationFrame:CGRectMake(50, 250, 30, 40)];
    
    [self.view addSubview:self.bubble];
    
    
    
    UIToolbar *barGridFooter=[[UIToolbar alloc] initWithFrame:CGRectMake(0, height-44, width, 44)];
    
    // Make BarButton Item
    UIImage *image=[UIImage imageNamed:@"shock"];
    
    UIBarButtonItem *barItemTalking =  [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(catchNearbyPeer:)];
    
    UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
  
    UIBarButtonItem *barItemNearby =  [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(segNearbyPeersView:)];
   
    UIBarButtonItem *barItemBubble =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(bubbleTest)];
    
    
    NSArray *barItemsGridFooter=@[barItemNearby,flex1,barItemBubble,flex1,barItemTalking];
    
    [barGridFooter setItems:barItemsGridFooter];
    
    self.barItemTalking=barItemTalking;
    
    self.barItemTalking.enabled=NO;
    
    [self.view addSubview:barGridFooter];
    
    self.barGridFooter=barGridFooter;
    
    self.invitationReceived=NO;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    self.expandingTextView.text=@"";
    
    UIEdgeInsets edgeInsets = self.expandingTextView.contentInset;
    
    CGFloat offset=[UIFont systemFontSize]/2.0;
    
    offset=ceilf(offset);
    
    edgeInsets.top = offset;
//    edgeInsets.bottom=offset;
    
//    self.expandingTextView.contentInset=edgeInsets;
    
//        self.expandingTextView.textContainerInset=UIEdgeInsetsMake(4, 0, 4, 0);
    
       GTMLoggerDebug(@"self.expandingTextView.textContainerInset = %@",NSStringFromUIEdgeInsets(self.expandingTextView.textContainerInset));
    
    [self textViewDidChange:self.expandingTextView];
}


-(void)bubbleTest
{

    [self.bubble StageGrow];
    
}

-(void)textViewDidChange:(UITextView *)textView
{
    
    GTMLoggerDebug(@"%@",[NSDate date]);
    
    GTMLoggerDebug(@"textView.textContainerInset = %@",NSStringFromUIEdgeInsets(textView.textContainerInset));
    
    GTMLoggerDebug(@"textview contentOffset = %@",NSStringFromCGPoint(textView.contentOffset));
    
    GTMLoggerDebug(@"textview contentInset = %@",NSStringFromUIEdgeInsets(textView.contentInset));
    
    
    GTMLoggerDebug(@"textview contentSize = %@",NSStringFromCGSize(textView.contentSize));
    
    CGFloat fontSize=14;
    
    CGRect frame = textView.frame;
    
    GTMLoggerDebug(@"textview       frame = %@",NSStringFromCGRect(textView.frame));
    
    CGFloat minHeight=fontSize+textView.textContainerInset.top+textView.textContainerInset.bottom;
    CGFloat maxHeight=fontSize*5+textView.textContainerInset.top+textView.textContainerInset.bottom;
    
    
    NSDictionary  *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    
    CGRect textRect= [textView.text boundingRectWithSize:CGSizeMake(frame.size.width, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    
    GTMLoggerDebug(@"textview   text rect = %@",NSStringFromCGRect(textRect));
    
    if (textRect.size.height<fontSize*2) {
        textView.contentSize=CGSizeMake(textView.contentSize.width,ceilf(textRect.size.height)+textView.textContainerInset.top+textView.textContainerInset.bottom);
    }
    
    
    CGFloat heightContent=textView.contentSize.height;

    
//        if (textRect.size.height>fontSize*2) {
//            textView.textContainerInset=UIEdgeInsetsMake(2, 0, 2, 0);
//        }
//        else
//        {
//            textView.textContainerInset=UIEdgeInsetsMake(8, 0, 8, 0);
//        }
    
    //    heightContent=heightContent+textView.textContainerInset.top+textView.textContainerInset.bottom;
    
    //    textView.textContainerInset=UIEdgeInsetsMake(0, 0, 0, 0);
    
    if (heightContent>=minHeight && heightContent<=maxHeight) {
        
        CGFloat heightOffset=heightContent - frame.size.height;
        
        if (heightOffset==0) {
            return;
        }
        
        
        if (frame.size.height+heightOffset<minHeight) {
            return;
        }
        
        frame.origin.y=frame.origin.y - heightOffset;
        
        frame.size.height=frame.size.height+heightOffset;

        
        [UIView animateWithDuration:0.2 animations:^{
            textView.frame=frame;

        } completion:^(BOOL finished) {
            GTMLoggerDebug(@"textview       frame = %@",NSStringFromCGRect(textView.frame));
            
            GTMLoggerDebug(@"textview contentOffset = %@",NSStringFromCGPoint(textView.contentOffset));
        }
         ];
        
        [textView setContentOffset:CGPointMake(0, 0) animated:YES];
        
        
    }
    else
    {
        GTMLoggerDebug(@"textview       frame = %@",NSStringFromCGRect(textView.frame));
        
        GTMLoggerDebug(@"textview contentOffset = %@",NSStringFromCGPoint(textView.contentOffset));
        
        //        [textView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }

}

-(void)textViewDidChange2:(UITextView *)textView
{
    GTMLoggerDebug(@"%@",[NSDate date]);
    
    GTMLoggerDebug(@"self.expandingTextView.textContainerInset = %@",NSStringFromUIEdgeInsets(self.expandingTextView.textContainerInset));
    
    GTMLoggerDebug(@"textview contentOffset = %@",NSStringFromCGPoint(textView.contentOffset));
    
    GTMLoggerDebug(@"textview contentInset = %@",NSStringFromUIEdgeInsets(textView.contentInset));
    
    
    GTMLoggerDebug(@"textview contentSize = %@",NSStringFromCGSize(textView.contentSize));
    
    CGRect frame = textView.frame;
    
    GTMLoggerDebug(@"textview       frame = %@",NSStringFromCGRect(textView.frame));
    
    CGFloat minHeight=30;
    CGFloat maxHeight=100;
    
    
    NSDictionary  *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    
    CGRect textRect= [textView.text boundingRectWithSize:CGSizeMake(frame.size.width, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    
    GTMLoggerDebug(@"textview   text rect = %@",NSStringFromCGRect(textRect));

    
    CGFloat heightContent=textView.contentSize.height;
    
//    h=ceilf(rect.size.height);
    

//    if (textRect.size.height>50) {
//        self.expandingTextView.textContainerInset=UIEdgeInsetsMake(2, 0, 2, 0);
//    }
//    else
//    {
//        self.expandingTextView.textContainerInset=UIEdgeInsetsMake(8, 0, 8, 0);
//    }
    
    
    if (heightContent>=minHeight && heightContent<=maxHeight) {

        CGFloat heightOffset=heightContent - frame.size.height;
        
        if (heightOffset==0) {
            return;
        }
        
        frame.origin.y=frame.origin.y - heightOffset;
        
//        frame.size.height=heightContent;
        
         frame.size.height=frame.size.height+heightOffset;
        
        [UIView animateWithDuration:0.2 animations:^{
            textView.frame=frame;
            //
        }
                         completion:^(BOOL finished) {
                             GTMLoggerDebug(@"textview       frame = %@",NSStringFromCGRect(textView.frame));
                             
                             GTMLoggerDebug(@"textview contentOffset = %@",NSStringFromCGPoint(textView.contentOffset));
                         }
         ];
        
        [textView setContentOffset:CGPointMake(0, 0) animated:YES];
        
        
    }
    else
    {
        GTMLoggerDebug(@"textview       frame = %@",NSStringFromCGRect(textView.frame));
        
        GTMLoggerDebug(@"textview contentOffset = %@",NSStringFromCGPoint(textView.contentOffset));
    
//        [textView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }
    

    

    

    
    
//

    

    

    
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

