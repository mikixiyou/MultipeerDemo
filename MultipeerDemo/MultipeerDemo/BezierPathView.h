//
//  BezierPathView.h
//  MultipeerDemo
//
//  Created by mikewang on 14/11/7.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BezierpathView :  UIView<UITextViewDelegate>{
    
    CGFloat animatedDistance;
    
    UITextView *LXVolabel;
    UIView *view;
    UIBezierPath * speechBubbleTopPath;
    UIBezierPath * rectanglePath;
    UIBezierPath * speechBubbleBottomPath;
    UIColor * darkGray;
    UIColor * shadow;
    CGSize shadowOffset;
    CGFloat shadowBlurRadius;
    NSString * textContent;
}

@property(nonatomic,strong)UIView *view;
@property(nonatomic,strong)UITextView *LXVolabel;

@end
