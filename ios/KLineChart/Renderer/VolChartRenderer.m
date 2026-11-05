//
//  VolChartRenderer.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "VolChartRenderer.h"
#import "ChartStyle.h"
#import "NSString+Rect.h"
#import "KLineStateManager.h"

@implementation VolChartRenderer

- (void)drawGrid:(CGContextRef)context gridRows:(NSUInteger)gridRows gridColums:(NSUInteger)gridColums {
    CGContextSetStrokeColorWithColor(context, RNKLColor(gridLineColor, ChartColors_gridColor).CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGFloat columsSpace = self.chartRect.size.width / (CGFloat)(gridColums);
    for (int index = 0;  index < gridColums; index++) {
        CGContextMoveToPoint(context, index * columsSpace, 0);
        CGContextAddLineToPoint(context, index * columsSpace, CGRectGetMaxY(self.chartRect));
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    CGContextAddRect(context, self.chartRect);
    CGContextDrawPath(context, kCGPathStroke);
    
}
- (void)drawChart:(CGContextRef)context lastPoit:(KLineModel *)lastPoint curPoint:(KLineModel *)curPoint curX:(CGFloat)curX {
    [self drawVolChat:context curPoint:curPoint curX:curX];
    if(lastPoint != nil){
        if(curPoint.MA5Volume != 0) {
            [self drawLine:context lastValue:lastPoint.MA5Volume curValue:curPoint.MA5Volume curX:curX color:RNKLColor(volMa1Color, [KLineStateManager manager].ma1Color) ];
        }
        if(curPoint.MA10Volume != 0) {
            [self drawLine:context lastValue:lastPoint.MA10Volume curValue:curPoint.MA10Volume curX:curX color:RNKLColor(volMa2Color, [KLineStateManager manager].ma2Color)];
        }
    }
}

- (void)drawVolChat:(CGContextRef)context curPoint:(KLineModel *)curPoint curX:(CGFloat)curX {
    CGFloat top = [self getY:curPoint.vol];
    CGContextSetLineWidth(context, self.candleWidth);
    if(curPoint.close > curPoint.open) {
        CGContextSetStrokeColorWithColor(context, [KLineStateManager manager].increaseColor.CGColor);
    } else {
        CGContextSetStrokeColorWithColor(context, [KLineStateManager manager].decreaseColor.CGColor);
    }
    CGContextMoveToPoint(context, curX, CGRectGetMaxY(self.chartRect));
    CGContextAddLineToPoint(context, curX, top);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawTopText:(CGContextRef)context curPoint:(KLineModel *)curPoint {
    NSMutableAttributedString *topAttributeText = [[NSMutableAttributedString alloc] init];
    {
        NSString *str = [NSString stringWithFormat:@"VOL:%@   ", [self volFormat:curPoint.vol]];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:RNKLFloat(defaultTextSize, ChartStyle_defaultTextSize)],NSForegroundColorAttributeName: RNKLColor(volLegendColor, ChartColors_volColor)}];
        [topAttributeText appendAttributedString:attr];
    }
    {
        NSString *str = [NSString stringWithFormat:@"MA5:%@    ", [self volFormat:curPoint.MA5Volume]];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:RNKLFloat(defaultTextSize, ChartStyle_defaultTextSize)],NSForegroundColorAttributeName: [KLineStateManager manager].ma1Color }];
        [topAttributeText appendAttributedString:attr];
    }
   {
        NSString *str = [NSString stringWithFormat:@"MA10:%@   ",[self volFormat:curPoint.MA10Volume]];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:RNKLFloat(defaultTextSize, ChartStyle_defaultTextSize)],NSForegroundColorAttributeName: [KLineStateManager manager].ma2Color}];
        [topAttributeText appendAttributedString:attr];
    }
    [topAttributeText drawAtPoint:CGPointMake(RNKLFloat(legendMarginLeft, 5), CGRectGetMinY(self.chartRect) + RNKLFloat(volLegendMarginTop, 0))];
}

- (void)drawRightText:(CGContextRef)context gridRows:(NSUInteger)gridRows gridColums:(NSUInteger)gridColums {
    NSString *text = [self volFormat:self.maxValue];
    CGRect rect = [text getRectWithFontSize:ChartStyle_reightTextSize];
    [self drawText:text atPoint:CGPointMake(self.chartRect.size.width - rect.size.width, CGRectGetMinY(self.chartRect)) fontSize:RNKLFloat(axisTextSize, ChartStyle_reightTextSize) textColor:RNKLColor(axisTextColor, ChartColors_reightTextColor)];
}

@end
