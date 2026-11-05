package com.byron.kline

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.viewmanagers.ByronKlineManagerDelegate
import com.facebook.react.viewmanagers.ByronKlineManagerInterface

/**
 * Fabric ViewManager for the ByronKline chart.
 *
 * Implements the codegen-generated interface so the generated
 * [ByronKlineManagerDelegate] drives prop/command dispatch on the new
 * architecture. All state lives on [RNKlineView] (per instance), the manager
 * stays stateless.
 */
@ReactModule(name = ByronKlineManager.NAME)
class ByronKlineManager :
    SimpleViewManager<RNKlineView>(), ByronKlineManagerInterface<RNKlineView> {

  private val delegate =
      ByronKlineManagerDelegate<RNKlineView, ByronKlineManager>(this)

  override fun getDelegate(): ViewManagerDelegate<RNKlineView> = delegate

  override fun getName(): String = NAME

  override fun createViewInstance(context: ThemedReactContext): RNKlineView =
      RNKlineView(context)

  override fun getExportedCustomBubblingEventTypeConstants(): Map<String, Any> =
      mapOf(
          "onMoreKLineData" to
              mapOf(
                  "phasedRegistrationNames" to
                      mapOf("bubbled" to "onMoreKLineData"),
              ),
      )

  // ----- commands -----

  override fun byronController(view: RNKlineView, event: String, list: ReadableArray?) {
    view.handleByronController(event, list)
  }

  // ----- data props -----

  override fun setDatas(view: RNKlineView, value: ReadableArray?) = view.updateDatas(value)

  override fun setLocales(view: RNKlineView, value: ReadableArray?) = view.updateLocales(value)

  override fun setIndicators(view: RNKlineView, value: ReadableArray?) =
      view.updateIndicators(value)

  override fun setPricePrecision(view: RNKlineView, value: Int) =
      view.updatePricePrecision(value)

  override fun setVolumePrecision(view: RNKlineView, value: Int) =
      view.updateVolumePrecision(value)

  // ----- colors -----

  override fun setMainBackgroundColor(view: RNKlineView, value: String?) =
      view.setMainBackgroundColor(value)

  override fun setIncreaseColor(view: RNKlineView, value: String?) = view.setIncreaseColor(value)

  override fun setDecreaseColor(view: RNKlineView, value: String?) = view.setDecreaseColor(value)

  override fun setLimitTextColor(view: RNKlineView, value: String?) = view.setLimitTextColor(value)

  override fun setMa1Color(view: RNKlineView, value: String?) = view.setMa1Color(value)

  override fun setMa2Color(view: RNKlineView, value: String?) = view.setMa2Color(value)

  override fun setMa3Color(view: RNKlineView, value: String?) = view.setMa3Color(value)

  override fun setMacdIncreaseColor(view: RNKlineView, value: String?) =
      view.setMacdIncreaseColor(value)

  override fun setMacdDecreaseColor(view: RNKlineView, value: String?) =
      view.setMacdDecreaseColor(value)

  override fun setMacdColor(view: RNKlineView, value: String?) = view.setMacdColor(value)

  override fun setDifColor(view: RNKlineView, value: String?) = view.setDifColor(value)

  override fun setDeaColor(view: RNKlineView, value: String?) = view.setDeaColor(value)

  override fun setWr1Color(view: RNKlineView, value: String?) = view.setWr1Color(value)

  override fun setWr2Color(view: RNKlineView, value: String?) = view.setWr2Color(value)

  override fun setWr3Color(view: RNKlineView, value: String?) = view.setWr3Color(value)

  override fun setKColor(view: RNKlineView, value: String?) = view.setKColor(value)

  override fun setDColor(view: RNKlineView, value: String?) = view.setDColor(value)

  override fun setJColor(view: RNKlineView, value: String?) = view.setJColor(value)

  override fun setRsi1Color(view: RNKlineView, value: String?) = view.setRsi1Color(value)

  override fun setRsi2Color(view: RNKlineView, value: String?) = view.setRsi2Color(value)

  override fun setRsi3Color(view: RNKlineView, value: String?) = view.setRsi3Color(value)

  override fun setVolMa1Color(view: RNKlineView, value: String?) = view.setVolMa1Color(value)

  override fun setVolMa2Color(view: RNKlineView, value: String?) = view.setVolMa2Color(value)

  override fun setVolLegendColor(view: RNKlineView, value: String?) = view.setVolLegendColor(value)

  override fun setVolLineChartColor(view: RNKlineView, value: String?) =
      view.setVolLineChartColor(value)

  override fun setGridLineColor(view: RNKlineView, value: String?) = view.setGridLineColor(value)

  override fun setLabelTextColor(view: RNKlineView, value: String?) = view.setLabelTextColor(value)

  override fun setCommonTextColor(view: RNKlineView, value: String?) =
      view.setCommonTextColor(value)

  override fun setTimeLineColor(view: RNKlineView, value: String?) = view.setTimeLineColor(value)

  override fun setTimeLineFillTopColor(view: RNKlineView, value: String?) =
      view.setTimeLineFillTopColor(value)

  override fun setTimeLineFillBottomColor(view: RNKlineView, value: String?) =
      view.setTimeLineFillBottomColor(value)

  override fun setTimeLineEndPointColor(view: RNKlineView, value: String?) =
      view.setTimeLineEndPointColor(value)

  override fun setBackgroundFillTopColor(view: RNKlineView, value: String?) =
      view.setBackgroundFillTopColor(value)

  override fun setBackgroundFillBottomColor(view: RNKlineView, value: String?) =
      view.setBackgroundFillBottomColor(value)

  override fun setPriceLineColor(view: RNKlineView, value: String?) = view.setPriceLineColor(value)

  override fun setPriceLineRightColor(view: RNKlineView, value: String?) =
      view.setPriceLineRightColor(value)

  override fun setPriceLabelRightTextColor(view: RNKlineView, value: String?) =
      view.setPriceLabelRightTextColor(value)

  override fun setPriceLabelRightBackgroundColor(view: RNKlineView, value: String?) =
      view.setPriceLabelRightBackgroundColor(value)

  override fun setPriceLabelInLineTextColor(view: RNKlineView, value: String?) =
      view.setPriceLabelInLineTextColor(value)

  override fun setPriceLabelInLineBoxBackgroundColor(view: RNKlineView, value: String?) =
      view.setPriceLabelInLineBoxBackgroundColor(value)

  override fun setPriceLabelInLineBoxBorderColor(view: RNKlineView, value: String?) =
      view.setPriceLabelInLineBoxBorderColor(value)

  override fun setSelectedXLabelBackgroundColor(view: RNKlineView, value: String?) =
      view.setSelectedXLabelBackgroundColor(value)

  override fun setSelectedXLineColor(view: RNKlineView, value: String?) =
      view.setSelectedXLineColor(value)

  override fun setSelectedYLineColor(view: RNKlineView, value: String?) =
      view.setSelectedYLineColor(value)

  override fun setSelectedYColor(view: RNKlineView, value: String?) = view.setSelectedYColor(value)

  override fun setSelectedCrossBigColor(view: RNKlineView, value: String?) =
      view.setSelectedCrossBigColor(value)

  override fun setSelectedCrossPointColor(view: RNKlineView, value: String?) =
      view.setSelectedCrossPointColor(value)

  override fun setSelectedPriceBoxBackgroundColor(view: RNKlineView, value: String?) =
      view.setSelectedPriceBoxBackgroundColor(value)

  override fun setSelectedInfoBoxTextColor(view: RNKlineView, value: String?) =
      view.setSelectedInfoBoxTextColor(value)

  override fun setSelectedInfoBoxBorderColor(view: RNKlineView, value: String?) =
      view.setSelectedInfoBoxBorderColor(value)

  override fun setSelectedInfoBoxBackgroundColor(view: RNKlineView, value: String?) =
      view.setSelectedInfoBoxBackgroundColor(value)

  override fun setSelectedLabelBorderColor(view: RNKlineView, value: String?) =
      view.setSelectedLabelBorderColor(value)

  // ----- sizes / metrics -----

  override fun setPriceLabelInLineTextSize(view: RNKlineView, value: Double) =
      view.setPriceLabelInLineTextSize(value)

  override fun setSelectedLabelTextSize(view: RNKlineView, value: Double) =
      view.setSelectedLabelTextSize(value)

  override fun setSelectedInfoTextSize(view: RNKlineView, value: Double) =
      view.setSelectedInfoTextSize(value)

  override fun setLabelTextSize(view: RNKlineView, value: Double) = view.setLabelTextSize(value)

  override fun setCommonTextSize(view: RNKlineView, value: Double) = view.setCommonTextSize(value)

  override fun setPriceLabelInLineBoxMarginRight(view: RNKlineView, value: Double) =
      view.setPriceLabelInLineBoxMarginRight(value)

  override fun setPriceLabelInLineShapeWidth(view: RNKlineView, value: Double) =
      view.setPriceLabelInLineShapeWidth(value)

  override fun setPriceLabelInLineShapeHeight(view: RNKlineView, value: Double) =
      view.setPriceLabelInLineShapeHeight(value)

  override fun setPriceLabelInLineBoxHeight(view: RNKlineView, value: Double) =
      view.setPriceLabelInLineBoxHeight(value)

  override fun setPriceLabelInLineBoxPadding(view: RNKlineView, value: Double) =
      view.setPriceLabelInLineBoxPadding(value)

  override fun setPriceLabelInLineBoxShapeTextMargin(view: RNKlineView, value: Double) =
      view.setPriceLabelInLineBoxShapeTextMargin(value)

  override fun setPriceLabelInLineBoxBorderWidth(view: RNKlineView, value: Double) =
      view.setPriceLabelInLineBoxBorderWidth(value)

  override fun setPriceLabelInLineBoxRadius(view: RNKlineView, value: Double) =
      view.setPriceLabelInLineBoxRadius(value)

  override fun setPriceLineRightLabelBackGroundAlpha(view: RNKlineView, value: Double) =
      view.setPriceLineRightLabelBackGroundAlpha(value)

  override fun setPriceLineWidth(view: RNKlineView, value: Double) = view.setPriceLineWidth(value)

  override fun setPriceLineDotSolidWidth(view: RNKlineView, value: Double) =
      view.setPriceLineDotSolidWidth(value)

  override fun setPriceLineDotStrokeWidth(view: RNKlineView, value: Double) =
      view.setPriceLineDotStrokeWidth(value)

  override fun setSelectedXLineWidth(view: RNKlineView, value: Double) =
      view.setSelectedXLineWidth(value)

  override fun setSelectedYLineWidth(view: RNKlineView, value: Double) =
      view.setSelectedYLineWidth(value)

  override fun setSelectedCrossPointRadius(view: RNKlineView, value: Double) =
      view.setSelectedCrossPointRadius(value)

  override fun setSelectedPriceBoxHorizontalPadding(view: RNKlineView, value: Double) =
      view.setSelectedPriceBoxHorizontalPadding(value)

  override fun setSelectedPriceBoxVerticalPadding(view: RNKlineView, value: Double) =
      view.setSelectedPriceBoxVerticalPadding(value)

  override fun setSelectedInfoBoxPadding(view: RNKlineView, value: Double) =
      view.setSelectedInfoBoxPadding(value)

  override fun setSelectedInfoBoxMargin(view: RNKlineView, value: Double) =
      view.setSelectedInfoBoxMargin(value)

  override fun setSelectedLabelBorderWidth(view: RNKlineView, value: Double) =
      view.setSelectedLabelBorderWidth(value)

  override fun setSelectedDateBoxVerticalPadding(view: RNKlineView, value: Double) =
      view.setSelectedDateBoxVerticalPadding(value)

  override fun setSelectedDateBoxHorizontalPadding(view: RNKlineView, value: Double) =
      view.setSelectedDateBoxHorizontalPadding(value)

  override fun setMainLegendMarginTop(view: RNKlineView, value: Double) =
      view.setMainLegendMarginTop(value)

  override fun setLegendMarginLeft(view: RNKlineView, value: Double) =
      view.setLegendMarginLeft(value)

  override fun setMainMarginTop(view: RNKlineView, value: Double) = view.setMainMarginTop(value)

  override fun setPaddingBottom(view: RNKlineView, value: Double) = view.setPaddingBottom(value)

  override fun setChildPaddingTop(view: RNKlineView, value: Double) =
      view.setChildPaddingTop(value)

  override fun setLineWidth(view: RNKlineView, value: Double) = view.setLineWidth(value)

  override fun setCandleWidth(view: RNKlineView, value: Double) = view.setCandleWidth(value)

  override fun setCandleLineWidth(view: RNKlineView, value: Double) =
      view.setCandleLineWidth(value)

  override fun setGridLineWidth(view: RNKlineView, value: Double) = view.setGridLineWidth(value)

  override fun setGridLineRows(view: RNKlineView, value: Double) = view.setGridLineRows(value)

  override fun setGridLineColumns(view: RNKlineView, value: Double) =
      view.setGridLineColumns(value)

  override fun setMacdStrokeWidth(view: RNKlineView, value: Double) =
      view.setMacdStrokeWidth(value)

  override fun setMacdWidth(view: RNKlineView, value: Double) = view.setMacdWidth(value)

  override fun setTimeLineEndRadius(view: RNKlineView, value: Double) =
      view.setTimeLineEndRadius(value)

  override fun setVolLegendMarginTop(view: RNKlineView, value: Double) =
      view.setVolLegendMarginTop(value)

  // ----- flags -----

  override fun setPriceLabelInLineClickable(view: RNKlineView, value: Boolean) =
      view.setPriceLabelInLineClickable(value)

  override fun setSelectedShowCrossPoint(view: RNKlineView, value: Boolean) =
      view.setSelectedShowCrossPoint(value)

  override fun setBetterXLabel(view: RNKlineView, value: Boolean) = view.setBetterXLabel(value)

  override fun setBetterSelectedXLabel(view: RNKlineView, value: Boolean) =
      view.setBetterSelectedXLabel(value)

  override fun setYLabelAlign(view: RNKlineView, value: Boolean) {
    // No-op on Android: the legacy Android manager did not implement this prop.
  }

  override fun setCandleHollow(view: RNKlineView, value: Int) = view.setCandleHollow(value)

  companion object {
    const val NAME = "ByronKline"
  }
}
