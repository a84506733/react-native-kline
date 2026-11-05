//
//  SecondaryChartRenderer.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "SecondaryChartRenderer.h"
#import "ChartStyle.h"
#import "NSString+Rect.h"
#import "KLineStateManager.h"

@interface SecondaryChartRenderer()

@property(nonatomic,assign) SecondaryState state;
@property(nonatomic,assign) CGFloat mMACDWidth;
@end

@implementation SecondaryChartRenderer

- (instancetype)initWithMaxValue:(CGFloat)maxValue
                        minValue:(CGFloat)minValue
                       chartRect:(CGRect)chartRect
                     candleWidth:(CGFloat)candleWidth
                      topPadding:(CGFloat)topPadding
                           state:(SecondaryState)state
{
    if(self = [super initWithMaxValue:maxValue minValue:minValue chartRect:chartRect candleWidth:candleWidth topPadding:topPadding]) {
        self.state = state;
        self.mMACDWidth = RNKLFloat(macdBarWidth, 5);
    }
    return self;
}

- (void)drawGrid:(CGContextRef)context gridRows:(NSUInteger)gridRows gridColums:(NSUInteger)gridColums {
    CGContextSetStrokeColorWithColor(context, RNKLColor(gridLineColor, ChartColors_gridColor).CGColor);
    CGContextSetLineWidth(context, RNKLFloat(gridLineWidth, 0.5));
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
    if(_state == SecondaryStateMacd) {
        [self drawMACD:context lastPoit:lastPoint curPoint:curPoint curX:curX];
    } else if (_state == SecondaryStateKDJ) {
        if(lastPoint != nil) {
            if(curPoint.k != 0) {
                [self drawLine:context lastValue:lastPoint.k curValue:curPoint.k curX:curX color:RNKLColor(kColor, ChartColors_kColor)];
            }
            if(curPoint.d != 0) {
                [self drawLine:context lastValue:lastPoint.d curValue:curPoint.d curX:curX color:RNKLColor(dColor, ChartColors_dColor)];
            }
            if(curPoint.j != 0) {
                [self drawLine:context lastValue:lastPoint.j curValue:curPoint.j curX:curX color:RNKLColor(jColor, ChartColors_jColor)];
            }
        }
    } else if (_state == SecondaryStateRSI) {
        if(lastPoint != nil) {
            if(curPoint.rsi != 0) {
                [self drawLine:context lastValue:lastPoint.rsi curValue:curPoint.rsi curX:curX color:RNKLColor(rsiColor, ChartColors_rsiColor)];
            }
        }
    } else if (_state == SecondaryStateWR) {
           if(lastPoint != nil) {
               if(curPoint.r != 0) {
                   [self drawLine:context lastValue:lastPoint.r curValue:curPoint.r curX:curX color:RNKLColor(wrColor, ChartColors_wrColor)];
               }
           }
    }
}

- (void)drawMACD:(CGContextRef)context lastPoit:(KLineModel *)lastPoint curPoint:(KLineModel *)curPoint curX:(CGFloat)curX {
    CGFloat maxdY = [self getY:curPoint.macd];
    CGFloat zeroy = [self getY:0];
    if(curPoint.macd > 0) {
        CGContextSetStrokeColorWithColor(context, RNKLColor(macdIncreaseColor, [KLineStateManager manager].increaseColor).CGColor);
    } else {
        CGContextSetStrokeColorWithColor(context, RNKLColor(macdDecreaseColor, [KLineStateManager manager].decreaseColor).CGColor);
    }
    CGContextSetLineWidth(context, self.mMACDWidth);
    CGContextMoveToPoint(context, curX, maxdY);
    CGContextAddLineToPoint(context, curX, zeroy);
    CGContextDrawPath(context, kCGPathStroke);
    if(lastPoint != nil) {
        if(curPoint.dif != 0) {
             [self drawLine:context lastValue:lastPoint.dif curValue:curPoint.dif curX:curX color:RNKLColor(difColor, ChartColors_difColor)];
        }
        if(curPoint.dea != 0) {
             [self drawLine:context lastValue:lastPoint.dea curValue:curPoint.dea curX:curX color:RNKLColor(deaColor, ChartColors_deaColor)];
        }
    }
}
- (void)drawRightText:(CGContextRef)context gridRows:(NSUInteger)gridRows gridColums:(NSUInteger)gridColums {
    NSString *text = [self volFormat:self.maxValue];
    CGRect rect = [text getRectWithFontSize:ChartStyle_reightTextSize];
    [self drawText:text atPoint:CGPointMake(self.chartRect.size.width - rect.size.width, CGRectGetMinY(self.chartRect)) fontSize:RNKLFloat(axisTextSize, ChartStyle_reightTextSize) textColor:RNKLColor(axisTextColor, ChartColors_reightTextColor)];
}

- (void)drawTopText:(CGContextRef)context curPoint:(KLineModel *)curPoint {
    NSMutableAttributedString *topAttributeText = [[NSMutableAttributedString alloc] init];
    NSNumber *fixed = [KLineStateManager manager].pricePrecision;
    switch (_state) {
        case SecondaryStateMacd:
        {
            {
                NSString *str = @"MACD(12,26,9)    ";
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:RNKLFloat(defaultTextSize, ChartStyle_defaultTextSize)],NSForegroundColorAttributeName: ChartColors_yAxisTextColor}];
                 [topAttributeText appendAttributedString:attr];
             }
            if(curPoint.macd != 0) {
                 NSString *fixedStr = [NSString stringWithFormat:@"%@%@f", @"MACD:%.", fixed];
                 NSString *str = [NSString stringWithFormat:fixedStr, curPoint.macd];
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:[str stringByAppendingString:@"    "] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:RNKLFloat(defaultTextSize, ChartStyle_defaultTextSize)],NSForegroundColorAttributeName: RNKLColor(macdColor, ChartColors_macdColor)}];
                 [topAttributeText appendAttributedString:attr];
             }
            if(curPoint.dif != 0) {
                 NSString *fixedStr = [NSString stringWithFormat:@"%@%@f", @"DIF:%.", fixed];
                 NSString *str = [NSString stringWithFormat:fixedStr, curPoint.dif];
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:[str stringByAppendingString:@"    "] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:RNKLFloat(defaultTextSize, ChartStyle_defaultTextSize)],NSForegroundColorAttributeName: RNKLColor(difColor, ChartColors_difColor)}];
                 [topAttributeText appendAttributedString:attr];
             }
            if(curPoint.dea != 0) {
                 NSString *fixedStr = [NSString stringWithFormat:@"%@%@f", @"DEA:%.", fixed];
                 NSString *str = [NSString stringWithFormat:fixedStr, curPoint.dea];
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:[str stringByAppendingString:@"    "] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:RNKLFloat(defaultTextSize, ChartStyle_defaultTextSize)],NSForegroundColorAttributeName: RNKLColor(deaColor, ChartColors_deaColor)}];
                 [topAttributeText appendAttributedString:attr];
             }
        } break;
        case SecondaryStateRSI:
        {
            NSString *fixedStr = [NSString stringWithFormat:@"%@%@f", @"RSI(14):%.", fixed];
            NSString *str = [NSString stringWithFormat:fixedStr, curPoint.rsi];
            NSAttributedString *attr = [[NSAttributedString alloc] initWithString:[str stringByAppendingString:@"    "] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:RNKLFloat(defaultTextSize, ChartStyle_defaultTextSize)],NSForegroundColorAttributeName: RNKLColor(rsiColor, ChartColors_rsiColor)}];
            [topAttributeText appendAttributedString:attr];
        } break;
        case SecondaryStateWR:
        {
            NSString *fixedStr = [NSString stringWithFormat:@"%@%@f", @"WR(14):%.", fixed];
            NSString *str = [NSString stringWithFormat:fixedStr, curPoint.r];
            NSAttributedString *attr = [[NSAttributedString alloc] initWithString:[str stringByAppendingString:@"    "] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:RNKLFloat(defaultTextSize, ChartStyle_defaultTextSize)],NSForegroundColorAttributeName: RNKLColor(wrColor, ChartColors_wrColor)}];
            [topAttributeText appendAttributedString:attr];
        } break;
        case SecondaryStateKDJ:
        {
            {
                NSString *str = @"KDJ(14,1,3)    ";
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:RNKLFloat(defaultTextSize, ChartStyle_defaultTextSize)],NSForegroundColorAttributeName: ChartColors_yAxisTextColor}];
                 [topAttributeText appendAttributedString:attr];
             }
            if(curPoint.k != 0) {
                 NSString *fixedStr = [NSString stringWithFormat:@"%@%@f", @"K:%.", fixed];
                 NSString *str = [NSString stringWithFormat:fixedStr, curPoint.k];
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:[str stringByAppendingString:@"    "] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:RNKLFloat(defaultTextSize, ChartStyle_defaultTextSize)],NSForegroundColorAttributeName: RNKLColor(kColor, ChartColors_kColor)}];
                 [topAttributeText appendAttributedString:attr];
             }
            if(curPoint.d != 0) {
                 NSString *fixedStr = [NSString stringWithFormat:@"%@%@f", @"D:%.", fixed];
                 NSString *str = [NSString stringWithFormat:fixedStr, curPoint.d];
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:[str stringByAppendingString:@"    "] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:RNKLFloat(defaultTextSize, ChartStyle_defaultTextSize)],NSForegroundColorAttributeName: ChartColors_dColor}];
                 [topAttributeText appendAttributedString:attr];
             }
            if(curPoint.j != 0) {
                 NSString *fixedStr = [NSString stringWithFormat:@"%@%@f", @"J:%.", fixed];
                 NSString *str = [NSString stringWithFormat:fixedStr, curPoint.j];
                 NSAttributedString *attr = [[NSAttributedString alloc] initWithString:[str stringByAppendingString:@"    "] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:RNKLFloat(defaultTextSize, ChartStyle_defaultTextSize)],NSForegroundColorAttributeName: ChartColors_jColor}];
                 [topAttributeText appendAttributedString:attr];
             }
        } break;
        default:
            break;
    }
    [topAttributeText drawAtPoint:CGPointMake(5, CGRectGetMinY(self.chartRect))];
}



@end
