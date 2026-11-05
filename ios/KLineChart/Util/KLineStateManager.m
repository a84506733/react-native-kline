//
//  KLineStateManager.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "KLineStateManager.h"
#import "DataUtil.h"

static KLineStateManager *_manager = nil;

@interface KLineStateManager ()
- (instancetype)initPrivate;
@end

@implementation KLineStateManager

// `init` returns the singleton so that Swift's `KLineStateManager()`
// (which the RNKlineChartController port uses everywhere) resolves to the
// same instance as the ObjC `[KLineStateManager manager]` callers
// (KLineChartView / renderers). Without this, every Swift call created a
// throwaway instance and no state ever reached the chart.
- (instancetype)init
{
    return [KLineStateManager manager];
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _mainState = MainStateMA;
        _secondaryState = SecondaryStateMacd;
        _isLine = false;
    }
    return self;
}

+(instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] initPrivate];
    });
    return _manager;
}

- (void)setKlineChart:(KLineChartView *)klineChart {
    _klineChart = klineChart;
    _klineChart.mainState = _mainState;
    _klineChart.secondaryState = _secondaryState;
    _klineChart.isLine = _isLine;
    _klineChart.datas = _datas;
}

- (void)setDatas:(NSArray *)datas {
    _datas = datas;
    _klineChart.datas = datas;
}

- (void)setMainState:(MainState)mainState {
    _mainState = mainState;
    _klineChart.mainState = mainState;
}
-(void)setSecondaryState:(SecondaryState)secondaryState {
    _secondaryState = secondaryState;
    _klineChart.secondaryState = secondaryState;
}

-(void)setIsLine:(BOOL)isLine {
    _isLine = isLine;
    _klineChart.isLine = isLine;
}

@end
