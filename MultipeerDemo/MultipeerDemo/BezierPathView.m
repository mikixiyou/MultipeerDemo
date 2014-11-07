//
//  BezierPathView.m
//  MultipeerDemo
//
//  Created by mikewang on 14/11/7.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import "BezierPathView.h"

@implementation BezierpathView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.LXVolabel = [[UITextView alloc]initWithFrame:CGRectMake(0, 0,self.frame.size.width , self.frame.size.height-10)];
        self.LXVolabel.backgroundColor = [UIColor clearColor];
        self.LXVolabel.delegate = self;
        self.LXVolabel.font = [UIFont systemFontOfSize:20];
        
        [self addSubview:self.LXVolabel];
        
        CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, applicationFrame.size.width, applicationFrame.size.height)];
        
        
        // Color Declarations
        darkGray = [UIColor grayColor];
        
        // Shadow Declarations
        shadow= [UIColor blackColor];
        shadowOffset= CGSizeMake(0, 1);
        shadowBlurRadius= 1;
        
        // Abstracted Graphic Attributes
        textContent= LXVolabel.text;
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef  context = UIGraphicsGetCurrentContext();
    
    // Drawing code
    
    //// General Declarations
    
    // speechBubbleTop Drawing
    speechBubbleTopPath = [UIBezierPath bezierPath];
    [speechBubbleTopPath moveToPoint: CGPointMake(294, 7)];
    [speechBubbleTopPath addCurveToPoint: CGPointMake(288, -0) controlPoint1: CGPointMake(294, 3.13) controlPoint2: CGPointMake(291.31, -0)];
    [speechBubbleTopPath addLineToPoint: CGPointMake(8, -0)];
    [speechBubbleTopPath addCurveToPoint: CGPointMake(2, 7) controlPoint1: CGPointMake(4.69, -0) controlPoint2: CGPointMake(2, 3.13)];
    [speechBubbleTopPath addLineToPoint: CGPointMake(294, 7)];
    [speechBubbleTopPath closePath];
    [darkGray setFill];
    [speechBubbleTopPath fill];
    
    
    
    // Rectangle Drawing
    rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(2, 6, 292,self.frame.size.height-15)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [darkGray setFill];
    [rectanglePath fill];
    CGContextRestoreGState(context);
    
    
    
    // Text Drawing
    CGRect textRect = CGRectMake(7, 6, 292, self.frame.size.height-15);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [[UIColor whiteColor] setFill];
    [textContent drawInRect: textRect withFont: [UIFont fontWithName: @"Helvetica-Light" size: 14] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];
    //CGContextRestoreGState(context);
    
    float addedHeight = 100 -38;
    
//    [self drawPath:addedHeight contextValue:context];
    //speechBubbleBottom Drawing
    
    
    speechBubbleBottomPath = [UIBezierPath bezierPath];
    [speechBubbleBottomPath moveToPoint: CGPointMake(2, 24+addedHeight)];
    [speechBubbleBottomPath addCurveToPoint: CGPointMake(8, 30+addedHeight) controlPoint1: CGPointMake(2, 27.31+addedHeight) controlPoint2: CGPointMake(4.69, 30+addedHeight)];
    [speechBubbleBottomPath addLineToPoint: CGPointMake(13, 30+addedHeight)];
    [speechBubbleBottomPath addLineToPoint: CGPointMake(8, 42+addedHeight)];
    [speechBubbleBottomPath addLineToPoint: CGPointMake(25, 30+addedHeight)];
    [speechBubbleBottomPath addLineToPoint: CGPointMake(288, 30+addedHeight)];
    [speechBubbleBottomPath addCurveToPoint: CGPointMake(294, 24+addedHeight) controlPoint1: CGPointMake(291.31, 30+addedHeight) controlPoint2: CGPointMake(294, 27.31+addedHeight)];
    [speechBubbleBottomPath addLineToPoint: CGPointMake(2, 24+addedHeight)];
    [speechBubbleBottomPath closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [darkGray setFill];
    [speechBubbleBottomPath fill];
    CGContextRestoreGState(context);
    
}
-(void)textViewDidChange:(UITextView *)textView{
    CGRect rect = textView.frame;
    rect.size.height = textView.contentSize.height;// Adding.size Since height is not a member of CGRect
    self.frame = CGRectMake(10, 20, textView.frame.size.width, textView.contentSize.height+20);
    textView.frame = rect;
}

@end
