//
//  KKMessageCell.m
//  MultipeerDemo
//
//  Created by mikewang on 14/11/5.
//  Copyright (c) 2014年 xiyou. All rights reserved.
//

#import "KKMessageCell.h"

#import "GTMLogger.h"

@interface KKMessageCell()

@property (nonatomic,strong) UITextView *labelMessage;

@property (nonatomic,strong) UIImageView *imageViewBubble;


@end

@implementation KKMessageCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {

        
        CGFloat width=self.contentView.frame.size.width;
        CGFloat height=self.contentView.frame.size.height;
        
        self.imageViewBubble=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        
        [self.contentView addSubview:self.imageViewBubble];
        
        
        self.labelMessage=[[UITextView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        
        self.labelMessage.backgroundColor=[UIColor clearColor];
        self.labelMessage.textAlignment=NSTextAlignmentLeft;
        self.labelMessage.font=[UIFont systemFontOfSize:[UIFont systemFontSize]];
        
//        self.labelMessage.numberOfLines=0;
        
        [self.contentView addSubview:self.labelMessage];
        
        

        
//        if (type == BubbleTypeSomeoneElse)
//        {
//            bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
//            bubbleImage.frame = CGRectMake(x - 18, y - 4, self.dataInternal.labelSize.width + 30, self.dataInternal.labelSize.height + 15);
//        }
//        else {
//            bubbleImage.image = [[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:14];
//            bubbleImage.frame = CGRectMake(x - 9, y - 4, self.dataInternal.labelSize.width + 26, self.dataInternal.labelSize.height + 15);
//        }
        
        
        
//        self.contentView.backgroundColor=[UIColor blueColor];
        
        
    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    //    NSArray* array = [self.cellField.layer.sublayers copy];
    //
    //    self.cellField.layer.sublayers=nil;
    //    // 不能直接 remove one item，但是可以置空  sublayes。
    //
    //    for (CALayer* layer in array){
    //        [layer removeFromSuperlayer];
    //    }
    

}

-(void)setInfo:(NSDictionary *)info
{
    _info=info;
    
    
    CGFloat width=self.contentView.frame.size.width;
    
    NSDictionary  *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:[UIFont systemFontSize]]};
    
    CGRect rect= [[info objectForKey:@"text"] boundingRectWithSize:CGSizeMake(width-60, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    
    GTMLoggerDebug(@"rect is %@",NSStringFromCGRect(rect));
    
    CGFloat widthMessageLable = ceilf(rect.size.width);
    CGFloat heightMessageLable = ceilf(rect.size.height);
    
    
    if ([[info objectForKey:@"source"] isEqualToString:@"local"]) {
        
        self.labelMessage.frame = CGRectMake(width-(widthMessageLable+20), 5, widthMessageLable,heightMessageLable);

        self.labelMessage.textColor=[UIColor greenColor];
        
        CGFloat x=self.labelMessage.frame.origin.x;
        CGFloat y=self.labelMessage.frame.origin.y;
        
        self.imageViewBubble.frame = CGRectMake(x - 3, y - 4, self.labelMessage.frame.size.width + 10, self.labelMessage.frame.size.height + 8);
        
        self.imageViewBubble.image = [[UIImage imageNamed:@"bubbleMine.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.5, 0.5, 0, 0)];
        
//        self.imageViewBubble.image          = [UIImage imageNamed:@"bubbleMine.png"];
        self.imageViewBubble.contentMode    = UIViewContentModeScaleToFill;
        

        
        
    }
    else
    {
        
        self.labelMessage.frame= CGRectMake(20, 3, widthMessageLable,heightMessageLable);
        
        self.labelMessage.textColor=[UIColor redColor];

        CGFloat x=self.labelMessage.frame.origin.x;
        CGFloat y=self.labelMessage.frame.origin.y;
        
        self.imageViewBubble.frame = CGRectMake(x - 3, y - 4, self.labelMessage.frame.size.width + 10, self.labelMessage.frame.size.height + 8);
        
        self.imageViewBubble.image = [[UIImage imageNamed:@"bubbleSomeone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.5, 0.5, 0, 0)];
        
//        self.imageViewBubble.image          = [UIImage imageNamed:@"bubbleSomeone.png"];
        self.imageViewBubble.contentMode    = UIViewContentModeScaleToFill;
        

    }
    
    
    self.labelMessage.text=[info objectForKey:@"text"];
    

}

@end
