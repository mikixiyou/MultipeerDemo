//
//  KKConnectViewController.m
//  MultipeerDemo
//
//  Created by mikewang on 14/10/22.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//


#import "KKConnectViewController.h"


@interface KKConnectViewController () <UITableViewDelegate,UITableViewDataSource,MCNearbyServiceBrowserDelegate,MCSessionDelegate,MCNearbyServiceAdvertiserDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSStreamDelegate>

@property (nonatomic, strong) MCNearbyServiceBrowser *browser;

@property (nonatomic, assign) BOOL connecting;

@property (nonatomic,strong) UITableView *tvPeers;

@property (nonatomic,strong) NSMutableArray *arrNearbyPeers;

@property (nonatomic,strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic,strong) UITextView *txvPeerDetail;

@property (nonatomic,strong) UIProgressView *progressViewFileSend;



@property (nonatomic,strong) UITextField *fieldMsg;

@property (nonatomic,strong) UIButton *btnSendPhoto;
@property (nonatomic,strong) UIButton *btnSendFile;

@property (nonatomic,strong) NSMutableDictionary *dicSelectedPeer;

@property (nonatomic,strong) NSMutableData *streamData;

@property (nonatomic,strong) NSDecimalNumber *bytesRead;


@property (nonatomic,strong) NSOutputStream *outputStreamer;

@property (nonatomic,strong) NSInputStream  *inputStreamer;



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
    
    
    
    self.txvPeerDetail=[[UITextView alloc] initWithFrame:CGRectMake(10, self.tvPeers.frame.origin.y+self.tvPeers.frame.size.height+2, width-20, 300)];
    
    [self.view addSubview:self.txvPeerDetail];
    
    CGRect frame =  self.txvPeerDetail.frame;

    UIProgressView *progressView=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressView.frame=CGRectMake(0, frame.origin.y+frame.size.height+1, width, 2);
    
    self.progressViewFileSend=progressView;
    [self.view addSubview:self.progressViewFileSend];
    
    
    UITextField *fieldMsg=[[UITextField alloc] initWithFrame:CGRectMake(3, frame.origin.y+frame.size.height+4, width-106, 40)];
    fieldMsg.delegate=self;
    fieldMsg.borderStyle=UITextBorderStyleRoundedRect;
    fieldMsg.returnKeyType=UIReturnKeyDone;
    
    self.btnSendPhoto=[UIButton buttonWithType:UIButtonTypeSystem];
    self.btnSendPhoto.frame=CGRectMake(width-100, frame.origin.y+frame.size.height+4, 50, 44);
    [self.btnSendPhoto addTarget:self action:@selector(sendPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnSendPhoto setTitle:@"Photo" forState:UIControlStateNormal];
    
    self.btnSendFile=[UIButton buttonWithType:UIButtonTypeSystem];
    self.btnSendFile.frame=CGRectMake(width-50, frame.origin.y+frame.size.height+4, 50, 44);
    [self.btnSendFile addTarget:self action:@selector(sendFile:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnSendFile setTitle:@"File" forState:UIControlStateNormal];
    

    [self.view addSubview:self.btnSendPhoto];
    
    [self.view addSubview:self.btnSendFile];
    
    [self.view addSubview:fieldMsg];
    
    self.fieldMsg=fieldMsg;
    
    
    //--
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.arrNearbyPeers = [NSMutableArray array];
    
    self.dicSelectedPeer = nil;
    
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

-(NSMutableDictionary *)peerOfArrNearbyPeersWithPeerID:(MCPeerID *)peerID
{
    
    NSMutableDictionary *dicSelectedPeer;
    
    for (NSMutableDictionary *dicPeer in self.arrNearbyPeers) {
        
        MCPeerID *tempPeerID=[dicPeer objectForKey:@"peerID"];
        
        if ( [tempPeerID.displayName isEqualToString:peerID.displayName]) {
            dicSelectedPeer=dicPeer;
            break;
        }
    }
    
    return dicSelectedPeer;
    
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
    
    cell.textLabel.text = [[[dicPeer objectForKey:@"info"] objectForKey:@"nickname"] stringByAppendingFormat:@" %@",status];
    
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
    
    self.dicSelectedPeer=dicPeer;
    
    
    if (section==0) {
//        [self sendMessageToPeers:@[peerID]];
    }
    
    if (section==1) {
        
        [self connectPeer:self];
       
    }
    
    if (section==2) {
        
        
    }
    
    NSLog(@"info is \n %@",[dicPeer objectForKey:@"info"]);
    

    
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:[dicPeer objectForKey:@"info"] options:NSJSONWritingPrettyPrinted error:&parseError];
   
    self.txvPeerDetail.text= [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
//    [tableView cellForRowAtIndexPath:indexPath].backgroundColor=[UIColor grayColor];
    
}




-(void)connectPeer:(id)sender
{
    if (self.dicSelectedPeer) {
        MCPeerID *peerID=[self.dicSelectedPeer objectForKey:@"peerID"];
        
        if (peerID) {
            [self inviteFoundPeerID:peerID withAuto:NO];
        }
    }
}


-(void)sendFile:(id)sender
{
    
    if (self.dicSelectedPeer) {
        MCPeerID *peerID=[self.dicSelectedPeer objectForKey:@"peerID"];
        
        if (peerID) {
           
//            [self sendMessageToPeers:@[peerID]];
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = NO;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
                [self presentViewController:picker animated:YES completion:^{
                    nil;
                    
                    
                    
                }];
                
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"访问图片库错误"
                                      message:@""
                                      delegate:nil
                                      cancelButtonTitle:@"OK!"
                                      otherButtonTitles:nil];
                [alert show];
                
            }

        }
    }
}

-(void)sendPhoto:(id)sender
{
    
    if (self.dicSelectedPeer) {
        MCPeerID *peerID=[self.dicSelectedPeer objectForKey:@"peerID"];
        
        if (peerID) {
//            [self sendMessageToPeers:@[peerID]];
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
                [self presentViewController:picker animated:YES completion:^{
                    nil;
                    
                    
                    
                }];
  
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"访问图片库错误"
                                      message:@""
                                      delegate:nil
                                      cancelButtonTitle:@"OK!"
                                      otherButtonTitles:nil];
                [alert show];

            }
        }
    }
}


//再调用以下委托：
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //imageView.image = image; //imageView为自己定义的UIImageView
    
    if (picker.allowsEditing) {
        [picker dismissViewControllerAnimated:YES completion:^{
            
            // Don't block the UI when writing the image to documents
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                // We only handle a still image
                UIImage *imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
                
                // Save the new image to the documents directory
                NSData *pngData = UIImageJPEGRepresentation(imageToSave, 1.0);
                
                // Create a unique file name
                NSDateFormatter *inFormat = [NSDateFormatter new];
                [inFormat setDateFormat:@"yyMMdd-HHmmss"];
                NSString *imageName = [NSString stringWithFormat:@"image-%@.JPG", [inFormat stringFromDate:[NSDate date]]];
                // Create a file path to our documents directory
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
                
                NSInputStream *inputStreamForFile = [NSInputStream inputStreamWithFileAtPath:filePath];
                
                
                
                [pngData writeToFile:filePath atomically:YES]; // Write the file
                // Get a URL for this file resource
                NSURL *imageUrl = [NSURL fileURLWithPath:filePath];
                
                MCPeerID *peer=[self.dicSelectedPeer objectForKey:@"peerID"];
                
                [self.session sendResourceAtURL:imageUrl withName:imageName toPeer:peer withCompletionHandler:^(NSError *error) {
                    if (error) {
                        NSLog(@"Failed to send picture to %@, %@", peer.displayName, error.localizedDescription);
                        return;
                    }
                    NSLog(@"Sent picture to %@", peer.displayName);
                    //Clean up the temp file
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager removeItemAtURL:imageUrl error:nil];
                }];
            });
            
            
            
        }];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:^{
            
            // Don't block the UI when writing the image to documents
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                MCPeerID *peer=[self.dicSelectedPeer objectForKey:@"peerID"];
                
                NSError *error;
                
                self.outputStreamer = [self.session startStreamWithName:@"music" toPeer:peer error:&error];
                
                self.outputStreamer.delegate=self;
                
                if (error) {
                    NSLog(@"Error: %@", [error userInfo].description);
                }
                else
                {
                    
                    [self.outputStreamer scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                    
                    [self.outputStreamer open];
                    
                }
                
                
                
                
                // We only handle a still image
                UIImage *imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
                
                // Save the new image to the documents directory
                NSData *pngData = UIImageJPEGRepresentation(imageToSave, 1.0);
                
                // Create a unique file name
                NSDateFormatter *inFormat = [NSDateFormatter new];
                [inFormat setDateFormat:@"yyMMdd-HHmmss"];
                NSString *imageName = [NSString stringWithFormat:@"image-%@.JPG", [inFormat stringFromDate:[NSDate date]]];
                // Create a file path to our documents directory
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
                
                
                NSData *newData = UIImagePNGRepresentation([UIImage imageNamed:imageName]);
                
                newData=pngData;
                
                
                int index = 0;
                int totalLen = [newData length];
                uint8_t buffer[1024];
                uint8_t *readBytes = (uint8_t *)[newData bytes];
                
                while (index < totalLen) {
                    if ([self.outputStreamer hasSpaceAvailable]) {
                        int indexLen =  (1024>(totalLen-index))?(totalLen-index):1024;
                        
                        (void)memcpy(buffer, readBytes, indexLen);
                        
                        int written = [self.outputStreamer write:buffer maxLength:indexLen];
                        
                        if (written < 0) {
                            break;
                        }
                        
                        index += written;
                        
                        readBytes += written;
                    }
                }
                
                
                
                NSLog(@"self.outputStreamer.streamStatus is %u",self.outputStreamer.streamStatus);

                
            });
            
      
            
            
            
        }];
    
        
    }

    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{

    [picker dismissViewControllerAnimated:YES completion:^{
        nil;
    }];

}



#pragma mark - found devices methods

- (void)sendMessage:(NSString *)message toPeers:(NSArray *)peerIDs
{
    NSError *error;
    
    NSData *msgData = [@"Hello there!" dataUsingEncoding:NSUTF8StringEncoding];
    
    if (message) {
        msgData = [message dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    [self.session sendData:msgData toPeers:peerIDs withMode:MCSessionSendDataReliable error:&error];
    
    if (error)
        NSLog(@"SendData error: %@", error);
    else
        NSLog(@"Sent message");
    
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


-(void)setDicPeerForSelected:(NSMutableDictionary *)dicSelectedPeer
{
    _dicSelectedPeer=dicSelectedPeer;
    
    if (dicSelectedPeer) {
        self.fieldMsg.enabled=YES;
        self.btnSendPhoto.enabled=YES;
        self.btnSendFile.enabled=YES;
    }
    else
    {
        self.fieldMsg.enabled=NO;
        self.btnSendPhoto.enabled=NO;
        self.btnSendFile.enabled=NO;
    }
    
}





#pragma mark - MCNearbyServiceBrowserDelegate methods

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    NSLog(@"FoundPeer: %@, %@", peerID.displayName, info);
    
    
    BOOL existed=NO;
    
    for (NSMutableDictionary *dic in self.arrNearbyPeers) {
        MCPeerID *tempPeerID=[dic objectForKey:@"peerID"];
        if ([peerID.displayName isEqualToString:tempPeerID.displayName]) {
            
            [dic setObject:peerID forKey:@"peerID"];
            [dic setObject:info forKey:@"info"];
            
            NSString *status=[dic objectForKey:@"status"];
            
//            [dic setObject:@"disconnect" forKey:@"status"];
            
            existed=YES;
            break;
        }

    }
    
    
    if (!existed) {
        
        NSMutableDictionary *dicPeer=[NSMutableDictionary dictionaryWithDictionary:@{@"peerID":peerID,@"info":info,@"status":@"disconnect"}];
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
    
    [self.arrNearbyPeers removeObject:[self peerOfArrNearbyPeersWithPeerID:peerID]];
    
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
    
    
    NSMutableDictionary *dicPeer=[self peerOfArrNearbyPeersWithPeerID:peerID];
    
    
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





- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    // Decode the incoming data to a UTF8 encoded string
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"From %@: %@", peerID.displayName, msg);
    
    NSString *peerDisplayName = [[[self peerOfArrNearbyPeersWithPeerID:peerID] objectForKey:@"info"] objectForKey:@"nickname"];
    
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
//            [alert show];
            
            
            NSString *message=[@"\n" stringByAppendingFormat:@"%@:%@",peerDisplayName,receivedText];
            
            self.txvPeerDetail.text=[self.txvPeerDetail.text stringByAppendingString:message];
            
        }
        
    });
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
    });
}



- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    NSLog(@"%s Resource: %@, Peer: %@, Progress %@", __PRETTY_FUNCTION__, resourceName, peerID.displayName, progress);
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.progressViewFileSend.progress=progress.fractionCompleted;
    });
    

    
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    if (error) {
        NSLog(@"%s Peer: %@, Resource: %@, Error: %@", __PRETTY_FUNCTION__, peerID.displayName, resourceName, [error localizedDescription]);
    }
    else {
        NSLog(@"%s Peer: %@, Resource: %@ complete %@", __PRETTY_FUNCTION__, peerID.displayName, resourceName,[localURL absoluteString]);
 
        UIImage *image=[UIImage imageWithData:[NSData dataWithContentsOfURL:localURL]];
        
        if (image) {
             UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果is nill"
                                      
                                                                message:@"nil image"
                                      
                                                               delegate:self
                                      
                                                      cancelButtonTitle:@"确定"
                                      
                                                      otherButtonTitles:nil];
                
                [alert show];
            });
            

        }
        
       
        

    }
}






- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo

{
    
    NSString *msg = nil;
    
    if(error != NULL)
        
    {
        
        msg = @"保存图片失败";
        
    }
    
    else
        
    {
        
        msg = @"保存图片成功";
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                              
                                                        message:msg
                              
                                                       delegate:self
                              
                                              cancelButtonTitle:@"确定"
                              
                                              otherButtonTitles:nil];
        
        [alert show];
    });
    

}





- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    NSLog(@"%s Peer: %@, Stream: %@", __PRETTY_FUNCTION__, peerID.displayName, streamName);
    
    
    self.inputStreamer=stream;
    
    // Start receiving data
    self.inputStreamer.delegate = self;
    
    [self.inputStreamer scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStreamer open];

    
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    if (aStream == self.outputStreamer) {
        
        if (eventCode == NSStreamEventHasBytesAvailable) {
            // handle incoming data
            if(!_streamData) {
                _streamData = [NSMutableData data];
            }
            
            if (!_bytesRead) {
                _bytesRead=[NSDecimalNumber decimalNumberWithString:@"0"];
            }
            
            uint8_t buf[1024];
            unsigned int len = 0;
            len = [(NSInputStream *)aStream read:buf maxLength:1024];
            if(len) {
                [_streamData appendBytes:(const void *)buf length:len];
                // bytesRead is an instance variable of type NSNumber.
                [self.bytesRead decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%d",len]]];
                
            } else {
                NSLog(@"no buffer!");
            }
            
            NSLog(@"self.bytesRead is %d",[self.bytesRead integerValue]);
            
            
        } else if (eventCode == NSStreamEventEndEncountered) {
            // notify application that stream has ended
            
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
            //        [aStream release];
            aStream = nil; // stream is ivar, so reinit it
            _bytesRead=nil;
            _streamData=nil;
            
            
            
        } else if (eventCode == NSStreamEventErrorOccurred) {
            // notify application that stream has encountered and error
        }
        
    }
    else if (aStream == self.inputStreamer)
    {
    
        
        if (eventCode == NSStreamEventHasBytesAvailable) {
            // handle incoming data
            if(!_streamData) {
                _streamData = [NSMutableData data];
            }
            
            if (!_bytesRead) {
                _bytesRead=[NSDecimalNumber decimalNumberWithString:@"0"];
            }
            
            uint8_t buf[1024];
            unsigned int len = 0;
            len = [(NSInputStream *)aStream read:buf maxLength:1024];
            if(len) {
                [_streamData appendBytes:(const void *)buf length:len];
                // bytesRead is an instance variable of type NSNumber.
                [self.bytesRead decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%d",len]]];
                
            } else {
                NSLog(@"no buffer!");
            }
            
            NSLog(@"self.bytesRead is %d",[self.bytesRead integerValue]);
            
            
        } else if (eventCode == NSStreamEventEndEncountered) {
            // notify application that stream has ended
            
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
            //        [aStream release];
            aStream = nil; // stream is ivar, so reinit it
            _bytesRead=nil;
            _streamData=nil;
            
            
            
        } else if (eventCode == NSStreamEventErrorOccurred) {
            // notify application that stream has encountered and error
        }
        
    }
    

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
    
    NSDictionary *dicDevice=@{@"uuid":remotePeerID.displayName,@"devname":[dicContext objectForKey:@"devname"],@"nickname":[dicContext objectForKey:@"nickname"]};
    
    
    if (self.session==nil) {
        // Create session
        self.session = [[MCSession alloc] initWithPeer:self.peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        // self.session.delegate = self;
        NSLog(@"create Session  %@",self.session);
    }
    
    
    
    NSString *title=[NSString stringWithFormat:NSLocalizedString(@"Received Invitation from %@", @"Received Invitation from {Peer}"), [dicContext objectForKey:@"nickname"]];
    
    
    
    NSLog(@"Invitation from: %@ the end.", [dicContext objectForKey:@"nickname"]);
    
    
    //-----
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    
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



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    
    if (self.dicSelectedPeer) {
        
        MCPeerID *selectedPeerID=[self.dicSelectedPeer objectForKey:@"peerID"];
        
        if (selectedPeerID) {
            
            [self sendMessage:textField.text toPeers:@[selectedPeerID]];
            
            NSString *peerDisplayName = [self.advertiser.discoveryInfo objectForKey:@"nickname"];
            
            NSString *message=[@"\n" stringByAppendingFormat:@"%@:%@",peerDisplayName,textField.text];
            
            self.txvPeerDetail.text=[self.txvPeerDetail.text stringByAppendingString:message];
            
        }
    }
    
    textField.text=nil;
    
    return YES;
    
    
}


@end
