//
//  KKTalkingViewController.m
//  MultipeerDemo
//
//  Created by mikewang on 14/10/22.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import "KKTalkingViewController.h"

@interface KKTalkingViewController () <UITextFieldDelegate>

@property (nonatomic,strong) UITextField *fieldMsg;

@end

@implementation KKTalkingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat width=self.view.bounds.size.width;
    CGFloat height=self.view.bounds.size.height;
    
    
    UIButton *btnClose=[UIButton buttonWithType:UIButtonTypeSystem];
    btnClose.frame=CGRectMake(40, 20, width-40, 40);
    [btnClose setTitle:@"Close" forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(closeSelfView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnClose];

    
    
    UITextField *fieldMsg=[[UITextField alloc] initWithFrame:CGRectMake(120, 60, width-130, 40)];
    fieldMsg.delegate=self;
    fieldMsg.borderStyle=UITextBorderStyleRoundedRect;
    
    [self.view addSubview:fieldMsg];
    
    self.fieldMsg=fieldMsg;
    
    
}


-(void)viewDidAppear:(BOOL)animated
{
    if ([self.talkingType isEqualToString:@"message"]) {
        [self.fieldMsg becomeFirstResponder];
    }
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
    
    
}


- (void)closeSelfView:(id)sender
{
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                                 [self.delegate dismissTalkingViewController];
                             }];
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





@end
