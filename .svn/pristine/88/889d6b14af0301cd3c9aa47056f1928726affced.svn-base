//
//  CKCylinderReversibleFooter.m
//  BatourTool
//
//  Created by mac on 17/3/17.
//  Copyright © 2017年 GRSource. All rights reserved.
//

#import "CKCylinderReversibleFooter.h"

@interface CKCylinderReversibleFooter()<CAAnimationDelegate>
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

@property (assign, nonatomic) NSInteger lastRefreshCount;
@property (assign, nonatomic) CGFloat lastBottomDelta;
@end

@implementation CKCylinderReversibleFooter

+ (instancetype)footerWithPad:(CGFloat) pad RefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock
{
    CKCylinderReversibleFooter * header = [[self alloc] initWithPad:pad frame:CGRectZero];
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

- (void)prepare
{
    [super prepare];
    
    self.stateLabel.hidden = YES;
    
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
    shapeLayer.strokeEnd = 1;
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
    [super placeSubviews];
    

    if(self.cylinderColor) {
        shapeLayer.strokeColor = self.cylinderColor.CGColor;
    }
    [super placeSubviews];
    
    if(![self.layer.sublayers containsObject:backgroundLayer]) {
        [self.layer addSublayer:backgroundLayer];
    }
    if(![self.layer.sublayers containsObject:shapeLayer]) {
        [self.layer addSublayer:shapeLayer];
    }
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    // 根据状态做事情
    if (state == MJRefreshStateNoMoreData || state == MJRefreshStateIdle) {
        [shapeLayer removeAllAnimations];
    
        if(state == MJRefreshStateNoMoreData || state == MJRefreshStateIdle)
        {
            [CATransaction setDisableActions:YES];
            [shapeLayer setHidden:YES];
            [backgroundLayer setHidden: YES];
            [self.stateLabel setHidden:NO];
            [CATransaction setDisableActions:NO];
            
        }

            
    } else if (state == MJRefreshStateRefreshing) {
        [shapeLayer setHidden:NO];
        [backgroundLayer setHidden: NO];
        [self.stateLabel setHidden:YES];
        
        [shapeLayer removeAllAnimations];
        shapeLayer.lineCap = @"round";
        shapeLayer.strokeStart = 0;
        [UIView animateWithDuration:0.5 animations:^{
            if(![shapeLayer animationForKey:@"strokeStart"]) {
                [shapeLayer removeAnimationForKey:@"strokeStart"];
            }
            
            shapeLayer.strokeStart = 1 - 1.0/6;
        
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
            pathAnimation.duration = 0.5;
            pathAnimation.repeatCount = 1;
            pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
            pathAnimation.toValue = [NSNumber numberWithFloat: 1 - 1.0/6];
            pathAnimation.delegate =self;
            pathAnimation.removedOnCompletion = YES;
            [shapeLayer addAnimation:pathAnimation forKey:@"strokeStart"];
            
            [self resumeLayer:shapeLayer];
        
        }  completion:^(BOOL finished) {
            CAAnimation * animation = [shapeLayer animationForKey:@"strokeStart"];
            [shapeLayer removeAnimationForKey:@"strokeStart"];
            [self animationDidStop:animation finished:true];
        }];
        
    }
    
}


-(void) testBack:(MJRefreshState)state oldState:(MJRefreshState) oldState {
    
    // 根据状态来设置属性
    if (state == MJRefreshStateNoMoreData || state == MJRefreshStateIdle) {

        
        CGFloat deltaH = [self heightForContentBreakView];
        // 刚刷新完毕
        if (MJRefreshStateRefreshing == oldState && deltaH > 0 && self.scrollView.mj_totalDataCount != self.lastRefreshCount) {
            
        }
        else if(state == MJRefreshStateNoMoreData) {
            // 刷新完毕
            if (MJRefreshStateRefreshing == oldState) {
                [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
                    self.scrollView.mj_insetB -= self.lastBottomDelta;
                    
                    // 自动调整透明度
                    if (self.isAutomaticallyChangeAlpha) self.alpha = 0.0;
                } completion:^(BOOL finished) {
                    self.pullingPercent = 0.0;
                }];
            }
            
            self.scrollView.mj_offsetY = self.scrollView.mj_offsetY;
        }
    } else if (state == MJRefreshStateRefreshing) {
        // 记录刷新前的数量
        self.lastRefreshCount = self.scrollView.mj_totalDataCount;
        
        [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
            CGFloat bottom = self.mj_h + self.scrollViewOriginalInset.bottom;
            CGFloat deltaH = [self heightForContentBreakView];
            if (deltaH < 0) { // 如果内容高度小于view的高度
                bottom -= deltaH;
            }
            self.lastBottomDelta = bottom - self.scrollView.mj_insetB;
            self.scrollView.mj_insetB = bottom;
//            self.scrollView.mj_offsetY = [self happenOffsetY] + self.mj_h;
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - 私有方法
#pragma mark 获得scrollView的内容 超出 view 的高度
- (CGFloat)heightForContentBreakView
{
    CGFloat h = self.scrollView.frame.size.height - self.scrollViewOriginalInset.bottom - self.scrollViewOriginalInset.top;
    return self.scrollView.contentSize.height - h;
}

#pragma mark 刚好看到上拉刷新控件时的contentOffset.y
- (CGFloat)happenOffsetY
{
    CGFloat deltaH = [self heightForContentBreakView];
    if (deltaH > 0) {
        return deltaH - self.scrollViewOriginalInset.top;
    } else {
        return - self.scrollViewOriginalInset.top;
    }
}

- (void)endRefreshingWithMessage:(NSString *) str {
    [self setTitle:str forState:MJRefreshStateIdle];
    [self endRefreshing];
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if(flag == YES && self.state == MJRefreshStateRefreshing) {
        if(![shapeLayer animationForKey:@"transform.rotation"]) {
            [shapeLayer removeAnimationForKey:@"transform.rotation"];
        }
        
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
        
        NSLog(@"stopAnimation : %@",animationPull);
    }
}

-(void) startAnimation
{
    if(self.state == MJRefreshStateRefreshing ) {
        NSLog(@"startAnimation : %@",animationPull);
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
