//
//  KLineModel.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "KLineModel.h"
#import <math.h>

static CGFloat RNKLSanitizedNumber(id value) {
    if (![value respondsToSelector:@selector(doubleValue)]) {
        return 0;
    }
    double v = [value doubleValue];
    return isfinite(v) ? (CGFloat)v : 0;
}

@implementation KLineModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
        // Fabric props / KVC 不做数值校验：JS 侧的 undefined、字符串或
        // NaN 会原样变成 NaN 字段。只要有一个 NaN，MAX/MIN 宏就会被
        // 污染（比较对 NaN 恒为 false），max-min 变成 NaN，进而所有
        // 坐标都是 NaN。在入库处把非有限数归零，绘制层再兜底。
        self.id = RNKLSanitizedNumber(dict[@"id"]);
        self.open = RNKLSanitizedNumber(dict[@"open"]);
        self.high = RNKLSanitizedNumber(dict[@"high"]);
        self.low = RNKLSanitizedNumber(dict[@"low"]);
        self.close = RNKLSanitizedNumber(dict[@"close"]);
        self.vol = RNKLSanitizedNumber(dict[@"vol"]);
        self.amount = RNKLSanitizedNumber(dict[@"amount"]);
    }
    return self;
}

@end
