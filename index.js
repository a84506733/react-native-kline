import React, { useEffect } from "react";
import ByronKlineNativeComponent, {
  Commands,
} from "./src/ByronKlineNativeComponent";

// Last mounted chart host component reference, used by `dispatchByronKline`.
// (Same semantics as the legacy implementation.)
let byronController = undefined;

/**
 * The iOS (Fabric) props parser is strictly typed: a numeric string such as
 * "1793843400" passed for a Double field arrives natively as NaN and ends up
 * in CoreGraphics APIs (crash / rendering glitches). Android (Gson) is lenient.
 * Normalize every numeric field on all JS entry points so both numbers and
 * numeric strings are accepted on both platforms.
 */
const toNumber = (value) => {
  const n = Number(value);
  return Number.isFinite(n) ? n : 0;
};

const normalizeKLineItem = (item) => {
  if (item == null) {
    return item;
  }
  const normalized = {
    ...item,
    id: toNumber(item.id),
    open: toNumber(item.open),
    high: toNumber(item.high),
    low: toNumber(item.low),
    close: toNumber(item.close),
    vol: toNumber(item.vol),
  };
  if (item.amount != null) {
    normalized.amount = toNumber(item.amount);
  }
  return normalized;
};

const normalizeKLineList = (list) =>
  Array.isArray(list) ? list.map(normalizeKLineItem) : list;

export const dispatchByronKline = (event = "init", list = []) => {
  if (!byronController) {
    return;
  }
  Commands.byronController(byronController, event, normalizeKLineList(list));
};

export const CandleHollow = {
  NONE_HOLLOW: 0,
  ALL_HOLLOW: 1,
  DECREASE_HOLLOW: 2,
  INCREASE_HOLLOW: 3,
};

export const KLineIndicator = {
  MainMA: 0,
  MainBOLL: 1,
  MainNONE: 2,
  ChildMACD: 3,
  ChildKDJ: 4,
  ChildRSI: 5,
  ChildWR: 6,
  ChildNONE: 7,
  TimeLineShow: 8,
  TimeLineHide: 9,
  VolumeShow: 10,
  VolumeHide: 11,
};

const KlineComponent = (props, forwardedRef) => {
  const { onMoreKLineData, datas, ...localProps } = props;
  const onMoreKLineDataEvent = onMoreKLineData
    ? (event) => onMoreKLineData(event.nativeEvent)
    : null;
  const _forwardedRef = (ref) => {
    byronController = ref;
    forwardedRef && forwardedRef(ref);
  };

  useEffect(() => {
    dispatchByronKline();
  }, []);

  return (
    <ByronKlineNativeComponent
      {...localProps}
      datas={normalizeKLineList(datas)}
      ref={_forwardedRef}
      onMoreKLineData={onMoreKLineDataEvent}
    />
  );
};

const ByronKlineChart = React.forwardRef(KlineComponent);

ByronKlineChart.defaultProps = {
  datas: [],
  locales: [],
  indicators: [],
  pricePrecision: 2,
  volumePrecision: 2,
  mainBackgroundColor: '#18181A',
  increaseColor: "#00BD9A",
  decreaseColor: "#FF6960",
};

export default ByronKlineChart;
