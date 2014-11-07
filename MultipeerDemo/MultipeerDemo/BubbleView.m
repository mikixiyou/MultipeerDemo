//
//  BubbleView.m
//  MultipeerDemo
//
//  Created by mikewang on 14/11/6.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import "BubbleView.h"

#define degreesToRadians(x) (M_PI*(x)/180.0) //把角度转换成PI的方式
#define  PROGREESS_WIDTH 80 //圆直径
#define PROGRESS_LINE_WIDTH 4 //弧线的宽度



#import <QuartzCore/QuartzCore.h>

#define HORIZONTAL_PADDING 10
#define VERTICAL_PADDING 5
#define ARROW_HEIGHT 20
#define ARROW_WIDTH 10
#define DEFAULT_ARROW_POSITION 60
#define CORNER_RADIUS 10
#define ACTIVATION_PADDING 0

CGFloat clamp(CGFloat value, CGFloat minValue, CGFloat maxValue)
{
    if (value < minValue) {
        return minValue;
    }
    
    if (value > maxValue) {
        return maxValue;
    }
    
    return value;
}


@interface BubbleView()
{
    CGRect _activationFrame;
}

@property (nonatomic,strong) CAShapeLayer *bubble;

@property(nonatomic, retain) UIColor *gradientStartColor;
@property(nonatomic, retain) UIColor *gradientEndColor;
@property(nonatomic, retain) UIColor *borderColor;

@end

@implementation BubbleView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self initalPop];
        
    }
    
    return self;
}





- (CGRect)bubbleFrame
{
    CGSize viewSize = self.frame.size;
    CGRect frame = CGRectMake(HORIZONTAL_PADDING, ARROW_HEIGHT + VERTICAL_PADDING,
                              viewSize.width - 2 * HORIZONTAL_PADDING,
                              viewSize.height - ARROW_HEIGHT - 2 * VERTICAL_PADDING);
    return frame;
}

- (CGFloat)minArrowPosition
{
    return CGRectGetMinX([self bubbleFrame]) + ARROW_WIDTH / 2 + CORNER_RADIUS;
}

- (CGFloat)maxArrowPosition
{
    return CGRectGetMaxX([self bubbleFrame]) - ARROW_WIDTH / 2 - CORNER_RADIUS;
}

- (CGFloat)arrowPosition
{
    if (CGRectIsEmpty(_activationFrame)) {
        return DEFAULT_ARROW_POSITION;
    }
    
    return clamp(CGRectGetMidX(_activationFrame), [self minArrowPosition], [self maxArrowPosition]);
}

- (CGPoint)arrowMiddleBase
{
    CGRect bubbleFrame = [self bubbleFrame];
    return CGPointMake(CGRectGetMinX(bubbleFrame) + [self arrowPosition], CGRectGetMinY(bubbleFrame));
}

- (UIBezierPath *)bubblePathWithRoundedCornerRadius:(CGFloat)cornerRadius
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGRect bubbleFrame = [self bubbleFrame];
    CGPoint arrowMiddleBase = CGPointMake([self arrowPosition], bubbleFrame.origin.y);
    
    // Start at the arrow
    [path moveToPoint:CGPointMake(arrowMiddleBase.x - ARROW_WIDTH / 2, arrowMiddleBase.y)];
    
    CGPoint controlPoint1= CGPointMake(arrowMiddleBase.x - ARROW_WIDTH / 4, arrowMiddleBase.y-ARROW_HEIGHT/4.0);
    CGPoint controlPoint2= CGPointMake(arrowMiddleBase.x - ARROW_WIDTH / 4, arrowMiddleBase.y-ARROW_HEIGHT/4.0);
    
    CGPoint controlPoint3= CGPointMake(arrowMiddleBase.x + ARROW_WIDTH / 4, arrowMiddleBase.y+ARROW_HEIGHT/4.0);
    CGPoint controlPoint4= CGPointMake(arrowMiddleBase.x + ARROW_WIDTH / 4, arrowMiddleBase.y+ARROW_HEIGHT/4.0);
    
//    [path addCurveToPoint:CGPointMake(arrowMiddleBase.x, arrowMiddleBase.y - ARROW_HEIGHT) controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    
//    [path addCurveToPoint:CGPointMake(arrowMiddleBase.x + ARROW_WIDTH / 2, arrowMiddleBase.y) controlPoint1:controlPoint3 controlPoint2:controlPoint3];
    
    
    [path addLineToPoint:CGPointMake(arrowMiddleBase.x, arrowMiddleBase.y - ARROW_HEIGHT)];
    [path addLineToPoint:CGPointMake(arrowMiddleBase.x + ARROW_WIDTH / 2, arrowMiddleBase.y)];
    
    [path addLineToPoint:CGPointMake(bubbleFrame.origin.x + bubbleFrame.size.width - cornerRadius,
                                     arrowMiddleBase.y)];
    // Top right corner
    [path addArcWithCenter:CGPointMake(CGRectGetMaxX(bubbleFrame) - cornerRadius,
                                       arrowMiddleBase.y + cornerRadius)
                    radius:cornerRadius startAngle:3 * M_PI / 2 endAngle:2 * M_PI
                 clockwise:YES];
    
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(bubbleFrame),
                                     CGRectGetMaxY(bubbleFrame) - cornerRadius)];
    // Bottom right corner
    [path addArcWithCenter:CGPointMake(CGRectGetMaxX(bubbleFrame) - cornerRadius,
                                       CGRectGetMaxY(bubbleFrame) - cornerRadius)
                    radius:cornerRadius startAngle:0 endAngle:M_PI / 2
                 clockwise:YES];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(bubbleFrame) + cornerRadius,
                                     CGRectGetMaxY(bubbleFrame))];
    
    // Bottom left corner
    
    CGPoint p1=CGPointMake(CGRectGetMinX(bubbleFrame)+cornerRadius, CGRectGetMaxY(bubbleFrame));
    
    CGPoint p2=CGPointMake(CGRectGetMinX(bubbleFrame), CGRectGetMaxY(bubbleFrame)-cornerRadius);
    
    CGPoint p0=CGPointMake(CGRectGetMinX(bubbleFrame)-2*cornerRadius, CGRectGetMaxY(bubbleFrame)+cornerRadius);
    
//    [path addLineToPoint:p0];
    
//    [path addLineToPoint:p2];
    
    
    CGPoint c1=CGPointMake(p0.x+5, p0.y-5);
//    
//    [path addCurveToPoint:p0 controlPoint1:c1 controlPoint2:c1];
//    
//    [path addCurveToPoint:p2 controlPoint1:c1 controlPoint2:c1];
    
    
    [path addArcWithCenter:CGPointMake(CGRectGetMinX(bubbleFrame) + cornerRadius,
                                       CGRectGetMaxY(bubbleFrame) - cornerRadius)
                    radius:cornerRadius startAngle:M_PI / 2 endAngle:M_PI clockwise:YES];
    
    
    
    
    [path addLineToPoint:CGPointMake(CGRectGetMinX(bubbleFrame),
                                     CGRectGetMaxY(bubbleFrame) - cornerRadius*2)];
    
    
    [path addLineToPoint:CGPointMake(CGRectGetMinX(bubbleFrame)-cornerRadius,
                                     CGRectGetMaxY(bubbleFrame) - cornerRadius*2-0.5*cornerRadius)];
    
    
    
    [path addLineToPoint:CGPointMake(CGRectGetMinX(bubbleFrame),
                                     CGRectGetMaxY(bubbleFrame)-cornerRadius*3)];
    
    
    
    [path addLineToPoint:CGPointMake(CGRectGetMinX(bubbleFrame),
                                     CGRectGetMinY(bubbleFrame) + cornerRadius)];
    
    
    // Top left corner
    [path addArcWithCenter:CGPointMake(CGRectGetMinX(bubbleFrame) + cornerRadius,
                                       CGRectGetMinY(bubbleFrame) + cornerRadius)
                    radius:cornerRadius startAngle:M_PI endAngle:3 * M_PI / 2 clockwise:YES];
    
    [path closePath];
    
    return path;
}

- (CALayer *)bubbleLayer
{
    CALayer *bubbleLayer = [CALayer layer];
    bubbleLayer.frame = (CGRect) { CGPointZero, self.frame.size };
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = (CGRect) { CGPointZero, bubbleLayer.frame.size };
    
    UIBezierPath *path = [self bubblePathWithRoundedCornerRadius:10.0];
    
    // Gradient colors from gray to black
    gradientLayer.colors = [NSArray arrayWithObjects:(id)self.gradientStartColor.CGColor, (id)self.gradientEndColor.CGColor, nil];
    
    // Apply a mask to the gradient layer
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    gradientLayer.mask = maskLayer;
    
    // Draw the border
    CAShapeLayer *outlineLayer = [CAShapeLayer layer];
    outlineLayer.path = path.CGPath;
    outlineLayer.strokeColor = self.borderColor.CGColor;
    outlineLayer.lineWidth = 1.5;
    outlineLayer.fillColor = [UIColor clearColor].CGColor;
    
    // And finally a shadow
    CAShapeLayer *shadowLayer = [CAShapeLayer layer];
    shadowLayer.shadowPath = path.CGPath;
    shadowLayer.shadowColor = [UIColor blackColor].CGColor;
    shadowLayer.shadowRadius = 5;
    shadowLayer.shadowOffset = CGSizeMake(1.0, 1.0);
    shadowLayer.shadowOpacity = 0.75;
    
//    [bubbleLayer addSublayer:shadowLayer];
//    [bubbleLayer addSublayer:gradientLayer];
    [bubbleLayer addSublayer:outlineLayer];
    
    return bubbleLayer;
}

- (void)setupDefaultValuesAndLayers
{
    self.borderColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
    self.gradientStartColor = [UIColor grayColor];
    self.gradientEndColor = [UIColor blackColor];
    
    [self.layer addSublayer:[self bubbleLayer]];
}

- (id)initWithFrame:(CGRect)frame activationFrame:(CGRect)activationFrame
{
    self = [super initWithFrame:frame];
    if (self) {
        _activationFrame = activationFrame;
        [self setupDefaultValuesAndLayers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupDefaultValuesAndLayers];
    }
    return self;
}

- (id)initWithHeight:(CGFloat)height activationFrame:(CGRect)activationFrame
{
    CGRect frame = CGRectMake(0.0, CGRectGetMaxY(activationFrame) + ACTIVATION_PADDING, [UIScreen mainScreen].bounds.size.width, height);
    
    return [self initWithFrame:frame activationFrame:activationFrame];
}

- (void)dealloc
{
    self.borderColor = nil;
    self.gradientStartColor = nil;
    self.gradientEndColor = nil;

}














//Called in init method
-(void) initalPop {
    //Circle
    self.bubble = [CAShapeLayer layer];
    self.bubble.bounds = self.bounds;
    self.bubble.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.bubble.fillColor = [[UIColor clearColor] CGColor];
    self.bubble.strokeColor = [[UIColor greenColor] CGColor];
    self.bubble.lineWidth = 1.0;
    
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, nil, self.bounds);
    
    
    UIBezierPath *path2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(40, 40) radius:(80 - 4)/2 startAngle:degreesToRadians(-210) endAngle:degreesToRadians(30) clockwise:YES];//上面说明过了用来构建圆形
    
    self.bubble.path = path2.CGPath;
    
    [self.layer addSublayer: self.bubble];
}


//Called when timer goes off
- (void) StageGrow {
    CGFloat growSize = 50.0;
    //Change the size of us and center the circle (but dont want to animate this
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    self.bounds = CGRectMake(0, 0, self.bounds.size.width + growSize, self.bounds.size.height + growSize);
    self.bubble.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [CATransaction commit];
    [self ActualGrowCircle];
}

-(void)ActualGrowCircle {
    CGMutablePathRef newPath = CGPathCreateMutable();
    CGPathAddEllipseInRect(newPath, nil, self.bounds);
    
    UIBezierPath *newPath2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(40, 40) radius:(80 - 4)/2 startAngle:degreesToRadians(-210) endAngle:degreesToRadians(30) clockwise:YES];//上面说明过了用来构建圆形
    

    
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = 1;
    animation.autoreverses = NO;
    animation.fromValue = (__bridge id)self.bubble.path;
    animation.toValue = (__bridge id)newPath;
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation2.repeatCount = 1;
    animation2.autoreverses = NO;
    animation2.fromValue = [NSValue valueWithCGRect:self.bubble.bounds];
    animation2.toValue = [NSValue valueWithCGRect:self.bounds];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    [group setAnimations:[NSArray arrayWithObjects: animation2, animation, nil]];
    group.duration = 0.5;
    group.delegate = self;
    
    self.bubble.bounds = self.bounds;
    self.bubble.path = newPath2.CGPath;
    [self.bubble addAnimation:group forKey:@"animateGroup"];
    
    CGPathRelease(newPath);
    
    
}


@end
