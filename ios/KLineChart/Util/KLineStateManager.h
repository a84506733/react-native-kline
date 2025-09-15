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

@end

NS_ASSUME_NONNULL_END
