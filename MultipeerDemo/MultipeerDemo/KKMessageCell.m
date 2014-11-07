//
//  KKMessageCell.m
//  MultipeerDemo
//
//  Created by mikewang on 14/11/5.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import "KKMessageCell.h"

#import "GTMLogger.h"

#define CORNER_RADIUS 4

#define ARROW_HEIGHT 8
#define ARROW_WIDTH 8


@interface KKMessageCell()

@property (nonatomic,strong) UITextView *textMessage;

@property (nonatomic,strong) UIImageView *imageViewBubble;

@property (nonatomic,strong)  CAShapeLayer *outlineLayer;


@end

@implementation KKMessageCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {

        self.contentView.backgroundColor=[UIColor lightGrayColor];

        
        
        // Draw the border
        CAShapeLayer *outlineLayer = [CAShapeLayer layer];
        outlineLayer.strokeColor = [UIColor blueColor].CGColor;
        outlineLayer.lineWidth = 1.0;
        outlineLayer.fillColor = [UIColor clearColor].CGColor;
        outlineLayer.name=@"bubbleLayer";
        
        [self.contentView.layer addSublayer:outlineLayer];
        
        self.outlineLayer=outlineLayer;
        
        // add subview
        UITextView *textMessage=[[UITextView alloc] initWithFrame:self.contentView.bounds];
        textMessage.editable=NO;
        textMessage.backgroundColor=[UIColor clearColor];
        textMessage.textAlignment=NSTextAlignmentLeft;
        textMessage.font=[UIFont systemFontOfSize:[UIFont systemFontSize]];
        
        [self.contentView addSubview:textMessage];

        self.textMessage=textMessage;
    }
    
    return self;
}

- (void)prepareForReuse
{
    
    [super prepareForReuse];
    
    
//    
//    NSArray *arrayLayers = [self.contentView.layer.sublayers copy];
//    
//    self.contentView.layer.sublayers = nil;
//    // 不能直接 remove one item，但是可以置空  sublayes。
//    
//    for (CALayer *layer in arrayLayers) {
//        if ([layer.name isEqualToString:@"bubbleLayer"]) {
//            [layer removeFromSuperlayer];
//            nil;
//        }
//    }
//    
//    for (UIView *view in self.contentView.subviews) {
//        [view removeFromSuperview];
//    }

}


-(UIBezierPath *)leftBubblePathWithFrame:(CGRect)frame
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGRect bubbleFrame = frame;
    
    CGFloat offset=8;
    
    // Start at the arrow
    
    CGPoint p0=  CGPointMake(CGRectGetMinX(bubbleFrame), CGRectGetMaxY(bubbleFrame)-CORNER_RADIUS-offset);
    [path moveToPoint:p0];
    
    CGPoint p1=  CGPointMake(CGRectGetMinX(bubbleFrame)-ARROW_HEIGHT, CGRectGetMaxY(bubbleFrame)-CORNER_RADIUS-offset-ARROW_WIDTH/2.0);
    [path addLineToPoint:p1];
    
    CGPoint p2=  CGPointMake(CGRectGetMinX(bubbleFrame), CGRectGetMaxY(bubbleFrame)-CORNER_RADIUS-offset-ARROW_WIDTH);
    [path addLineToPoint:p2];
    
    CGPoint p3=  CGPointMake(CGRectGetMinX(bubbleFrame), CGRectGetMinY(bubbleFrame)+CORNER_RADIUS);
    [path addLineToPoint:p3];
    
    // Top left corner
    [path addArcWithCenter:CGPointMake(CGRectGetMinX(bubbleFrame) + CORNER_RADIUS,
                                       CGRectGetMinY(bubbleFrame) + CORNER_RADIUS)
                    radius:CORNER_RADIUS startAngle:M_PI endAngle:3 * M_PI / 2 clockwise:YES];
    

    CGPoint p4=  CGPointMake(CGRectGetMaxX(bubbleFrame)-CORNER_RADIUS, CGRectGetMinY(bubbleFrame));
    [path addLineToPoint:p4];
    
    
    // Top right corner
    [path addArcWithCenter:CGPointMake(CGRectGetMaxX(bubbleFrame) - CORNER_RADIUS,
                                       CGRectGetMinY(bubbleFrame) + CORNER_RADIUS)
                    radius:CORNER_RADIUS startAngle:3 * M_PI / 2 endAngle:2 * M_PI
                 clockwise:YES];
    
    CGPoint p5=  CGPointMake(CGRectGetMaxX(bubbleFrame), CGRectGetMaxY(bubbleFrame)-CORNER_RADIUS);
    [path addLineToPoint:p5];
    
    
    // Bottom right corner
    [path addArcWithCenter:CGPointMake(CGRectGetMaxX(bubbleFrame) - CORNER_RADIUS,
                                       CGRectGetMaxY(bubbleFrame) - CORNER_RADIUS)
                    radius:CORNER_RADIUS startAngle:0 endAngle:M_PI / 2
                 clockwise:YES];
    
    CGPoint p6=  CGPointMake(CGRectGetMinX(bubbleFrame)+CORNER_RADIUS, CGRectGetMaxY(bubbleFrame));
    [path addLineToPoint:p6];

    
    // Bottom left corner
    
    [path addArcWithCenter:CGPointMake(CGRectGetMinX(bubbleFrame) + CORNER_RADIUS,
                                       CGRectGetMaxY(bubbleFrame) - CORNER_RADIUS)
                    radius:CORNER_RADIUS startAngle:M_PI / 2 endAngle:M_PI clockwise:YES];
    
    [path addLineToPoint:p0];
    
    [path closePath];
    
    return path;
}


-(UIBezierPath *)rightBubblePathWithFrame:(CGRect)frame
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGRect bubbleFrame = frame;
    
    CGFloat offset=8;
    
    // Start at the arrow
    
    CGPoint p0=  CGPointMake(CGRectGetMaxX(bubbleFrame), CGRectGetMaxY(bubbleFrame)-CORNER_RADIUS-offset);
    [path moveToPoint:p0];
    
    CGPoint p1=  CGPointMake(CGRectGetMaxX(bubbleFrame) + ARROW_HEIGHT, CGRectGetMaxY(bubbleFrame)-CORNER_RADIUS-offset-ARROW_WIDTH/2.0);
    [path addLineToPoint:p1];
    
    CGPoint p2=  CGPointMake(CGRectGetMaxX(bubbleFrame), CGRectGetMaxY(bubbleFrame)-CORNER_RADIUS-offset-ARROW_WIDTH);
    [path addLineToPoint:p2];
    
    CGPoint p3=  CGPointMake(CGRectGetMaxX(bubbleFrame), CGRectGetMinY(bubbleFrame)+CORNER_RADIUS);
    [path addLineToPoint:p3];
    
    
    
    // Top right corner
    [path addArcWithCenter:CGPointMake(CGRectGetMaxX(bubbleFrame) - CORNER_RADIUS,
                                       CGRectGetMinY(bubbleFrame) + CORNER_RADIUS)
                    radius:CORNER_RADIUS startAngle:2 * M_PI  endAngle:3 * M_PI/2
                 clockwise:NO];
    
    CGPoint p5=  CGPointMake(CGRectGetMinX(bubbleFrame) + CORNER_RADIUS, CGRectGetMinY(bubbleFrame));
    [path addLineToPoint:p5];
    
    
    
    // Top left corner
    [path addArcWithCenter:CGPointMake(CGRectGetMinX(bubbleFrame) + CORNER_RADIUS,
                                       CGRectGetMinY(bubbleFrame) + CORNER_RADIUS)
                    radius:CORNER_RADIUS startAngle:3*M_PI/2 endAngle: M_PI clockwise:NO];
    
    
    CGPoint p4=  CGPointMake(CGRectGetMinX(bubbleFrame), CGRectGetMaxY(bubbleFrame)-CORNER_RADIUS);
    [path addLineToPoint:p4];
    

    
    // Bottom left corner
    
    [path addArcWithCenter:CGPointMake(CGRectGetMinX(bubbleFrame) + CORNER_RADIUS,
                                       CGRectGetMaxY(bubbleFrame) - CORNER_RADIUS)
                    radius:CORNER_RADIUS startAngle:M_PI endAngle:M_PI/2 clockwise:NO];
    
    CGPoint p6=  CGPointMake(CGRectGetMaxX(bubbleFrame) - CORNER_RADIUS, CGRectGetMaxY(bubbleFrame));
    [path addLineToPoint:p6];
    
    
    // Bottom right corner
    [path addArcWithCenter:CGPointMake(CGRectGetMaxX(bubbleFrame) - CORNER_RADIUS,
                                       CGRectGetMaxY(bubbleFrame) - CORNER_RADIUS)
                    radius:CORNER_RADIUS startAngle:M_PI / 2 endAngle:0
                 clockwise:NO];
    
    [path addLineToPoint:p0];
    
    [path closePath];
    
    return path;
}



-(void)setMessageInfo:(NSDictionary *)messageInfo
{
    _messageInfo=messageInfo;
    
    
    CGFloat width=self.contentView.frame.size.width;
    
    
    NSDictionary  *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]]};
    
    CGRect rect= [[messageInfo objectForKey:@"text"] boundingRectWithSize:CGSizeMake(width-60, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    
    GTMLoggerDebug(@"real text rect is %@",NSStringFromCGRect(rect));
    
    CGFloat widthMessage = ceilf(rect.size.width)+10;
    
    CGFloat heightMessage = ceilf(rect.size.height)+16;
    
    CGRect frameMessage;
    
    
    if ([[messageInfo objectForKey:@"source"] isEqualToString:@"local"]) {
        
        frameMessage= CGRectMake(width-(widthMessage+20), 5, widthMessage,heightMessage);

        self.textMessage.textColor=[UIColor greenColor];
        
        self.textMessage.frame=frameMessage;
        
        self.outlineLayer.path=[self rightBubblePathWithFrame:frameMessage].CGPath;
    }
    else
    {
        frameMessage= CGRectMake(20, 5, widthMessage,heightMessage);
        
        self.textMessage.textColor=[UIColor redColor];
        
        self.textMessage.frame=frameMessage;
        
        self.outlineLayer.path=[self leftBubblePathWithFrame:frameMessage].CGPath;
    }
    
    GTMLoggerDebug(@"self.textMessage.frameMessage is %@",NSStringFromCGRect(frameMessage));
    
    self.textMessage.text=[messageInfo objectForKey:@"text"];
    
//    [self setNeedsDisplay];
    
    

}

@end
