//
//  KKConnectViewController.m
//  MultipeerDemo
//
//  Created by mikewang on 14/10/22.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//


#import "KKConnectViewController.h"

@interface KKConnectViewController () <UITableViewDelegate,UITableViewDataSource,MCNearbyServiceBrowserDelegate,MCSessionDelegate,MCNearbyServiceAdvertiserDelegate>

@property (nonatomic, strong) MCNearbyServiceBrowser *browser;

@property (nonatomic, assign) BOOL connecting;

@property (nonatomic,strong) UITableView *tvPeers;

@property (nonatomic,strong) NSMutableArray *arrNearbyPeers;

@property (nonatomic,strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic,strong) UITextView *txtvPeerDetail;

@property (nonatomic,strong) UIButton *btnConnectPeer;
@property (nonatomic,strong) UIButton *btnSendMsg;
@property (nonatomic,strong) UIButton *btnSendFile;

@property (nonatomic,strong) NSMutableDictionary *dicPeerForSelected;



@end

@implementation KKConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    CGFloat width=self.view.bounds.size.width;
    CGFloat height=self.view.bounds.size.height;
    
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];//指定进度轮的大小
    
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];//设置进度轮显示类型
    
    [self.view addSubview:activity];
    
    self.activityIndicatorView=activity;
    
    
    UIButton *btnClose=[UIButton buttonWithType:UIButtonTypeSystem];
    btnClose.frame=CGRectMake(40, 20, width-40, 40);
    [btnClose setTitle:@"Close" forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closeSelfView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnClose];
    
    
    self.tvPeers=[[UITableView alloc] initWithFrame:CGRectMake(10, 70, width-20, 120) style:UITableViewStylePlain];
    
    [self.tvPeers setDelegate:self];
    [self.tvPeers setDataSource:self];
    
    self.tvPeers.allowsMultipleSelection=NO;
    
    [self.view addSubview:self.tvPeers];
    
    
    
    self.txtvPeerDetail=[[UITextView alloc] initWithFrame:CGRectMake(10, self.tvPeers.frame.origin.y+self.tvPeers.frame.size.height+2, width-20, 100)];
    
    [self.view addSubview:self.txtvPeerDetail];
    
    CGRect frame =  self.txtvPeerDetail.frame;
    
    self.btnConnectPeer=[UIButton buttonWithType:UIButtonTypeSystem];
    self.btnConnectPeer.frame=CGRectMake(0, frame.origin.y+frame.size.height+4, width/3.0, 44);
    
    [self.btnConnectPeer addTarget:self action:@selector(connectPeer:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnConnectPeer setTitle:@"connect" forState:UIControlStateNormal];
    
    self.btnSendMsg=[UIButton buttonWithType:UIButtonTypeSystem];
    self.btnSendMsg.frame=CGRectMake(width/3.0, frame.origin.y+frame.size.height+4, width/3.0, 44);
    [self.btnSendMsg addTarget:self action:@selector(sendMsg:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnSendMsg setTitle:@"send msg" forState:UIControlStateNormal];
    
    self.btnSendFile=[UIButton buttonWithType:UIButtonTypeSystem];
    self.btnSendFile.frame=CGRectMake(2*width/3.0, frame.origin.y+frame.size.height+4, width/3.0, 44);
    [self.btnSendFile addTarget:self action:@selector(sendFile:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnSendFile setTitle:@"send file" forState:UIControlStateNormal];
    
    [self.view addSubview:self.btnConnectPeer];
    [self.view addSubview:self.btnSendMsg];
    [self.view addSubview:self.btnSendFile];
    
    
    
    //--
    self.view.backgroundColor=[UIColor whiteColor];
    
    self.arrNearbyPeers=[NSMutableArray array];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



- (void)setBrowsing:(BOOL)value {
    
    if (_browsing==value) {
        return;
    }
    
    
    if (self.browser==nil) {
        // Setup browser
        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:kServiceType];
        self.browser.delegate = self;
    }
    
    
    if (value) {
        
        [self.browser startBrowsingForPeers];
        NSLog(@"Started browsing...");
        //        self.lblConnectStatus.text=@"Started browsing...";
        
        [self.activityIndicatorView startAnimating];
        
    }
    else {
        [self.browser stopBrowsingForPeers];
        NSLog(@"Stopped browsing");
        
        [self.activityIndicatorView stopAnimating];
        
        //        self.lblConnectStatus.text=@"Stopped browsing...";
    }
    
    _browsing = value;
    
    
    
    
    // Update UI on main thread
    if ([NSThread isMainThread]) {
        //        self.browseSwitch.on = value;
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            //            self.browseSwitch.on = value;
        });
    }
}



- (void)closeSelfView:(id)sender
{
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                                 self.browsing=NO;
                                 
                                 [self.delegate dismissConnectViewController];
                             }];
}

-(void)setSession:(MCSession *)session
{
    _session=session;
    
    _session.delegate=self;
    
    [self.tvPeers reloadData];
}


- (void)setAdvertiser:(MCNearbyServiceAdvertiser *)advertiser
{
    _advertiser=advertiser;
    _advertiser.delegate=self;
}


-(NSInteger)countOfArrNearbyPeersWithStatus:(NSString *)status
{
    NSInteger i=0;
    
    i = [self arrNearbyPeersWithStatus:status].count;
    
    NSLog(@"countOfArrNearbyPeersWithStatus %@ = %d",status,i);
    
    return i;
    
}


-(NSMutableArray *)arrNearbyPeersWithStatus:(NSString *)status
{
    
    NSMutableArray *arr=[NSMutableArray array];
    
    for (NSMutableDictionary *dicPeer in self.arrNearbyPeers) {
        if ([[dicPeer objectForKey:@"status"] isEqualToString:status]) {
            [arr  addObject:dicPeer];
        }
    }
    
    return arr;
    
}

-(NSMutableDictionary *)nearbyPeerFromArrWithPeerID:(MCPeerID *)peerID
{
    
    NSMutableDictionary *dicPeerSelected;
    
    for (NSMutableDictionary *dicPeer in self.arrNearbyPeers) {
        if ([dicPeer objectForKey:@"peerID"] == peerID) {
            dicPeerSelected=dicPeer;
            break;
        }
    }
    
    return dicPeerSelected;
    
}



#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section==0) {
        return [self countOfArrNearbyPeersWithStatus:@"connected"];
    }
    
    if (section==1) {
        return [self countOfArrNearbyPeersWithStatus:@"disconnect"];
    }
    
    if (section==2) {
        return [self countOfArrNearbyPeersWithStatus:@"connecting"];
    }
    
    
    return 0;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    NSInteger section=indexPath.section;
    
    NSString *status;
    
    if (section==0) {
        
        status=@"connected";
        
        cell.textLabel.textColor=[UIColor redColor];
    }
    
    if (section==1) {
        status=@"disconnect";
        cell.textLabel.textColor=[UIColor blackColor];
    }
    
    if (section==2) {
        status=@"connecting";
        
        cell.textLabel.textColor=[UIColor blueColor];
    }
    
    
    NSMutableDictionary *dicPeer = [[self arrNearbyPeersWithStatus:status] objectAtIndex:indexPath.row];
    
    MCPeerID *peerID=[dicPeer  objectForKey:@"peerID"];
    
    cell.textLabel.text = [peerID.displayName stringByAppendingFormat:@" %@",status];
    
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section=indexPath.section;
    
    NSString *status;
    
    if (section==0) {
        
        status=@"connected";
    }
    
    if (section==1) {
        status=@"disconnect";
    }
    
    if (section==2) {
        status=@"connecting";
    }
    
    
    NSMutableDictionary *dicPeer = [[self arrNearbyPeersWithStatus:status] objectAtIndex:indexPath.row];
    
    self.dicPeerForSelected=dicPeer;
    
    
    if (section==0) {
//        [self sendMessageToPeers:@[peerID]];
    }
    
    if (section==1) {
       
    }
    
    if (section==2) {
        
        
    }
    
    NSLog(@"info is \n %@",[dicPeer objectForKey:@"info"]);
    

    
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:[dicPeer objectForKey:@"info"] options:NSJSONWritingPrettyPrinted error:&parseError];
   
    self.txtvPeerDetail.text= [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
//    [tableView cellForRowAtIndexPath:indexPath].backgroundColor=[UIColor grayColor];
    
}




-(void)connectPeer:(id)sender
{


    if (self.dicPeerForSelected) {
        MCPeerID *peerID=[self.dicPeerForSelected objectForKey:@"peerID"];
        
        if (peerID) {
            [self inviteFoundPeerID:peerID withAuto:NO];
        }
    }
}


-(void)sendMsg:(id)sender
{
    
    if (self.dicPeerForSelected) {
        MCPeerID *peerID=[self.dicPeerForSelected objectForKey:@"peerID"];
        
        if (peerID) {
            [self sendMessageToPeers:@[peerID]];
        }
    }
}

-(void)sendFile:(id)sender
{
    
    if (self.dicPeerForSelected) {
        MCPeerID *peerID=[self.dicPeerForSelected objectForKey:@"peerID"];
        
        if (peerID) {
            [self sendMessageToPeers:@[peerID]];
        }
    }
}



- (void)inviteFoundPeerID:(MCPeerID *)foundPeerID  withAuto:(BOOL)atype
{
    // Create session
    
    if (self.session==nil) {
        // Create session
        self.session = [[MCSession alloc] initWithPeer:self.peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        self.session.delegate = self;
    }
    
    if ([self.session.connectedPeers containsObject:foundPeerID]) {
        return;
    }
    
    
    NSData *context;
    
    if (atype) {
        
        NSMutableDictionary *contextInfo=  [NSMutableDictionary dictionaryWithDictionary:self.advertiser.discoveryInfo];
        
        [contextInfo setObject:@"y" forKey:@"auto"];
        
        context = [NSKeyedArchiver archivedDataWithRootObject:contextInfo];
    }
    else
    {
        context = [NSKeyedArchiver archivedDataWithRootObject:self.advertiser.discoveryInfo];
    }
    
    
    [self.browser invitePeer:foundPeerID toSession:self.session withContext:context timeout:30.0];
    
    self.connecting=YES;
    
    NSLog(@"peerID = %@",self.peerID.displayName);
    
    NSLog(@"initializeSession is self= %@",self);
    
}

-(void)setConnecting:(BOOL)connecting
{
    _connecting=connecting;
    
    // Update UI on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tvPeers reloadData];
    });
}




#pragma mark - MCNearbyServiceBrowserDelegate methods

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    NSLog(@"FoundPeer: %@, %@", peerID.displayName, info);
    
    NSMutableDictionary *dicPeer=[NSMutableDictionary dictionaryWithDictionary:@{@"peerID":peerID,@"info":info,@"status":@"disconnect"}];
    
    
    if ([self.arrNearbyPeers containsObject:dicPeer]) {
        NSLog(@"twice FoundPeer: %@, %@", peerID.displayName, info);
    }
    else
    {
        [self.arrNearbyPeers addObject:dicPeer];
    }
    
    // Update UI on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tvPeers reloadData];
    });
    
    //
    //    self.lblConnectStatus.text=[NSString stringWithFormat:@"browser FoundPeer: %@",peerID.displayName];
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"LostPeer: %@", peerID.displayName);
    

    // 可以删除掉发现的 peer
    
    [self.arrNearbyPeers removeObject:[self nearbyPeerFromArrWithPeerID:peerID]];
    
    // Update UI on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tvPeers reloadData];
    });
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    //    self.lblConnectStatus.text=@"browser didNotStartBrowsingForPeers";
}





#pragma mark - MCSessionDelegate methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    //    NSLog(@"%@: %@", [self stringForPeerConnectionState:state], peerID.displayName);
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        NSString *txt=[NSString stringWithFormat:@"%@ %@",[self stringForPeerConnectionState:state],peerID.displayName];
        //        self.lblConnectStatus.text=txt;
    });
    
    NSLog(@"session is %@",session);
    NSLog(@"self.session is %@",self.session);
    
    
    NSMutableDictionary *dicPeer=[self nearbyPeerFromArrWithPeerID:peerID];
    
    
    if (state==MCSessionStateConnecting) {
        NSLog(@"MCSessionDelegate Connecting");
        
        self.connecting=YES;
        
        [dicPeer setObject:@"connecting" forKey:@"status"];
        
    }
    else if (state == MCSessionStateConnected){
        NSLog(@"MCSessionDelegate Connected");
        
        self.browsing=NO;
        
        self.connecting=NO;
        
        [dicPeer setObject:@"connected" forKey:@"status"];
        
        
        
    }else if (state == MCSessionStateNotConnected){
        
        NSLog(@"MCSessionDelegate Disconnected");
        
        [session cancelConnectPeer:peerID];
        
        [dicPeer setObject:@"disconnect" forKey:@"status"];
        
        self.connecting=NO;
    }
    
    // Update UI on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tvPeers reloadData];
    });
}


#pragma mark - found devices methods

- (void)sendMessageToPeers:(NSArray *)peerIDs
{
    NSError *error;
    
    NSData *msgData = [@"Hello there!" dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.session sendData:msgData toPeers:peerIDs withMode:MCSessionSendDataReliable error:&error];
    
    if (error)
        NSLog(@"SendData error: %@", error);
    else
        NSLog(@"Sent message");
    
}



- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    // Decode the incoming data to a UTF8 encoded string
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"From %@: %@", peerID.displayName, msg);
    
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = data;
    NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if ([receivedText isEqualToString:@"K"]) {
            //            self.lblReceivedMsg.text = [NSString stringWithFormat:@"%f : heartbeat %@", [[NSDate date] timeIntervalSince1970],peerDisplayName];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: peerDisplayName
                                                           message: [[NSString alloc] initWithFormat:@"%@", receivedText]
                                                          delegate: nil
                                                 cancelButtonTitle:@"Got it"
                                                 otherButtonTitles:nil];
            [alert show];
        }
        
    });
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
    });
}



- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    NSLog(@"%s Resource: %@, Peer: %@, Progress %@", __PRETTY_FUNCTION__, resourceName, peerID.displayName, progress);
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    if (error) {
        NSLog(@"%s Peer: %@, Resource: %@, Error: %@", __PRETTY_FUNCTION__, peerID.displayName, resourceName, [error localizedDescription]);
    }
    else {
        NSLog(@"%s Peer: %@, Resource: %@ complete", __PRETTY_FUNCTION__, peerID.displayName, resourceName);
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    NSLog(@"%s Peer: %@, Stream: %@", __PRETTY_FUNCTION__, peerID.displayName, streamName);
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)cert fromPeer:(MCPeerID *)peerID certificateHandler:(void(^)(BOOL accept))certHandler {
    NSLog(@"%s Peer: %@", __PRETTY_FUNCTION__, peerID.displayName);
    certHandler(YES);
}




- (NSString *)stringForPeerConnectionState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnected:
            return @"Connected";
            break;
            
        case MCSessionStateConnecting:
            return @"Connecting";
            break;
            
        case MCSessionStateNotConnected:
            return @"Disconnected";
            break;
    }
}




#pragma mark - MCNearbyServiceAdvertiserDelegate methods

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)remotePeerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler {
    
    
    //只建立单向连接，不建立双向连接。
    
    if ([self.session.connectedPeers containsObject:remotePeerID]) {
        invitationHandler(NO,self.session);
        return;
    }
    
    
    NSDictionary *dicContext=[NSKeyedUnarchiver unarchiveObjectWithData:context];
    
    NSLog(@"Invitation from: %@, info=%@", remotePeerID.displayName, dicContext);
    
    NSDictionary *dicDevice=@{@"peername":remotePeerID.displayName,@"devname":[dicContext objectForKey:@"devname"],@"uuid":[dicContext objectForKey:@"uuid"]};
    
    
    if (self.session==nil) {
        // Create session
        self.session = [[MCSession alloc] initWithPeer:self.peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        // self.session.delegate = self;
        NSLog(@"create Session  %@",self.session);
    }
    
    
    
    NSString *title=[NSString stringWithFormat:NSLocalizedString(@"Received Invitation from %@", @"Received Invitation from {Peer}"), remotePeerID.displayName];
    
    
    
    NSLog(@"Invitation from: %@ the end.", remotePeerID.displayName);
    
    
    //-----
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
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
                                      invitationHandler(NO,self.session);
                                      
                                      self.session=nil;
                                      
                                  }];
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Accept", @"Accept action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"Accept action");
                                   invitationHandler(YES,self.session);
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:resetAction];
    [alertController addAction:okAction];
    
    
    
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        //        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        [alert show];
        
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        
    });
    
    
    return;
    
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    
}




@end
