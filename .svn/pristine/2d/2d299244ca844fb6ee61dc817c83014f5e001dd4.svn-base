//
//  MJRefreshNormalHeader.m
//  MJRefreshExample
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "CKMJProgressHeader.h"
#import "NSBundle+MJRefresh.h"

@interface CKMJProgressHeader()<CAAnimationDelegate>
{
    CAShapeLayer * backgroundLayer;
    CAShapeLayer *shapeLayer;
    CGPoint centerPoint;
    
    NSTimeInterval  lastTime;
    CGFloat lastEndScale;
}
@end

@implementation CKMJProgressHeader


#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 54);
    self.backgroundColor = [UIColor clearColor];
    lastTime = 0;
    lastEndScale = 0;
    
    
    centerPoint = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, 22);
    
    backgroundLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:12 startAngle:0 endAngle:(2 * M_PI) clockwise:YES];
    backgroundLayer.path = path.CGPath;
    backgroundLayer.strokeColor = [UIColor colorWithRed:230.0/255.0 green:230/255.0 blue:230/255.0 alpha:1].CGColor;
    backgroundLayer.fillColor = nil;
    backgroundLayer.lineWidth = 4;
    
    shapeLayer = [CAShapeLayer layer];
    UIBezierPath *spath = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:12 startAngle:0 endAngle:(2 * M_PI) clockwise:YES];
    shapeLayer.path = spath.CGPath;
    shapeLayer.strokeColor = [UIColor colorWithRed:71/255.0 green:157/255.0 blue:252/255.0 alpha:1].CGColor;
    shapeLayer.strokeStart = 0;
    shapeLayer.strokeEnd = 0;
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 4;

}

- (void)placeSubviews
{
    [super placeSubviews];
    
    CGRect aFrame = CGRectMake(0, 10, self.bounds.size.width, 54 - 10);
    backgroundLayer.frame = aFrame;
    shapeLayer.frame = aFrame;
    [self.layer addSublayer:backgroundLayer];
    [self.layer addSublayer:shapeLayer];
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    // 根据状态做事情
    if (state == MJRefreshStateIdle) {
        if(shapeLayer.strokeEnd == 0 )
        {
            shapeLayer.strokeEnd = 0;
            shapeLayer.strokeStart = 0;
            shapeLayer.lineCap = @"miter";
            
            [shapeLayer removeAllAnimations];
        }
    } else if (state == MJRefreshStatePulling) {

    } else if (state == MJRefreshStateRefreshing) {
        
        shapeLayer.strokeStart = 0.9f;
        shapeLayer.lineCap = @"round";
        [UIView animateWithDuration:0.5 animations:^{
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
            pathAnimation.duration = 0.5;
            pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
            pathAnimation.toValue = [NSNumber numberWithFloat:0.9f];
            pathAnimation.delegate =self;
            pathAnimation.removedOnCompletion = YES;
            [shapeLayer addAnimation:pathAnimation forKey:@"strokeStart"];
        
        }];
    }
}


- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    
    NSTimeInterval duration = 0;
    if(lastEndScale != 0) {
        NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
        duration = now  - lastTime;
        lastTime = now;
    }
    
    [UIView animateWithDuration:duration animations:^{
        CGFloat scale = (pullingPercent - 0.3 < 0 ? 0 : (pullingPercent - 0.3))/0.7;
        scale = scale > 1 ? 1 : scale ;
        shapeLayer.strokeEnd = scale;
        CGFloat tmpLastEndScale = lastEndScale;
        lastEndScale = scale;
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = 0.5;
        pathAnimation.fromValue = [NSNumber numberWithFloat:tmpLastEndScale];
        pathAnimation.toValue = [NSNumber numberWithFloat:scale];
        pathAnimation.removedOnCompletion = YES;
        [shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    }];
    
    
    NSLog(@"%f",shapeLayer.strokeEnd);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if(flag == YES) {
        CABasicAnimation *myAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        myAnimation.duration = 0.5;
        myAnimation.fromValue = @(0);
        myAnimation.toValue = @(M_PI * 2);
        myAnimation.repeatCount = INT_MAX;
        myAnimation.removedOnCompletion = YES;
        [shapeLayer addAnimation:myAnimation forKey:@"transform.rotation"];
    }
}

@end
