import React, { useEffect } from "react";
import ByronKlineNativeComponent, {
  Commands,
} from "./src/ByronKlineNativeComponent";

// Last mounted chart host component reference, used by `dispatchByronKline`.
// (Same semantics as the legacy implementation.)
let byronController = undefined;

export const dispatchByronKline = (event = "init", list = []) => {
  if (!byronController) {
    return;
  }
  Commands.byronController(byronController, event, list);
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
  const { onMoreKLineData, ...localProps } = props;
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
