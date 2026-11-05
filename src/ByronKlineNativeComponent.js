// @flow strict-local

/**
 * react-native-kline Fabric Native Component spec.
 *
 * Field names and prop names intentionally match the legacy (paper)
 * implementation one-to-one, to keep the JavaScript API identical.
 */

import type {ViewProps} from 'react-native/Libraries/Components/View/ViewPropTypes';
import type {HostComponent} from 'react-native';
import type {
  BubblingEventHandler,
  Double,
  Int32,
} from 'react-native/Libraries/Types/CodegenTypes';

import {codegenNativeCommands, codegenNativeComponent} from 'react-native';
import * as React from 'react';

/** Single K-line candle item; parsed natively (Gson on Android, KVC on iOS). */
type KLineDataItem = $ReadOnly<{|
  id: Double,
  open: Double,
  high: Double,
  low: Double,
  close: Double,
  vol: Double,
  amount?: ?Double,
|}>;

type MoreKLineDataEvent = $ReadOnly<{|
  id: Double,
|}>;

type NativeProps = $ReadOnly<{|
  ...ViewProps,

  // data
  datas?: ?$ReadOnlyArray<KLineDataItem>,
  locales?: ?$ReadOnlyArray<string>,
  indicators?: ?$ReadOnlyArray<Int32>,
  pricePrecision?: ?Int32,
  volumePrecision?: ?Int32,

  // colors
  mainBackgroundColor?: ?string,
  increaseColor?: ?string,
  decreaseColor?: ?string,
  limitTextColor?: ?string,
  ma1Color?: ?string,
  ma2Color?: ?string,
  ma3Color?: ?string,
  macdIncreaseColor?: ?string,
  macdDecreaseColor?: ?string,
  macdColor?: ?string,
  difColor?: ?string,
  deaColor?: ?string,
  wr1Color?: ?string,
  wr2Color?: ?string,
  wr3Color?: ?string,
  kColor?: ?string,
  dColor?: ?string,
  jColor?: ?string,
  rsi1Color?: ?string,
  rsi2Color?: ?string,
  rsi3Color?: ?string,
  volMa1Color?: ?string,
  volMa2Color?: ?string,
  volLegendColor?: ?string,
  volLineChartColor?: ?string,
  gridLineColor?: ?string,
  labelTextColor?: ?string,
  commonTextColor?: ?string,
  timeLineColor?: ?string,
  timeLineFillTopColor?: ?string,
  timeLineFillBottomColor?: ?string,
  timeLineEndPointColor?: ?string,
  backgroundFillTopColor?: ?string,
  backgroundFillBottomColor?: ?string,
  priceLineColor?: ?string,
  priceLineRightColor?: ?string,
  priceLabelRightTextColor?: ?string,
  priceLabelRightBackgroundColor?: ?string,
  priceLabelInLineTextColor?: ?string,
  priceLabelInLineBoxBackgroundColor?: ?string,
  priceLabelInLineBoxBorderColor?: ?string,
  selectedXLabelBackgroundColor?: ?string,
  selectedXLineColor?: ?string,
  selectedYLineColor?: ?string,
  selectedYColor?: ?string,
  selectedCrossBigColor?: ?string,
  selectedCrossPointColor?: ?string,
  selectedPriceBoxBackgroundColor?: ?string,
  selectedInfoBoxTextColor?: ?string,
  selectedInfoBoxBorderColor?: ?string,
  selectedInfoBoxBackgroundColor?: ?string,
  selectedLabelBorderColor?: ?string,

  // sizes / metrics
  priceLabelInLineTextSize?: ?Double,
  selectedLabelTextSize?: ?Double,
  selectedInfoTextSize?: ?Double,
  labelTextSize?: ?Double,
  commonTextSize?: ?Double,
  priceLabelInLineBoxMarginRight?: ?Double,
  priceLabelInLineShapeWidth?: ?Double,
  priceLabelInLineShapeHeight?: ?Double,
  priceLabelInLineBoxHeight?: ?Double,
  priceLabelInLineBoxPadding?: ?Double,
  priceLabelInLineBoxShapeTextMargin?: ?Double,
  priceLabelInLineBoxBorderWidth?: ?Double,
  priceLabelInLineBoxRadius?: ?Double,
  priceLineRightLabelBackGroundAlpha?: ?Double,
  priceLineWidth?: ?Double,
  priceLineDotSolidWidth?: ?Double,
  priceLineDotStrokeWidth?: ?Double,
  selectedXLineWidth?: ?Double,
  selectedYLineWidth?: ?Double,
  selectedCrossPointRadius?: ?Double,
  selectedPriceBoxHorizontalPadding?: ?Double,
  selectedPriceBoxVerticalPadding?: ?Double,
  selectedInfoBoxPadding?: ?Double,
  selectedInfoBoxMargin?: ?Double,
  selectedLabelBorderWidth?: ?Double,
  selectedDateBoxVerticalPadding?: ?Double,
  selectedDateBoxHorizontalPadding?: ?Double,
  mainLegendMarginTop?: ?Double,
  legendMarginLeft?: ?Double,
  mainMarginTop?: ?Double,
  paddingBottom?: ?Double,
  childPaddingTop?: ?Double,
  lineWidth?: ?Double,
  candleWidth?: ?Double,
  candleLineWidth?: ?Double,
  gridLineWidth?: ?Double,
  gridLineRows?: ?Double,
  gridLineColumns?: ?Double,
  macdStrokeWidth?: ?Double,
  macdWidth?: ?Double,
  timeLineEndRadius?: ?Double,
  volLegendMarginTop?: ?Double,

  // flags
  priceLabelInLineClickable?: ?boolean,
  selectedShowCrossPoint?: ?boolean,
  betterXLabel?: ?boolean,
  betterSelectedXLabel?: ?boolean,
  yLabelAlign?: ?boolean,
  candleHollow?: ?Int32,

  // events
  /** Fired when the chart is scrolled to the left edge and needs older data. */
  onMoreKLineData?: ?BubblingEventHandler<MoreKLineDataEvent>,
|}>;

type NativeType = HostComponent<NativeProps>;

interface NativeCommands {
  /**
   * Data channel command.
   * event: 'init' | 'update' (refresh last candle) | 'add' (append older data).
   */
  +byronController: (
    viewRef: React.ElementRef<NativeType>,
    event: string,
    list: $ReadOnlyArray<KLineDataItem>,
  ) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['byronController'],
});

export default (codegenNativeComponent<NativeProps>(
  'ByronKline',
): NativeType);
