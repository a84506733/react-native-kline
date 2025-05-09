//
//  KLineInfoView.m
//  KLine-Chart-OC
//
//  Created by 何俊松 on 2020/3/10.
//  Copyright © 2020 hjs. All rights reserved.
//

#import "KLineInfoView.h"
#import "ChartStyle.h"
#import "KLineStateManager.h"
#import "DataUtil.h"

@interface KLineInfoView()
@property (weak, nonatomic) IBOutlet UILabel *timeLable;

@property (weak, nonatomic) IBOutlet UILabel *openLable;
@property (weak, nonatomic) IBOutlet UILabel *highLable;
@property (weak, nonatomic) IBOutlet UILabel *lowLabel;
@property (weak, nonatomic) IBOutlet UILabel *clsoeLabel;
@property (weak, nonatomic) IBOutlet UILabel *IncreaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *amplitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLable;

@property (weak, nonatomic) IBOutlet UILabel *timeText;

@property (weak, nonatomic) IBOutlet UILabel *openText;
@property (weak, nonatomic) IBOutlet UILabel *highText;
@property (weak, nonatomic) IBOutlet UILabel *lowText;
@property (weak, nonatomic) IBOutlet UILabel *clsoeText;
@property (weak, nonatomic) IBOutlet UILabel *IncreaseText;
@property (weak, nonatomic) IBOutlet UILabel *amplitudeText;
@property (weak, nonatomic) IBOutlet UILabel *amountText;

@end

@implementation KLineInfoView

+(instancetype)lineInfoView {
    KLineInfoView *view = [[NSBundle mainBundle] loadNibNamed:@"KLineInfoView" owner:self options:nil].lastObject;
    view.frame = CGRectMake(0, 0, 120, 145);
  if ([KLineStateManager manager].locales != nil && [KLineStateManager manager].locales.count > 6) {
   view.timeText.text = [KLineStateManager manager].locales[0];
    view.openText.text = [KLineStateManager manager].locales[1];
    view.highText.text = [KLineStateManager manager].locales[2];
    view.lowText.text = [KLineStateManager manager].locales[3];
    view.clsoeText.text = [KLineStateManager manager].locales[4];
    view.IncreaseText.text = [KLineStateManager manager].locales[5];
    view.amplitudeText.text = [KLineStateManager manager].locales[6];
    view.amountText.text = [KLineStateManager manager].locales[7];
  }
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = ChartColors_bgColor;
    self.layer.borderWidth = 1;
    self.layer.borderColor = ChartColors_gridColor.CGColor;
}

- (void)setModel:(KLineModel *)model {
    _model = model;
//    _timeLable.text =
    NSNumber *fixedPrice = [KLineStateManager manager].pricePrecision;
    NSNumber *fixedVolume = [KLineStateManager manager].volumePrecision;
    NSString *fixedPriceStr = [NSString stringWithFormat:@"%@%@f", @"%.", fixedPrice];
    NSString *fixedVolumeStr = [NSString stringWithFormat:@"%@%@f", @"%.", fixedVolume];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.id];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.dateFormat = @"yyyy-MM-dd HH:mm";
    _timeLable.text = [formater stringFromDate:date];
    
    _openLable.text = [DataUtil  formatDecimal:[NSNumber numberWithFloat:model.open]]; //[NSString stringWithFormat:fixedPriceStr,model.open];
    _highLable.text = [DataUtil  formatDecimal:[NSNumber numberWithFloat:model.high]];// [NSString stringWithFormat:fixedPriceStr,model.high];
    _lowLabel.text = [DataUtil  formatDecimal:[NSNumber numberWithFloat:model.low]]; //[NSString stringWithFormat:fixedPriceStr,model.low];
     _clsoeLabel.text = [DataUtil  formatDecimal:[NSNumber numberWithFloat:model.close]];// [NSString stringWithFormat:fixedPriceStr,model.close];
    CGFloat upDown = model.close - model.open;
    NSString *symbol = @"-";
    if(upDown > 0) {
        symbol = @"+";
        self.IncreaseLabel.textColor = [KLineStateManager manager].increaseColor;
        self.amplitudeLabel.textColor = [KLineStateManager manager].increaseColor;
    } else {
        self.IncreaseLabel.textColor = [KLineStateManager manager].decreaseColor;
        self.amplitudeLabel.textColor = [KLineStateManager manager].decreaseColor;
    }
    CGFloat upDownPercent = 0.0;
    if (model.open != 0) {
      upDownPercent = upDown / model.open * 100;
    }
    _IncreaseLabel.text = [NSString stringWithFormat:@"%@%.2f",symbol,ABS(upDown)];
    _amplitudeLabel.text = [NSString stringWithFormat:@"%@%.2f%%",symbol,ABS(upDownPercent)];
    _amountLable.text = [NSString stringWithFormat:fixedVolumeStr,model.vol];
    
}

@end
