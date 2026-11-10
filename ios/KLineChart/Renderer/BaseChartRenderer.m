//
//  BaseChartRenderer.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "BaseChartRenderer.h"
#import "ChartStyle.h"
#import "KLineStateManager.h"
#import <math.h>


@implementation BaseChartRenderer

- (instancetype)initWithMaxValue:(CGFloat)maxValue
                        minValue:(CGFloat)minValue
                       chartRect:(CGRect)chartRect
                     candleWidth:(CGFloat)candleWidth
                      topPadding:(CGFloat)topPadding
{
    self = [super init];
    if (self) {
        // 所有纵坐标都来自 scaleY * (maxValue - value)。
        // 一旦区间为 0（只有一个/全平的行情点）或边界是 NaN/Inf，
        // scaleY 会变成 inf/NaN，getY 随后产生 NaN 并传给 CoreGraphics
        // （"invalid numeric value" + "no current point"）。
        // 在这里统一把区间修正成有限值，子类都受益。
        if (!isfinite(maxValue)) { maxValue = 0; }
        if (!isfinite(minValue)) { minValue = 0; }
        CGFloat range = maxValue - minValue;
        // 用相对 epsilon 判断平盘，避免把低币价（如 1e-8）的正常小区间误判为 0。
        CGFloat epsilon = fabs(maxValue) > 0 ? fabs(maxValue) * 1e-9 : 1e-12;
        if (!isfinite(range) || fabs(range) <= epsilon) {
            CGFloat base = maxValue;
            CGFloat padding = fabs(base) > 0 ? fabs(base) * 0.01 : 1.0;
            maxValue = base + padding;
            minValue = base - padding;
            range = maxValue - minValue;
        }
        self.maxValue = maxValue;
        self.minValue = minValue;
        self.chartRect = chartRect;
        self.candleWidth = candleWidth;
        self.topPadding = topPadding;
        _scaleY = (chartRect.size.height - topPadding) / range;
        // 视图尺寸退化（高度恰为 topPadding）时仍可能得到 0/inf，最后兜底。
        if (!isfinite(_scaleY) || _scaleY == 0) { _scaleY = 1; }
    }
    return self;
}

-(void)drawGrid:(CGContextRef)context
       gridRows:(NSUInteger)gridRows
     gridColums:(NSUInteger)gridColums {
    
}

-(void)drawRightText:(CGContextRef)context
            gridRows:(NSUInteger)gridRows
          gridColums:(NSUInteger)gridColums {

    
}

-(void)drawTopText:(CGContextRef)context
          curPoint:(KLineModel *)curPoint {
    
}
-(void)drawBg:(CGContextRef)context bgColor:(NSString*)color {
    CGContextClipToRect(context, _chartRect);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0,1};
    NSArray *colors = @[(__bridge id)RNKLColor(backgroundFillTopColor, [UIColor colorWithHexString:color]).CGColor, (__bridge id)RNKLColor(backgroundFillBottomColor, [UIColor colorWithHexString:color]).CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
    CGColorSpaceRelease(colorSpace);
    CGPoint start = CGPointMake(_chartRect.size.width / 2, CGRectGetMinY(_chartRect));
    CGPoint end = CGPointMake(_chartRect.size.width / 2, CGRectGetMaxY(_chartRect));
    CGContextDrawLinearGradient(context, gradient, start, end, 0);
    CGContextResetClip(context);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

-(void)drawChart:(CGContextRef)context
        lastPoit:(KLineModel *)lastPoint
        curPoint:(KLineModel *)curPoint
            curX:(CGFloat)curX {
    
}
-(void)drawLine:(CGContextRef)context
      lastValue:(CGFloat)lastValue
       curValue:(CGFloat)curValue
           curX:(CGFloat)curX
          color:(UIColor *)color {
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1);
    CGFloat x1 = curX;
    CGFloat y1 = [self getY:curValue];
    CGFloat x2 = curX + _candleWidth + ChartStyle_canldeMargin;
    CGFloat y2 = [self getY:lastValue];
    CGContextMoveToPoint(context, x1, y1);
    CGContextAddLineToPoint(context, x2, y2);
    CGContextDrawPath(context, kCGPathFillStroke);
}

-(void)drawText:(NSString *)text atPoint:(CGPoint)point fontSize:(CGFloat)size textColor:(UIColor *)color {
    [text drawAtPoint:point withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:size],NSForegroundColorAttributeName: color}];
}

-(CGFloat)getY:(CGFloat)value {
    CGFloat y = _scaleY * (_maxValue - value) + CGRectGetMinY(_chartRect) + _topPadding;
    // 最后一道防线：绝不把 NaN/Inf 坐标交给 CoreGraphics。
    if (!isfinite(y)) {
        return CGRectGetMinY(_chartRect) + _topPadding;
    }
    return y;
}

-(NSString *)volFormat:(CGFloat)value {
    NSNumber *fixed = [KLineStateManager manager].volumePrecision;
    NSString *fixedStr = [NSString stringWithFormat:@"%@%@f", @"%.", fixed];
    if (value > 10000 && value < 999999) {
         CGFloat d = value / 1000;
         NSString *k = [NSString stringWithFormat:fixedStr,d];
         return  [k stringByAppendingString:@"K"];
       } else if (value > 1000000) {
         CGFloat d = value / 1000000;
         NSString *m = [NSString stringWithFormat:fixedStr,d];
         return [m stringByAppendingString:@"M"];
       }
       return [NSString stringWithFormat:fixedStr,value];
    
}


@end
