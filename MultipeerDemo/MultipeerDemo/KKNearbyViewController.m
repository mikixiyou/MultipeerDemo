//
//  KKNearbyViewController.m
//  MultipeerDemo
//
//  Created by mikewang on 14/10/28.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import "KKNearbyViewController.h"

#import "KKNearbyAlertView.h"

#import <sys/utsname.h>

#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "KKNearbyPeer.h"

#import "KKMessageCell.h"




static NSString * const kServiceType = @"KKNearbyService";

@interface KKNearbyViewController () <UIAlertViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,MCNearbyServiceBrowserDelegate,MCSessionDelegate,MCNearbyServiceAdvertiserDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSStreamDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate,UITextViewDelegate>
{
    NSMutableData *_incomingDataBuffer;
    unsigned long totalBytesRead;
    
    NSData *_outgoingDataBuffer;
    
    unsigned long totalBytesWritten;
    
}
#pragma mark display

@property (nonatomic,strong) NSString *accountOwner;

@property (nonatomic,strong) UINavigationItem *navigationItemHeader;

@property (nonatomic,strong) UITextField *textFieldAccountOwner;

@property (nonatomic,strong)  UIProgressView *progressBar;


@property (nonatomic,strong)  UIScrollView *peersView;

@property (nonatomic,strong)  UIActivityIndicatorView *indicatorBrowsing;

@property (nonatomic,strong)  UISwitch *switchBrowsing;


@property (nonatomic,strong)  UITableView *tableViewPeers;

@property (nonatomic,strong)  NSMutableArray *arrPeers;



@property (nonatomic,strong)  UIView *talkingView;

@property (nonatomic,strong)  UICollectionView *talkingMessageView;
@property (nonatomic,strong)  NSMutableArray *arrMessages;

@property (nonatomic,strong)  UIView *talkingToolView;


@property (nonatomic,strong)  UITextView *textViewMessage;

@property (nonatomic,strong)  UIButton *btnSendData;
@property (nonatomic,strong)  UIButton *btnSendResource;
@property (nonatomic,strong)  UIButton *btnSendStream;

@property (nonatomic,strong) UIImagePickerController *pickerResource;
@property (nonatomic,strong) UIImagePickerController *pickerStream;



@property (nonatomic,strong)  NSProgress *progressResourceSent;

@property (nonatomic,strong)  NSProgress *progressResourceReceived;


@property (nonatomic,strong) NSOutputStream *streamOutput;

@property (nonatomic,strong) NSInputStream *streamInput;


@property (nonatomic)  BOOL keyboardShown;

@property (nonatomic,strong)  id firstResponderObject;

@property (nonatomic,strong)  UITapGestureRecognizer *tapGestureOnTalkingMessageView;

// message,device 需要定义类，model

#pragma mark nearby

@property (nonatomic, strong) MCPeerID *peerID;

@property (nonatomic, strong) MCNearbyServiceBrowser *browser;

@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@property (nonatomic, strong) MCSession *session;

@property (nonatomic, assign) BOOL browsing;

@property (nonatomic, assign) BOOL advertising;


//-- dialog display flag
@property (nonatomic, strong) KKNearbyPeer *dialogPeer;

@property (nonatomic, strong) NSTimer *heartbeatTimer;


@end

@implementation KKNearbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configHeaderBar];
    
    [self configPeersView];
    
    [self configTalkingMessageViewToolView];
    
    [self keyboardSetNotification:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotifySetFirstResponder:) name:@"Notify_FirstResponder" object:nil];

}

-(void)dealloc
{
    
    [self keyboardSetNotification:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:@"Notify_FirstResponder" object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)configHeaderBar
{
    UINavigationBar *headerBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    
    CGRect  headerFrame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        headerFrame = CGRectMake(0, 0, self.view.frame.size.width, 64);
    }
    
    headerBar.frame = headerFrame;
    //    self.headerBar.barTintColor=[UIColor colorWithHexString:@"eeeeee"];
    
    
    // 创建一个导航栏集合
    UINavigationItem *navigationItemHeader = [[UINavigationItem alloc] initWithTitle:nil];
    
    // 创建一个左边按钮
    
    UIImage *backImage = [UIImage imageNamed:@"shock"];
    UIBarButtonItem *btnItemBack = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStyleDone target:self action:@selector(backToUpperView:)];
    
    UIBarButtonItem *btnItemBrowse=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(browseNearbyPeer:)];
    
    navigationItemHeader.leftBarButtonItems = @[btnItemBack];
    
    navigationItemHeader.rightBarButtonItems = @[btnItemBrowse];
    
    // 设置导航栏内容
    [navigationItemHeader setTitle:@""];
    
    [headerBar setItems:@[navigationItemHeader]];
    
    
    self.progressBar=[[UIProgressView alloc] initWithFrame:CGRectMake(0, 62, self.view.frame.size.width, 2)];
    [self.progressBar setProgressViewStyle:UIProgressViewStyleBar];
    
    [headerBar addSubview:self.progressBar];
    
    [self.view addSubview:headerBar];
    
    
    self.navigationItemHeader=navigationItemHeader;
    
}


-(void)configPeersView
{
    
    if (!self.arrPeers) {
        self.arrPeers=[NSMutableArray array];
    }
    
    
    CGFloat width=self.view.frame.size.width-6;

    CGRect frame=CGRectMake(3, 64+2, width, 44*4);
    
    UIScrollView *peersView=[[UIScrollView alloc] initWithFrame:frame];
    
    peersView.contentSize=frame.size;
    peersView.backgroundColor=[UIColor lightGrayColor];
    
    peersView.layer.borderWidth=0;
    peersView.layer.borderColor=[UIColor redColor].CGColor;
    
    GTMLoggerDebug(@"peersView frame is %@",NSStringFromCGRect(frame));
    
    UITableView *tableView=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.frame=CGRectMake(0, 0, width, 44*3);
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    tableView.separatorColor=[UIColor lightGrayColor];
    tableView.backgroundColor=[UIColor clearColor];
    
    CALayer *layer=tableView.layer;
    
//    layer.cornerRadius = 6.0f;
//    layer.borderWidth=1;
//    layer.borderColor=[UIColor lightGrayColor].CGColor;
//    layer.masksToBounds = YES;
    
    [peersView addSubview:tableView];
    
    
    
    UISwitch *switchBrowse=[[UISwitch alloc] initWithFrame:CGRectMake(30, tableView.frame.size.height+2, 100, 40)];
    [switchBrowse addTarget:self action:@selector(switchBrowseChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIActivityIndicatorView *indicatorBrowsing = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorBrowsing.frame=CGRectMake(tableView.frame.size.width-100, tableView.frame.size.height+2, 44, 44);
    
    [peersView addSubview:switchBrowse];
    [peersView addSubview:indicatorBrowsing];
    
    
    [self.view insertSubview:peersView belowSubview:[self.view.subviews firstObject]];
    
    
    self.switchBrowsing=switchBrowse;
    self.indicatorBrowsing=indicatorBrowsing;
    
    self.tableViewPeers=tableView;

    self.peersView=peersView;
    
    //
    self.peersView.frame=CGRectOffset(frame, 0, -frame.size.height);
}





-(void)configTalkingMessageViewToolView
{
    CGFloat width=self.view.frame.size.width;
    CGFloat height=self.view.frame.size.height;
    
    
    if (self.arrMessages==nil) {
        self.arrMessages=[NSMutableArray array];
    }
    
    
    
    UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumLineSpacing=10;
    
    CGFloat y=self.peersView.frame.origin.y+self.peersView.frame.size.height+2;
    
    UICollectionView *messageView=[[UICollectionView alloc] initWithFrame:CGRectMake(0,y, width,height-50-y) collectionViewLayout:layout];
    
    messageView.backgroundColor=[UIColor whiteColor];
    messageView.keyboardDismissMode=UIScrollViewKeyboardDismissModeInteractive;
    
    messageView.alwaysBounceVertical=YES;
    
    messageView.delegate = self;
    messageView.dataSource = self;
    
    [messageView registerClass:[KKMessageCell class] forCellWithReuseIdentifier:@"CollectionCell"];
    
    
    [self.view insertSubview:messageView belowSubview:self.peersView];
    
    self.talkingMessageView=messageView;
    
    
    UIView *toolView=[[UIView alloc] initWithFrame:CGRectMake(0, height-50, width, 50)];
   
    toolView.backgroundColor=[UIColor colorWithWhite:0.99 alpha:1];
    
    toolView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    toolView.layer.borderWidth=1;
    
    [self.view addSubview:toolView];
    
    UIButton *btnResource=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnResource.frame=CGRectMake(0, 0, 50, 50);
    [btnResource setTitle:@"Resource" forState:UIControlStateNormal];
    [btnResource addTarget:self action:@selector(sendResourceFile:) forControlEvents:UIControlEventTouchUpInside];

    
    UIButton *btnStream=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnStream.frame=CGRectMake(btnResource.frame.size.width, 0, 50, 50);
    
    [btnStream setTitle:@"Stream" forState:UIControlStateNormal];
    
    [btnStream addTarget:self action:@selector(sendStream:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat widthField=width-btnResource.frame.size.width-50;
    
    UITextField *textField1=[[UITextField alloc] initWithFrame:CGRectMake(width-widthField-50, 10, widthField, 30)];
    textField1.borderStyle=UITextBorderStyleRoundedRect;
    textField1.delegate=self;
    
    textField1.placeholder=@"Data";
    
    UITextView *textView=[[UITextView alloc] initWithFrame:CGRectMake(width-widthField-50, 5, widthField, 40)];
    textView.delegate=self;
    
    textView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    textView.layer.borderWidth=1;
    textView.layer.cornerRadius=4;
    
    textView.font=[UIFont systemFontOfSize:14];
    
    
    UIButton *btnData=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnData.frame=CGRectMake(width-50, 0, 50, 50);
    [btnData setTitle:@"Send" forState:UIControlStateNormal];
    [btnData addTarget:self action:@selector(sendData:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [toolView addSubview:btnResource];
//    [toolView addSubview:btnStream];
    
    [toolView addSubview:textView];
    
    [toolView addSubview:btnData];
    
    
    self.talkingToolView=toolView;
    
    self.btnSendResource=btnResource;
    self.btnSendStream=btnStream;
    
    
    self.textViewMessage=textView;
    
    self.btnSendData=btnData;
    
    
    //初始化
    self.textViewMessage.text=@"";
    [self textViewDidChange:self.textViewMessage];
    return;
    
}

-(void)switchBrowseChanged:(id)sender
{
    UISwitch *ss=(UISwitch *)sender;
    
    if (ss.isOn) {
        self.browsing = YES;
    }
    else {
        self.browsing = NO;
    }
}


-(void)configGestures
{
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponderFromTalking:)];
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    
    tapGesture.delaysTouchesBegan = YES;
    tapGesture.cancelsTouchesInView = YES;
    
    tapGesture.enabled=NO;
    
    [self.talkingMessageView addGestureRecognizer:tapGesture];
    
    self.tapGestureOnTalkingMessageView=tapGesture;
}



-(void)viewDidAppear:(BOOL)animated
{
    
    //    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"accountOwner"];
    
    self.accountOwner = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountOwner"];
    
    if (self.accountOwner==nil) {
        
        KKNearbyAlertView* dialog = [[KKNearbyAlertView alloc] initWithTitle:@"Enter Account Owner Name" message:@"One input, No changed" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Add",nil];
        
        [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
        
        self.textFieldAccountOwner=  [dialog textFieldAtIndex:0];
        self.textFieldAccountOwner.delegate=self;
        
        dialog.delegate=self;
        
        [dialog show];
        
        
    }
    
//    [self showPeersView:self];
    
}

-(void)browseNearbyPeer:(id)sender
{
    self.browsing=YES;

}

-(void)alertView:(KKNearbyAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if ([alertView isKindOfClass:[KKNearbyAlertView class]]) {
        if(buttonIndex == 0)
        {
            NSString *text=[[alertView textFieldAtIndex:0] text];
            GTMLoggerDebug(@"%@",text);
            
            if (text.length>0) {
                
                self.accountOwner=text; // need to trimming blank cell.
                
                alertView.dontDismiss=NO;
            }
            else
            {
                alertView.dontDismiss=YES;
            }
        }
    }
    
    
}



-(void)NotifySetFirstResponder:(NSNotification *)notify
{
    if ([[[notify userInfo] objectForKey:@"dml"] isEqualToString:@"add"]) {
        
        self.firstResponderObject=[notify object];
        
        if (self.firstResponderObject==self.textViewMessage) {

//            [UIView animateWithDuration:0.3 animations:^{
//                self.btnSendResource.frame=CGRectZero;
//                self.btnSendStream.frame=CGRectZero;
//                self.textFieldTalkingMessage.frame=CGRectMake(0, 10, self.view.frame.size.width-80, 30);
//                self.btnSendData.frame=CGRectMake(self.view.frame.size.width-80, 0, 80, 50);
//            }];
            
        }
        
        self.tapGestureOnTalkingMessageView.enabled=YES;
    }
    else
    {
        if (self.firstResponderObject==self.textViewMessage) {
//            [UIView animateWithDuration:0.3 animations:^{
//                self.btnSendResource.frame=CGRectMake(0, 0, 80, 50);
//                self.btnSendStream.frame=CGRectMake(80, 0, 80, 50);
//                self.textFieldTalkingMessage.frame=CGRectMake(160, 10, self.view.frame.size.width-160, 30);
//                self.btnSendData.frame=CGRectMake(self.view.frame.size.width, 0, 0, 50);
//            }];
        }
        
        self.firstResponderObject=nil;
        
        self.tapGestureOnTalkingMessageView.enabled=NO;
        
        
    }
    
    
    
    
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notify_FirstResponder" object:textField userInfo:@{@"dml":@"add"}];
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{

    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notify_FirstResponder" object:textField userInfo:@{@"dml":@"delete"}];
    

    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==self.textFieldAccountOwner) {
        if (textField.text.length>0) {
            return YES;
        }
        return NO;
    }

    
    return YES;
}



#pragma  mark expandingTextView delegate


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
    
//    heightContent=textRect.size.height;
    
//    if (textRect.size.height>14*2) {
//        textView.textContainerInset=UIEdgeInsetsMake(2, 0, 2, 0);
//    }
//    else
//    {
//        textView.textContainerInset=UIEdgeInsetsMake(8, 0, 8, 0);
//    }
    
//    heightContent=heightContent+textView.textContainerInset.top+textView.textContainerInset.bottom;
    
//    textView.textContainerInset=UIEdgeInsetsMake(0, 0, 0, 0);
    
    if (heightContent>=minHeight && heightContent<=maxHeight) {
        
        CGFloat heightOffset=heightContent - frame.size.height;
        
        if (heightOffset==0) {
            return;
        }
        
//        frame.origin.y=frame.origin.y - heightOffset;

        if (frame.size.height+heightOffset<minHeight) {
            return;
        }
        
        frame.size.height=frame.size.height+heightOffset;
        
        
        CGRect parentFrame = self.talkingToolView.frame;
        
        parentFrame.origin.y=parentFrame.origin.y - heightOffset;
        parentFrame.size.height=parentFrame.size.height + heightOffset;
        
        
//        self.btnSendResource=btnResource;
//        self.btnSendStream=btnStream;
//        
//        self.btnSendData=btnData;
        
        [UIView animateWithDuration:0.2 animations:^{
            textView.frame=frame;
            self.talkingToolView.frame=parentFrame;
//            self.btnSendResource.center=CGPointMake(self.btnSendResource.center.x, self.btnSendResource.center.y+heightOffset);
//            self.btnSendStream.center=CGPointMake(self.btnSendStream.center.x, self.btnSendStream.center.y+heightOffset);
//            self.btnSendData.center=CGPointMake(self.btnSendData.center.x, self.btnSendData.center.y+heightOffset);
            
            //
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

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
//    self.firstResponderObject=textView;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notify_FirstResponder" object:textView userInfo:@{@"dml":@"add"}];
    
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
//    self.firstResponderObject=textView;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
//    self.firstResponderObject=nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notify_FirstResponder" object:textView userInfo:@{@"dml":@"delete"}];
    
}




#pragma mark others



-(void)resignFirstResponderFromTalking:(UITapGestureRecognizer *)gesture
{
    
    [self.textViewMessage resignFirstResponder];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}



-(void)setAccountOwner:(NSString *)accountOwner
{
    if (accountOwner==nil) {
        return;
    }
    
    _accountOwner=accountOwner;
    
    
    NSString *owner=[[NSUserDefaults standardUserDefaults] objectForKey:@"accountOwner"];
    
    if ([owner isEqualToString:accountOwner]==NO) {
        [[NSUserDefaults standardUserDefaults] setObject:accountOwner forKey:@"accountOwner"];
    }
    
    [self.navigationItemHeader setTitle:accountOwner];
    
    [self configNearbyPeerServiceWithName:accountOwner];
    
    self.advertising=YES;
    
    self.browsing=YES;
}


-(void)backToUpperView:(id)sender
{
    
    [self dismissViewControllerAnimated:YES
                             completion:^{

                                 [self.delegate dismissNearbyViewController];
                                 
                                 self.browsing=NO;
                                 self.advertising=NO;
                                 self.arrPeers=[NSMutableArray array];
                             }];
    
}



#pragma  mark nearby session methods about data and message


-(void)heartbeatPeers:(BOOL)beat
{
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (beat) {
            
            if (self.heartbeatTimer==nil) {
                self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireHeartbeat) userInfo:nil repeats:YES];
            }
            
            [self.heartbeatTimer fire];
//            self.lblReceivedMsg.text=@"heartbeat running";
        }
        else
        {
            [self.heartbeatTimer invalidate];
            self.heartbeatTimer=nil;
            
//            self.lblReceivedMsg.text=@"heartbeat broken";
        }
    });
    
    
}


-(void)timerFireHeartbeat
{
    
    NSData *msgData = [@"K" dataUsingEncoding:NSUTF8StringEncoding];
    
    if (self.session.connectedPeers.count>0) {
        
        for (NSInteger i=0; i<self.session.connectedPeers.count; i++) {
            NSError *error;
            MCPeerID *peerID = [[self.session connectedPeers] objectAtIndex:i];
            [self.session sendData:msgData toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error];
        }
        
    }
    else
    {

        
    }
    
}



-(void)syncBusiData:(id)sender
{
    
}






-(void)sendResourceFile:(id)sender
{
    
    if (self.dialogPeer) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:picker animated:YES completion:^{
                self.pickerResource=picker;
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

-(void)sendStream:(id)sender
{
    
    if (self.dialogPeer) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:picker animated:YES completion:^{
                self.pickerStream=picker;
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




//再调用以下委托：
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if (picker == self.pickerResource) {
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
                
                
                [pngData writeToFile:filePath atomically:YES]; // Write the file
                // Get a URL for this file resource
                NSURL *imageUrl = [NSURL fileURLWithPath:filePath];
                
                //源头的传输文件进度 数据表
                self.progressResourceSent = [self.session sendResourceAtURL:imageUrl withName:imageName toPeer:self.dialogPeer.peerID withCompletionHandler:^(NSError *error) {
                    if (error) {
                        GTMLoggerDebug(@"Failed to send picture to %@, %@", self.dialogPeer.accountOwner, error.localizedDescription);
                        return;
                    }
                    GTMLoggerDebug(@"Sent picture to %@", self.dialogPeer.accountOwner);
                    //Clean up the temp file
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager removeItemAtURL:imageUrl error:nil];
                }];
                
                GTMLoggerDebug(@"progressResourceSent is   %@",self.progressResourceSent);
                
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.progressResourceSent addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
                });
                
            });
            
            
            
        }];
    }
    else{
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            // Don't block the UI when writing the image to documents
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                

                
            });
            
            
            
            // We only handle a still image
            UIImage *imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
            
            // Save the new image to the documents directory
            _outgoingDataBuffer = UIImageJPEGRepresentation(imageToSave, 1.0);
            
            NSString *streamLength= [[NSNumber numberWithInteger:_outgoingDataBuffer.length] stringValue];
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                [self.progressBar setProgress:0 animated:YES];
            });
            
            if (self.session.connectedPeers.count==0) {
                
                NSAssert(YES,@"self.streamOutput self.session.connectedPeers = 0");
           
                
                return ;
            }
            else
            {
                if ([self.session.connectedPeers containsObject:self.dialogPeer.peerID]==NO) {
                    NSAssert(YES,@"self.streamOutput self.session.connectedPeers not contain  dialogPeer.peerID");
                    
                    return ;
                    
                }
                
            }
            
            NSError *error;
            
            self.streamOutput = [self.session startStreamWithName:streamLength toPeer:self.dialogPeer.peerID error:&error];
            
            self.streamOutput.delegate=self;
            
            
            if (error) {
                GTMLoggerDebug(@"self.streamOutput Error: %@", [error userInfo].description);
                return;
            }
            
            [self.streamOutput scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            
            [self.streamOutput open];
            
            
            GTMLoggerDebug(@"self.streamOutput.streamStatus is %u",self.streamOutput.streamStatus);
            
            
        }];
        
        
        
        
    }
    
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
    
}



-(void)sendData:(id)sender
{
    UITextView *textView=self.textViewMessage;
    
    if (textView.text.length==0) return;
    
    
    
    // test bubble view begin
    [self.arrMessages addObject: @{@"accountOwner":self.accountOwner,@"source":@"local",@"type":@"message",@"text":textView.text,@"date":[NSDate date],@"status":@"ok"}];
    
    [self.talkingMessageView reloadData];
    
    
    textView.text=@"";
    [self textViewDidChange:textView];
    
    
    
    return;
    // end of test bubble view.
    
    if (self.dialogPeer) {
        [self sendMessage:textView.text toPeers:@[self.dialogPeer.peerID]];
        
        textView.text=@"";
        [self textViewDidChange:textView];
    }
    else
    {
        NSString *title=[@"Message " stringByAppendingString:@" Receiver Dismiss"];
        
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:title message:@"failure" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        
        textView.text=@"";
        [self textViewDidChange:textView];
    }
}
#pragma  mark keyboard notification center

// keyboard notification center

- (void)keyboardSetNotification:(Boolean)setting
{
    if (setting) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}

// The callback for frame-changing of keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (self.keyboardShown) {
        return;
    }
    
    
    GTMLoggerDebug(@"keyboardWillShow");
    
    GTMLoggerDebug(@"NSNotification is \n %@ \n %@", [notification object],[notification userInfo]);
    
    CGRect  keyboardScreenRect;
    CGRect  keyboardWindowRect;
    CGRect  keyboardViewFrame;
    
    // determine's keyboard height
    keyboardScreenRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardWindowRect = [self.view.window convertRect:keyboardScreenRect fromWindow:nil];
    keyboardViewFrame = [self.view convertRect:keyboardWindowRect fromView:nil];
    
    GTMLoggerDebug(@"keyboardScreenRect is %@", NSStringFromCGRect(keyboardScreenRect));
    GTMLoggerDebug(@"keyboardWindowRect is %@", NSStringFromCGRect(keyboardWindowRect));
    GTMLoggerDebug(@"keyboardFrame is %@", NSStringFromCGRect(keyboardViewFrame));
    
    //----
    
    GTMLoggerDebug(@"self.firstResponderObject is %@", self.firstResponderObject);
    
        UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    
//        id firstResponder = [mainWindow.rootViewController findFirstResponder];
    
        // 这是一个私有方法，会被apple拒绝掉的。
        UIView *firstResponder2 = [mainWindow performSelector:@selector(firstResponder)];
    
     GTMLoggerDebug(@" mainWindow firstResponderObject is %@", firstResponder2);
    
    if (self.firstResponderObject==self.textViewMessage) {
        
        CGRect frame=self.talkingToolView.frame;
        
        CGRect  keyboardFrameInTalkingView = [self.talkingView convertRect:keyboardWindowRect fromView:nil];
        
        GTMLoggerDebug(@"keyboardFrameInTalkingView is %@", NSStringFromCGRect(keyboardFrameInTalkingView));
        
        CGFloat originY= keyboardViewFrame.origin.y;
        
        CGRect offsetFrame=CGRectMake(0, originY-frame.size.height, frame.size.width, frame.size.height);
        
        
        NSDictionary* info = [notification userInfo];
        NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval duration = 0;
        duration=[number doubleValue];
        
        [UIView animateWithDuration:duration animations:^{
            self.talkingToolView.frame=offsetFrame;
        }
         completion:^(BOOL finished) {
                 self.keyboardShown=YES;
         }
         ];
        
        
        
    }
    else
    {
    
            self.keyboardShown=YES;
    }
    
    
    
    
    
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    GTMLoggerDebug(@"keyboardDidShow");
    
    CGRect  keyboardScreenRect;
    CGRect  keyboardWindowRect;
    CGRect  keyboardViewFrame;
    
    // determine's keyboard height
    keyboardScreenRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardWindowRect = [self.view.window convertRect:keyboardScreenRect fromWindow:nil];
    keyboardViewFrame = [self.view convertRect:keyboardWindowRect fromView:nil];
    
    GTMLoggerDebug(@"keyboardScreenRect is %@", NSStringFromCGRect(keyboardScreenRect));
    GTMLoggerDebug(@"keyboardWindowRect is %@", NSStringFromCGRect(keyboardWindowRect));
    GTMLoggerDebug(@"keyboardFrame is %@", NSStringFromCGRect(keyboardViewFrame));
    
}


- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    GTMLoggerDebug(@"keyboardDidChangeFrame");
    
    CGRect  keyboardScreenRect;
    CGRect  keyboardWindowRect;
    CGRect  keyboardViewFrame;
    
    // determine's keyboard height
    keyboardScreenRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardWindowRect = [self.view.window convertRect:keyboardScreenRect fromWindow:nil];
    keyboardViewFrame = [self.view convertRect:keyboardWindowRect fromView:nil];
    
    GTMLoggerDebug(@"keyboardScreenRect is %@", NSStringFromCGRect(keyboardScreenRect));
    GTMLoggerDebug(@"keyboardWindowRect is %@", NSStringFromCGRect(keyboardWindowRect));
    GTMLoggerDebug(@"keyboardFrame is %@", NSStringFromCGRect(keyboardViewFrame));
    
    /// scroll category view to display above of  keyboard
    
    if (self.keyboardShown == NO) {
        //避免二次 弹出 键盘
        return;
    }
    
    
    if (self.firstResponderObject==self.textViewMessage) {
        
        NSDictionary* info = [notification userInfo];
        NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval duration = 0;
        duration=[number doubleValue];
        
        CGRect frame=self.talkingToolView.frame;
        
        CGRect  keyboardFrameInTalkingView = [self.talkingView convertRect:keyboardWindowRect fromView:nil];
        
        GTMLoggerDebug(@"keyboardFrameInTalkingView is %@", NSStringFromCGRect(keyboardFrameInTalkingView));
        
        CGFloat originY= keyboardViewFrame.origin.y;
        
        CGRect offsetFrame=CGRectMake(0, originY-frame.size.height, frame.size.width, frame.size.height);
        
        
        [UIView animateWithDuration:duration animations:^{
            self.talkingToolView.frame=offsetFrame;
        }];
        
    }
    // end of which view will update frame.
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.keyboardShown == NO) {
        return;
    }
    
    self.keyboardShown = NO;
    
    GTMLoggerDebug(@"keyboardWillHide");
    
    //    self.appDelegate.keyboardFrameValue = [NSValue valueWithCGRect:keyboardViewRect];
    // 不取消这个设置。
    
    //    if (self.keyboardGridContentOffset.y!=0) {
    //         [self.gridContent setContentOffset:self.keyboardGridContentOffset animated:YES];
    //        self.keyboardGridContentOffset=CGPointMake(0, 0);
    //    }
    // 不能 滚动回去， 否则 editingcell 会 从内存中 消失，导致一系列错误。
    
    CGRect  keyboardScreenRect;
    CGRect  keyboardWindowRect;
    CGRect  keyboardViewFrame;
    
    // determine's keyboard height
    keyboardScreenRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardWindowRect = [self.view.window convertRect:keyboardScreenRect fromWindow:nil];
    keyboardViewFrame = [self.view convertRect:keyboardWindowRect fromView:nil];
    
    GTMLoggerDebug(@"keyboardScreenRect is %@", NSStringFromCGRect(keyboardScreenRect));
    GTMLoggerDebug(@"keyboardWindowRect is %@", NSStringFromCGRect(keyboardWindowRect));
    GTMLoggerDebug(@"keyboardFrame is %@", NSStringFromCGRect(keyboardViewFrame));
    
    
    
    
    if (self.firstResponderObject==self.textViewMessage){
        CGRect frame=self.talkingToolView.frame;
        
        CGRect  keyboardFrameInTalkingView = [self.talkingView convertRect:keyboardWindowRect fromView:nil];
        
        GTMLoggerDebug(@"keyboardFrameInTalkingView is %@", NSStringFromCGRect(keyboardFrameInTalkingView));
        
        CGFloat originY= keyboardViewFrame.origin.y;
        
        CGRect offsetFrame=CGRectMake(0, originY-frame.size.height, frame.size.width, frame.size.height);
        
        
        NSDictionary* info = [notification userInfo];
        NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval duration = 0;
        duration=[number doubleValue];
        
        [UIView animateWithDuration:duration animations:^{
            self.talkingToolView.frame=offsetFrame;
        }];
        
    }
    
    
}





-(void)setDialogPeer:(KKNearbyPeer *)dialogPeer
{
    _dialogPeer=dialogPeer;
    
}





#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView==self.tableViewPeers) {
        return 3;
    }
    
    return 0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView==self.tableViewPeers) {
        NSMutableArray *peers;
        
        if (section==0) {
            
            peers=[self peersWithStatus:@"1" fromArr:self.arrPeers];
            
        }
        
        if (section==1) {
            peers=[self peersWithStatus:@"-1" fromArr:self.arrPeers];
        }
        
        if (section==2) {
            peers=[self peersWithStatus:@"0" fromArr:self.arrPeers];
        }
        
        
        return peers.count;
        
        
    }
    
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    
    //        如果要显示完整的推，关键部分有两个：
    //        1. 让detailTextLabel可以合适的换行
    //        2. 调整单元格的大小从而可以完全显示detailTextLabel
    //        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap; //如何换行
    //        cell.detailTextLabel.numberOfLines = 0; //这个值设置为0可以让UILabel动态的显示需要的行数。
    //        调整单元格的高度则比较复杂，需要小心计算，步骤如下：
    
    
    if (tableView==self.tableViewPeers) {
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
        }
        
        NSInteger section=indexPath.section;
        
        NSString *status;
        NSMutableArray *peers;
        
        if (section==0) {
            
            status=@"connected";
            
            
            peers=[self peersWithStatus:@"1" fromArr:self.arrPeers];
            
            //            cell.textLabel.textColor=[UIColor redColor];
            cell.detailTextLabel.textColor=[UIColor redColor];
        }
        
        if (section==1) {
            status=@"disconnect";
             
            peers=[self peersWithStatus:@"-1" fromArr:self.arrPeers];
            
            //            cell.textLabel.textColor=[UIColor blueColor];
            cell.detailTextLabel.textColor=[UIColor blueColor];
            
        }
        
        if (section==2) {
            status=@"connecting";
            
            peers=[self peersWithStatus:@"0" fromArr:self.arrPeers];
            
            //            cell.textLabel.textColor=[UIColor yellowColor];
            cell.detailTextLabel.textColor=[UIColor yellowColor];
            
        }
        
        if (peers.count>0) {
            KKNearbyPeer *peer=[peers objectAtIndex:indexPath.row];
            
            GTMLoggerDebug(@"peer is %@",peer);
            
            cell.textLabel.text = [peer.accountOwner stringByAppendingFormat:@"(%@)",peer.source];
        }
        
        
        cell.detailTextLabel.text=status;
        
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView==self.tableViewPeers) {
        
        NSInteger section=indexPath.section;
        
        KKNearbyPeer *peer;
        
        NSString *status;
        
        peer=[self peerWithIndexPath:indexPath fromArr:self.arrPeers];
        
        if (section==0) {
            status=@"1";

            [self heartbeatPeers:YES];
            
        }
        
        if (section==1) {
            status=@"-1";
            
            if ([peer.source isEqualToString:@"browse"]) {
                
                [self inviteFoundPeerID:peer.peerID withAuto:NO];
                
            }
            else{
                
                [self.arrPeers removeObject:peer];
                
                [self.tableViewPeers reloadData];
                
            }
            
            
            
        }
        
        if (section==2) {
            status=@"0";
            
        }
        
    }
    
    
}


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"segTalking"]) {
//        KKTalkingViewController *dest = [segue destinationViewController];
//        dest.delegate = self;
//    }
//
//}
//
//
//-(void)segTalkingView:(id)sender
//{
//    [self performSegueWithIdentifier:@"segTalking" sender:sender];
//}
//
//
//-(void)dismissTalkingViewController
//{
//// KKTalkingViewController delegate methods
//
//}



#pragma mark - UICollectionViewDelegate methods

//每个section的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrMessages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    KKMessageCell *cell = (KKMessageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    
    NSDictionary *info = [self.arrMessages objectAtIndex:indexPath.item];
    
    cell.messageInfo=info;
    
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *info = [self.arrMessages objectAtIndex:indexPath.item];
    
    NSString *text=[info objectForKey:@"text"];
    
    NSDictionary  *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]]};
    
    CGRect rect= [text boundingRectWithSize:CGSizeMake(collectionView.frame.size.width-60, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    
    GTMLoggerDebug(@"text size is %@",NSStringFromCGSize(rect.size));
    
    
    CGSize size=CGSizeMake(collectionView.frame.size.width-10, ceilf(rect.size.height)+16+10);
   
    GTMLoggerDebug(@"cell size is %@",NSStringFromCGSize(size));
   
    
    return size;
    
}


#pragma mark nearby service

- (void)configNearbyPeerServiceWithName:(NSString *)name
{
    NSString *accountOwner;
    
    NSString *uuidStr=[[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    
    if (name.length==0) {
        accountOwner=[[UIDevice currentDevice] name];
    }
    else
    {
        accountOwner=name;
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
                           @"accountOwner":accountOwner,
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
        GTMLoggerDebug(@"Started advertising...");
 
    }
    else {
        [self.advertiser stopAdvertisingPeer];
        GTMLoggerDebug(@"Stopped advertising");
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



- (void)setBrowsing:(BOOL)browsing {
    
    if (_browsing==browsing) {
        return;
    }
    
    _browsing = browsing;
    
    
    if (self.browser==nil) {
        // Setup browser
        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:kServiceType];
        self.browser.delegate = self;
    }
    
    
    if (browsing) {
        
        
        [self.switchBrowsing setOn:YES animated:YES];
        
        [self.browser startBrowsingForPeers];
        GTMLoggerDebug(@"Started browsing...");
        //        self.lblConnectStatus.text=@"Started browsing...";
        
        [self.indicatorBrowsing startAnimating];
        
        [self.arrPeers removeAllObjects];
        
        // Update UI on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableViewPeers reloadData];
            
            CGRect frame1=self.peersView.frame;
            
            CGRect frame2=self.talkingMessageView.frame;
            
            CGFloat offsetY= self.peersView.frame.size.height;
            
            [UIView animateWithDuration:0.3 animations:^{
                
                self.peersView.frame=CGRectOffset(frame1, 0, frame1.size.height);
                
                self.talkingMessageView.frame=CGRectMake(frame2.origin.x, frame2.origin.y + offsetY, frame2.size.width, frame2.size.height - offsetY);
                }
            ];

            
        });
        
        
    }
    else {
        
        // Update UI on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        
        [self.switchBrowsing setOn:NO animated:YES];
        
        [self.browser stopBrowsingForPeers];
        GTMLoggerDebug(@"Stopped browsing");
        
        [self.indicatorBrowsing stopAnimating];
        
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            CGRect frame1=self.peersView.frame;
            
            CGRect frame2=self.talkingMessageView.frame;
            
            CGFloat offsetY= self.peersView.frame.size.height;
            
            [UIView animateWithDuration:0.3 animations:^{
                
                self.peersView.frame=CGRectOffset(frame1, 0, -frame1.size.height);
                
                self.talkingMessageView.frame=CGRectMake(frame2.origin.x, frame2.origin.y - offsetY, frame2.size.width, frame2.size.height + offsetY);
            }
             ];
            
        });
    }

    
    
    
    
    
    
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


#pragma mark - Nearby methods

- (void)inviteFoundPeerID:(MCPeerID *)foundPeerID  withAuto:(BOOL)atype
{
    // Create session
    
    if (self.session==nil) {
        // Create session
        self.session = [[MCSession alloc] initWithPeer:self.peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        self.session.delegate = self;
    }
    
    
    //只建立单向连接，不建立双向连接。
    
    if ([self.session.connectedPeers containsObject:foundPeerID]) {
        return;
    }
    
    
    
    
    NSData *contextData;
    
    if (atype) {
        
        NSMutableDictionary *contextInfo=  [NSMutableDictionary dictionaryWithDictionary:self.advertiser.discoveryInfo];
        
        [contextInfo setObject:@"y" forKey:@"auto"];
        
        contextData = [NSKeyedArchiver archivedDataWithRootObject:contextInfo];
    }
    else
    {
        contextData = [NSKeyedArchiver archivedDataWithRootObject:self.advertiser.discoveryInfo];
    }
    
    [self.browser invitePeer:foundPeerID toSession:self.session withContext:contextData timeout:30.0];

}


- (void)sendMessage:(NSString *)message toPeers:(NSArray *)peerIDs
{
    NSError *error;
    
    NSData *msgData = [@"Hello there!" dataUsingEncoding:NSUTF8StringEncoding];
    
    if (message) {
        msgData = [message dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    BOOL sendMessageResult;
    
    sendMessageResult = [self.session sendData:msgData toPeers:peerIDs withMode:MCSessionSendDataReliable error:&error];
    
    if (error){
        GTMLoggerDebug(@"SendData error: %@", error);
        [self.arrMessages addObject: @{@"accountOwner":self.accountOwner,@"source":@"local",@"type":@"message",@"text":message,@"date":[NSDate date],@"status":@"error"}];
        
    }
    else{
        GTMLoggerDebug(@"Sent message");
        [self.arrMessages addObject: @{@"accountOwner":self.accountOwner,@"source":@"local",@"type":@"message",@"text":message,@"date":[NSDate date],@"status":@"ok"}];
        
    }
    
    [self.talkingMessageView reloadData];
    
    self.textViewMessage.text=@"";
    
    [self textViewDidChange:self.textViewMessage];
    
}



-(KKNearbyPeer *)peerWithSameDisplayName:(NSString *)name fromArr:(NSMutableArray *)peers
{
    KKNearbyPeer *selectedPeer;
    
    for (KKNearbyPeer *peer in peers) {
        
        if ([peer.peerName isEqualToString:name]) {
            selectedPeer=peer;
            break;
        }
    }
    
    return selectedPeer;
}

//
//
-(KKNearbyPeer *)peerWithIndexPath:(NSIndexPath *)indexPath fromArr:(NSMutableArray *)peers
{
    
    
    NSMutableArray *selectedPeers;
    
    switch (indexPath.section) {
        case 0:
            selectedPeers=[self peersWithStatus:@"1" fromArr:peers] ;
            break;
        case 1:
            selectedPeers=[self peersWithStatus:@"-1" fromArr:peers];
            break;
        case 2:
            selectedPeers=[self peersWithStatus:@"0" fromArr:peers] ;
            break;
            
        default:
            break;
    }
    
    KKNearbyPeer *selectedPeer;
    
    if (selectedPeers.count>=indexPath.row+1) {
        selectedPeer = [selectedPeers objectAtIndex:indexPath.row];
    }
    
    
    return selectedPeer;
}
//
//
-(NSMutableArray *)peersWithStatus:(NSString *)status fromArr:(NSMutableArray *)peers
{
    NSMutableArray *selectedPeers=[NSMutableArray array];
    
    for (KKNearbyPeer *peer in peers) {
        
        if ([peer.status isEqualToString:status]) {
            [selectedPeers addObject:peer];
        }
    }
    
    return selectedPeers;
}



#pragma mark - MCNearbyServiceBrowserDelegate methods

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    GTMLoggerDebug(@"FoundPeer:%@, %@, %@", [info objectForKey:@"accountOwner"],peerID.displayName, info);
    
    
    KKNearbyPeer *sameDisplayNamePeer=[self peerWithSameDisplayName:peerID.displayName fromArr:self.arrPeers];
    
    
    //新 browsing 到的 设备 名称和 已经建立连接的设备名称相同，那么需要判断，
    if (sameDisplayNamePeer) {
        //
        
        
        if ([self.session.connectedPeers containsObject:sameDisplayNamePeer.peerID]) {
            nil;
            // 如果还在 连接着，那么不做任何处理，忽略掉这个新扫描到的设备。
            
            GTMLoggerDebug(@"new browsing  FoundPeer :%@ ,but this peer had been connected.",peerID);
        }
        else
        {
            [self.arrPeers removeObject:sameDisplayNamePeer];
            
            KKNearbyPeer *foundPeer=[[KKNearbyPeer alloc] initWithPeerID:peerID discoveryInfo:info status:@"-1"];
            
            foundPeer.source=@"browse";
            
            [self.arrPeers addObject:foundPeer];
            
             GTMLoggerDebug(@"new browsing  FoundPeer :%@ ,but this peer had been browsed.",peerID);
        }
        
    }
    else
    {
        GTMLoggerDebug(@"browse  FoundPeer :%@",peerID);
        
        KKNearbyPeer *foundPeer=[[KKNearbyPeer alloc] initWithPeerID:peerID discoveryInfo:info status:@"-1"];
        
        foundPeer.source=@"browse";
        
        [self.arrPeers addObject:foundPeer];
    }
    
    
    
    
    // Update UI on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableViewPeers reloadData];
    });
    
    //
    //    self.lblConnectStatus.text=[NSString stringWithFormat:@"browser FoundPeer: %@",peerID.displayName];
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    
    GTMLoggerDebug(@"LostPeer: %@", peerID.displayName);
    
    // 可以删除掉发现的 peer
    
    KKNearbyPeer *lostPeer =[self peerWithSameDisplayName:peerID.displayName fromArr:self.arrPeers];
    
    
    if (lostPeer) {
        [self.arrPeers removeObject:lostPeer];
        GTMLoggerDebug(@"remove LostPeer:%@, %@, %@", lostPeer.accountOwner,lostPeer.peerName, lostPeer.discoveryInfo);
    }
    
    
    // Update UI on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableViewPeers reloadData];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost browse Peer"
                                                        message:lostPeer.accountOwner
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        [alert show];
    });
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    GTMLoggerDebug(@"%s %@", __PRETTY_FUNCTION__, error);
    //    self.lblConnectStatus.text=@"browser didNotStartBrowsingForPeers";
}





#pragma mark - MCSessionDelegate methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    GTMLoggerDebug(@"session is %@",session);
//   GTMLoggerDebug(@"self.session is %@",self.session);
    
    
    if (self.dialogPeer==nil) {
        // 主动 发起连接请求的设备
        
        KKNearbyPeer *peer=[self peerWithSameDisplayName:peerID.displayName fromArr:self.arrPeers];
        
        self.dialogPeer=peer;
        
    }
    else{
    
        
    }
    
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [self.navigationItemHeader setTitle:[[self stringForPeerConnectionState:state] stringByAppendingString:self.dialogPeer.accountOwner]];
        
    });
    
    if (state==MCSessionStateConnecting) {
        GTMLoggerDebug(@"MCSessionDelegate Connecting");
        
        self.dialogPeer.status=@"0";
        
    }
    else if (state == MCSessionStateConnected){
        GTMLoggerDebug(@"MCSessionDelegate Connected");
        
        self.dialogPeer.status=@"1";
        
        self.browsing=NO;
        
    }
    else if (state == MCSessionStateNotConnected){
        
        GTMLoggerDebug(@"MCSessionDelegate Disconnected");
        
        self.dialogPeer.status=@"-1";
        
        [session cancelConnectPeer:peerID];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            if ([self.dialogPeer.source isEqualToString:@"invite"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost invite Peer,reconnect..."
                                                                message:self.dialogPeer.accountOwner
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                
                [alert show];
                
//                self.browsing=YES;
                
            }

        });
        
    }
    else
    {
        GTMLoggerDebug(@"MCSessionDelegate %d",state);
    }
    
    // Update UI on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableViewPeers reloadData];
    });
}





- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    // Decode the incoming data to a UTF8 encoded string
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (message.length==0) {
        return;
    }
    
    if ([message isEqualToString:@"K"]) {
        return;
    }
    
//    KKNearbyPeer *dialogPeer=[self peerWithSameDisplayName:peerID.displayName fromArr:self.arrPeers];
    
    KKNearbyPeer *dialogPeer=self.dialogPeer;
    
    GTMLoggerDebug(@"From %@: %@", dialogPeer.peerName, message);
    
    NSString *accountOwner =  dialogPeer.accountOwner;
    
    [self.arrMessages addObject: @{@"accountOwner":accountOwner,@"source":@"remote",@"type":@"message",@"text":message,@"date":[NSDate date],@"status":@"ok"}];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.talkingMessageView reloadData];
    });
    
    if (self.talkingMessageView.hidden) {
        
        NSInteger index = [[self peersWithStatus:@"1" fromArr:self.arrPeers] indexOfObject:dialogPeer];
        
        NSIndexPath *indexPath =  [NSIndexPath indexPathForRow:index inSection:0];
        
        UITableViewCell *cell=[self.tableViewPeers cellForRowAtIndexPath:indexPath];
        
        UIColor *oldColor=cell.backgroundColor;
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [UIView animateWithDuration:1.0 animations:^{
                cell.contentView.backgroundColor=[UIColor redColor];
            }
                             completion:^(BOOL finished) {
                                 //                cell.backgroundColor=oldColor;
                                 
                                 [self.tableViewPeers reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                             }
             ];
        });
        
        
        
        
    }
    
}



- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    GTMLoggerDebug(@"didStartReceivingResourceWithName %s Resource: %@, Peer: %@, Progress %@", __PRETTY_FUNCTION__, resourceName, peerID.displayName, progress);
    
    self.progressResourceReceived=progress;
    
    GTMLoggerDebug(@"progressResourceReceived is  %@", self.progressResourceReceived);
    
    //目标端的传输文件进度 数据表  接收数据
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.progressResourceReceived addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
    });
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //        self.progressViewFileSend.progress=progress.fractionCompleted;
    });
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //        self.progressViewFileSend.progress=progress.fractionCompleted;
        
        if (object == self.progressResourceReceived) {
            
            NSProgress *progress=self.progressResourceReceived;
            
            // Handle new fractionCompleted value
            [self.progressBar setProgress:progress.fractionCompleted animated:YES];
            GTMLoggerDebug(@"Fraction Complete: %@", [NSNumber numberWithDouble:progress.fractionCompleted]);
            
            GTMLoggerDebug(@"progress : %@", progress.localizedDescription);
            GTMLoggerDebug(@"progress : %@", progress.localizedAdditionalDescription);
            
            
            
            return;
        }
        
        if (object == self.progressResourceSent) {
            
            NSProgress *progress=self.progressResourceSent;
            // Handle new fractionCompleted value
            // Handle new fractionCompleted value
            [self.progressBar setProgress:progress.fractionCompleted animated:YES];
            GTMLoggerDebug(@"Fraction Complete: %@", [NSNumber numberWithDouble:progress.fractionCompleted]);
            
            GTMLoggerDebug(@"progress : %@", progress.localizedDescription);
            GTMLoggerDebug(@"progress : %@", progress.localizedAdditionalDescription);
            return;
        }
        
    });
    
    
    
    
    //
    //    [super observeValueForKeyPath:keyPath
    //                         ofObject:object
    //                           change:change
    //                          context:context];
}


- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.progressResourceReceived removeObserver:self forKeyPath:@"fractionCompleted"];
    });
    
    if (error) {
        GTMLoggerDebug(@"%s Peer: %@, Resource: %@, Error: %@", __PRETTY_FUNCTION__, peerID.displayName, resourceName, [error localizedDescription]);
    }
    else {
        GTMLoggerDebug(@"%s Peer: %@, Resource: %@ complete %@", __PRETTY_FUNCTION__, peerID.displayName, resourceName,[localURL absoluteString]);
        
        UIImage *image=[UIImage imageWithData:[NSData dataWithContentsOfURL:localURL]];
        
        if (image) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果is nill"
                                                                message:@"nil image"
                                                               delegate:nil
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
    GTMLoggerDebug(@"%sdidReceiveStream Peer: %@, Stream: %@", __PRETTY_FUNCTION__, peerID.displayName, streamName);
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [self.progressBar setProgress:0 animated:YES];
    });
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"开始 接收 stream "
                                                        message:streamName
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
        
        _incomingDataBuffer=[NSMutableData dataWithCapacity:[streamName integerValue]];
        
        self.streamInput=stream;
        
        // Start receiving data
        self.streamInput.delegate = self;
        
        [self.streamInput scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.streamInput open];
        
    });

    
}


- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    if (aStream == self.streamOutput) {
        
        if (eventCode == NSStreamEventHasSpaceAvailable) {
            // handle incoming data
            //we will only open the stream when we want to send the file.
            
            GTMLoggerDebug(@"Stream has space available");
            //[self updateStatus:@"Sending"];
            
            // If we don't have any data buffered, go read the next chunk of data.
            
            NSInteger packetSize=1024;
            
            if (totalBytesWritten< _outgoingDataBuffer.length) {
                //more stuff to read
                unsigned long towrite;
                unsigned long diff = _outgoingDataBuffer.length-packetSize;
                
                if (diff <= totalBytesWritten)
                {
                    towrite = _outgoingDataBuffer.length - totalBytesWritten;
                } else
                {
                    towrite = packetSize;
                }
                
                NSRange byteRange = {totalBytesWritten, towrite};
                uint8_t buffer[towrite];
                [_outgoingDataBuffer getBytes:buffer range:byteRange];
                
                NSInteger bytesWritten = [(NSOutputStream *)aStream write:buffer maxLength:towrite];
                
                totalBytesWritten += bytesWritten;
                
                GTMLoggerDebug(@"Written %d, total Written %ld out of %d bytes",bytesWritten,totalBytesWritten, _outgoingDataBuffer.length);
                
                CGFloat progressValue=((100*totalBytesWritten)/_outgoingDataBuffer.length)/100.0;
                
                GTMLoggerDebug(@"Written stream file progressValue  :%lf",progressValue);
            
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    [self.progressBar setProgress:progressValue animated:YES];
                });
                
            } else {
                //we've written all we can write about the topic?
                GTMLoggerDebug(@"done complete Written %ld out of %d bytes",totalBytesWritten, _outgoingDataBuffer.length);
                
                //                [self endStream];
            }
            
            // If we're not out of data completely, send the next chunk.
            
        } else if (eventCode == NSStreamEventEndEncountered) {
            // notify application that stream has ended
            
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
            //        [aStream release];
            aStream = nil; // stream is ivar, so reinit it
            //            _bytesRead=nil;
            //            _streamData=nil;
            
            
            
        } else if (eventCode == NSStreamEventErrorOccurred) {
            // notify application that stream has encountered and error
            
            
        }
        
    }
    else if (aStream == self.streamInput)
    {
        
        
        if (eventCode == NSStreamEventHasBytesAvailable) {
            // handle incoming data
            GTMLoggerDebug(@"Bytes Available");
            //Sent when the input stream has bytes to read, we need to read bytes or else this wont be called again
            //when this happens... we want to read as many bytes as we can
            
            uint8_t buffer[1024];
            int bytesRead;
            
            bytesRead = [(NSInputStream *)aStream read:buffer maxLength:sizeof(buffer)];
            
            [_incomingDataBuffer appendBytes:&buffer length:bytesRead];
            
            totalBytesRead += bytesRead;
            
            GTMLoggerDebug(@"Read %d bytes, total read bytes: %ld , stream file length :%d",bytesRead, totalBytesRead,_incomingDataBuffer.length);
            
            CGFloat progressValue=((100*totalBytesRead)/_incomingDataBuffer.length)/100.0;
            GTMLoggerDebug(@"Read stream file progressValue  :%lf",progressValue);
            
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                [self.progressBar setProgress:progressValue animated:YES];
            });
            
            
            
        } else if (eventCode == NSStreamEventEndEncountered) {
            // notify application that stream has ended
            
            UIImage *newImage = [[UIImage alloc]initWithData:_incomingDataBuffer];
            
            if (newImage) {
                UIImageWriteToSavedPhotosAlbum(newImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片"
                                                                    message:@"success"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                });
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片 nil"
                                                                    message:@"failure"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                });
                
                
            }
            
            
            //            [[self.detailViewController imageView] setImage:newImage];
            GTMLoggerDebug(@"End Encountered");
            
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
            //        [aStream release];
            aStream = nil; // stream is ivar, so reinit it
            
            _incomingDataBuffer=nil;
            
            
            
        } else if (eventCode == NSStreamEventErrorOccurred) {
            // notify application that stream has encountered and error
        }
        
    }
    
    
}




- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)cert fromPeer:(MCPeerID *)peerID certificateHandler:(void(^)(BOOL accept))certHandler {
    GTMLoggerDebug(@"didReceiveCertificate %s Peer: %@", __PRETTY_FUNCTION__, peerID.displayName);
    certHandler(YES);
}







- (NSString *)stringForPeerConnectionState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnected:
            return @"Connected ";
            break;
            
        case MCSessionStateConnecting:
            return @"Connecting ";
            break;
            
        case MCSessionStateNotConnected:
            return @"Disconnected ";
            break;
    }
}




#pragma mark - MCNearbyServiceAdvertiserDelegate methods

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)nearbyPeerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler {
    
    
    NSDictionary *dicContext=[NSKeyedUnarchiver unarchiveObjectWithData:context];
    
    
    
    //    GTMLoggerDebug(@"Invitation from:%@, %@, info=%@", invitePeer.accountOwner,invitePeer.peerName, invitePeer.discoveryInfo);
    
    
    
    if (self.session==nil) {
        // Create session
        self.session = [[MCSession alloc] initWithPeer:self.peerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        self.session.delegate = self;
        GTMLoggerDebug(@"create Session  %@",self.session);
    }
    
    
    
    NSString *title=[NSString stringWithFormat:NSLocalizedString(@"Received Invitation from %@", @"Received Invitation from {Peer}"), [dicContext objectForKey:@"accountOwner"]];
    
    
    
    GTMLoggerDebug(@"Invitation from: %@ ", [dicContext objectForKey:@"accountOwner"]);
    
    
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
                                       GTMLoggerDebug(@"Cancel action");
                                   }];
    
    UIAlertAction *resetAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Reject", @"Reject action")
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction *action)
                                  {
                                      GTMLoggerDebug(@"Reject action");
                                      invitationHandler(NO,self.session);
                                      
                                      self.session=nil;
                                      
                                  }];
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Accept", @"Accept action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   GTMLoggerDebug(@"Accept action");
                                   invitationHandler(YES,self.session);
                                   
                                   
                                   KKNearbyPeer *browsedPeer=[self peerWithSameDisplayName:nearbyPeerID.displayName fromArr:self.arrPeers];
                                   
                                   if (browsedPeer){
                                       self.dialogPeer=browsedPeer;
                                       
                                   }else{
                                       //设备还没有  browing 到，就已经被对方发了 连接请求 过来。
                                       // 这种情况会发生吗？
                                       //会发生，手工添加一个 纪录
                                       
                                       
                                       KKNearbyPeer *invitePeer=[[KKNearbyPeer alloc] initWithPeerID:nearbyPeerID discoveryInfo:dicContext status:@"-1"];
                                       invitePeer.source=@"invite";
                                       
//                                       [self.arrPeers addObject:invitePeer];
                                       
                                       //但是在 browsing扫描到了这个远程设备以后，怎么处理？
                                       
                                        self.dialogPeer=invitePeer;
                                       
                                   }
                                   
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
    GTMLoggerDebug(@"%s %@", __PRETTY_FUNCTION__, error);
    
}



@end
