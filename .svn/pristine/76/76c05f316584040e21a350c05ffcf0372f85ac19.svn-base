//
//  CKCylinderReversibleHeader.m
//
//  Created by Mac on 17/3/14.
//  Copyright (c) 2017年 kaicheng. All rights reserved.
//

#import "CKCylinderReversibleHeader.h"
#import "NSBundle+MJRefresh.h"

#define HexRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

@interface CKCylinderReversibleHeader()<CAAnimationDelegate>
{
    CAShapeLayer * backgroundLayer;
    CAShapeLayer *shapeLayer;
    CGPoint centerPoint;
    
    NSTimeInterval  lastTime;
    CGFloat lastEndScale;
    CAAnimation * animationPull;
    BOOL isPaused;
    
    NSTimeInterval refreshingTime;
    NSTimeInterval lowRefreshTime;
}
@property(nonatomic,assign) CGFloat topPad;
@end

@implementation CKCylinderReversibleHeader


+ (instancetype)headerWithPad:(CGFloat) pad RefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock
{
    CKCylinderReversibleHeader * header = [[self alloc] initWithPad:pad frame:CGRectZero];
    header.refreshingBlock = refreshingBlock;
    return header;
}

#pragma mark - 重写父类的方法
- (instancetype)initWithPad:(CGFloat) pad frame:(CGRect) frame
{
    if (self = [super initWithFrame:frame]) {
        self.topPad = pad;
        [self prepare];
        self.state = MJRefreshStateIdle;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.state = MJRefreshStateIdle;
    }
    return self;
}

- (void)prepare
{
    [super prepare];
    self.backgroundColor = [UIColor clearColor];
    isPaused= NO;
    refreshingTime = 0;
    lowRefreshTime = 0.5;
    lastTime = 0;
    lastEndScale = 0;
    
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 54);
    centerPoint = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, 27 - self.topPad/2);
    CGRect aFrame = CGRectMake(0, self.topPad, self.bounds.size.width, 54 - self.topPad);
    
    backgroundLayer = [CAShapeLayer layer];
    backgroundLayer.frame = aFrame;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:12 startAngle:0 endAngle:(2 * M_PI) clockwise:YES];
    backgroundLayer.path = path.CGPath;
    backgroundLayer.strokeColor = [UIColor colorWithRed:230.0/255.0 green:230/255.0 blue:230/255.0 alpha:1].CGColor;
    backgroundLayer.fillColor = nil;
    backgroundLayer.lineWidth = 2;
    
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = aFrame;
    UIBezierPath *spath = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:12 startAngle:0 endAngle:(2 * M_PI) clockwise:YES];
    shapeLayer.strokeColor = [UIColor colorWithRed:71/255.0 green:157/255.0 blue:252/255.0 alpha:1].CGColor;
    shapeLayer.path = spath.CGPath;
    shapeLayer.strokeStart = 0;
    shapeLayer.strokeEnd = 0;
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 2;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willContinueAnimation) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willStopAnimation) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeUpdateNotification:) name:@"BackgroundColorUpdateNotification" object:nil];

}


-(void) themeUpdateNotification:(NSNotification*) notification
{
    UIColor * color = notification.object;
    self.cylinderColor = color;
    if(self.cylinderColor) {
        shapeLayer.strokeColor = self.cylinderColor.CGColor;
    }
}

- (void)placeSubviews
{
    if(self.cylinderColor) {
        shapeLayer.strokeColor = self.cylinderColor.CGColor;
    }
    [super placeSubviews];
    
    [self.layer addSublayer:backgroundLayer];
    [self.layer addSublayer:shapeLayer];
}


-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
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
        refreshingTime = [[NSDate date] timeIntervalSinceReferenceDate];
        [shapeLayer removeAllAnimations];
        shapeLayer.lineCap = @"round";
        [UIView animateWithDuration:0.5 animations:^{
            shapeLayer.strokeStart = 1 - 1.0/6;
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
            pathAnimation.duration = 0.5;
            pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
            pathAnimation.toValue = [NSNumber numberWithFloat: 1 - 1.0/6];
            pathAnimation.delegate =self;
            pathAnimation.removedOnCompletion = YES;
            [shapeLayer addAnimation:pathAnimation forKey:@"strokeStart"];
        
            [self resumeLayer:shapeLayer];
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
        pathAnimation.duration = duration;
        pathAnimation.fromValue = [NSNumber numberWithFloat:tmpLastEndScale];
        pathAnimation.toValue = [NSNumber numberWithFloat:scale];
        pathAnimation.removedOnCompletion = YES;
        [shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
        
        [self resumeLayer:shapeLayer];
    }];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if(flag == YES && self.state == MJRefreshStateRefreshing) {
        [shapeLayer removeAllAnimations];
        CABasicAnimation *myAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        myAnimation.duration = 1;
        myAnimation.fromValue = @(0);
        myAnimation.toValue = @(M_PI * 2);
        myAnimation.repeatCount = INT_MAX;
        myAnimation.removedOnCompletion = YES;
        [shapeLayer addAnimation:myAnimation forKey:@"transform.rotation"];
        
        [self resumeLayer:shapeLayer];
    }
}

-(void) willStopAnimation {
    [self stopAnimation];
}

-(void) willContinueAnimation
{
    [self startAnimation];
}

-(void)stopAnimation
{
    if(self.state == MJRefreshStateRefreshing ) {
        animationPull = [[shapeLayer animationForKey:@"transform.rotation"] copy];
        [self pauseLayer:shapeLayer];
    }
}

-(void) startAnimation
{
    if(self.state == MJRefreshStateRefreshing ) {
        if (animationPull != nil)
        {
            if([shapeLayer animationForKey:@"transform.rotation"])
            {
                [shapeLayer removeAnimationForKey:@"transform.rotation"];
            }
            [shapeLayer addAnimation:animationPull forKey:@"transform.rotation"];
            animationPull = nil;
        }
        [self resumeLayer:shapeLayer];
    }
}

-(void)pauseLayer:(CALayer*)layer
{
    if(!isPaused) {
        CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
        layer.speed = 0.0;
        layer.timeOffset = pausedTime;
        isPaused = YES;
    }
}

-(void)resumeLayer:(CALayer*)layer
{
    if(isPaused) {
        CFTimeInterval pausedTime = [layer timeOffset];
        layer.speed = 1.0;
        layer.timeOffset = 0.0;
        layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        layer.beginTime = timeSincePause;
        isPaused = NO;
    }
    
}

- (void)endRefreshing
{
    NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
    NSTimeInterval interval  = lowRefreshTime - (now - refreshingTime);
    if(interval <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.state = MJRefreshStateIdle;
        });
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.state = MJRefreshStateIdle;
        });
    }
}

@end
