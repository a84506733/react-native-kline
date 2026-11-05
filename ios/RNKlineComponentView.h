#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Fabric component view for the ByronKline chart (iOS).
 *
 * Bridges the codegen-generated C++ props/commands/event-emitter to the
 * Swift `RNKlineChartController` which hosts the chart engine.
 */
@interface RNKlineComponentView : RCTViewComponentView

@end

NS_ASSUME_NONNULL_END
