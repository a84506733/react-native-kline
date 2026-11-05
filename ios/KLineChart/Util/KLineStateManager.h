//
//  KLineStateManager.h
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLineChartView.h"
#import "KLineState.h"

NS_ASSUME_NONNULL_BEGIN

@interface KLineStateManager : NSObject

+(instancetype)manager;

@property(nonatomic,weak) KLineChartView *klineChart;

@property(nonatomic,assign) MainState mainState;
@property(nonatomic,assign) SecondaryState secondaryState;
@property(nonatomic,assign) BOOL isLine;

@property(nonatomic,strong) NSArray *datas;

@property(nonatomic,assign) NSNumber *pricePrecision;
@property(nonatomic,assign) NSNumber *volumePrecision;

@property(nonatomic,strong) NSArray *locales;

@property(nonatomic,strong) UIColor *increaseColor;//K线上涨颜色

@property(nonatomic,strong) UIColor *decreaseColor;//k线下跌颜色

@property(nonatomic,strong) UIColor *ma1Color;//m5颜色

@property(nonatomic,strong) UIColor *ma2Color;//m10颜色

@property(nonatomic,strong) UIColor *ma3Color;//m30颜色

@property(nonatomic,strong) UIColor *limitTextColor;//最大最小值颜色

// ---------------------------------------------------------------------------
// Runtime-configurable styles (react-native-kline props). nil = engine default,
// consumed via the RNKLColor/RNKLFloat macros below.
// ---------------------------------------------------------------------------
@property(nonatomic,strong,nullable) UIColor *gridLineColor;
@property(nonatomic,strong,nullable) UIColor *axisTextColor;//坐标轴文字颜色(labelTextColor/commonTextColor)
@property(nonatomic,strong,nullable) UIColor *macdIncreaseColor;
@property(nonatomic,strong,nullable) UIColor *macdDecreaseColor;
@property(nonatomic,strong,nullable) UIColor *macdColor;
@property(nonatomic,strong,nullable) UIColor *difColor;
@property(nonatomic,strong,nullable) UIColor *deaColor;
@property(nonatomic,strong,nullable) UIColor *kColor;
@property(nonatomic,strong,nullable) UIColor *dColor;
@property(nonatomic,strong,nullable) UIColor *jColor;
@property(nonatomic,strong,nullable) UIColor *rsiColor;
@property(nonatomic,strong,nullable) UIColor *wrColor;
@property(nonatomic,strong,nullable) UIColor *volMa1Color;
@property(nonatomic,strong,nullable) UIColor *volMa2Color;
@property(nonatomic,strong,nullable) UIColor *volLegendColor;
@property(nonatomic,strong,nullable) UIColor *timeLineColor;
@property(nonatomic,strong,nullable) UIColor *timeLineFillTopColor;
@property(nonatomic,strong,nullable) UIColor *timeLineFillBottomColor;
@property(nonatomic,strong,nullable) UIColor *timeLineEndPointColor;
@property(nonatomic,strong,nullable) UIColor *backgroundFillTopColor;
@property(nonatomic,strong,nullable) UIColor *backgroundFillBottomColor;

@property(nonatomic,strong,nullable) NSNumber *candleWidth;
@property(nonatomic,strong,nullable) NSNumber *candleLineWidth;
@property(nonatomic,strong,nullable) NSNumber *gridLineWidth;
@property(nonatomic,strong,nullable) NSNumber *gridRows;
@property(nonatomic,strong,nullable) NSNumber *gridColumns;
@property(nonatomic,strong,nullable) NSNumber *macdBarWidth;//macdWidth
@property(nonatomic,strong,nullable) NSNumber *topPadding;//mainMarginTop
@property(nonatomic,strong,nullable) NSNumber *bottomDateHigh;//paddingBottom
@property(nonatomic,strong,nullable) NSNumber *childPaddingTop;
@property(nonatomic,strong,nullable) NSNumber *axisTextSize;//labelTextSize
@property(nonatomic,strong,nullable) NSNumber *defaultTextSize;//commonTextSize
@property(nonatomic,strong,nullable) NSNumber *priceLineWidth;
@property(nonatomic,strong,nullable) NSNumber *priceLineDotSolidWidth;
@property(nonatomic,strong,nullable) NSNumber *priceLineDotStrokeWidth;
@property(nonatomic,strong,nullable) NSNumber *selectedXLineWidth;
@property(nonatomic,strong,nullable) NSNumber *selectedYLineWidth;
@property(nonatomic,strong,nullable) NSNumber *selectedCrossPointRadius;
@property(nonatomic,strong,nullable) NSNumber *timeLineEndRadius;
@property(nonatomic,strong,nullable) NSNumber *legendMarginLeft;
@property(nonatomic,strong,nullable) NSNumber *mainLegendMarginTop;
@property(nonatomic,strong,nullable) NSNumber *volLegendMarginTop;

@end



// Convenience accessors: configured value or engine default.
#define RNKLColor(prop, def) (([KLineStateManager manager].prop) ?: (def))
#define RNKLFloat(prop, def) (([KLineStateManager manager].prop) ? [[KLineStateManager manager].prop doubleValue] : (def))

NS_ASSUME_NONNULL_END
