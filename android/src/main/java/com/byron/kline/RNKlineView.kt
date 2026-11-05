package com.byron.kline

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.FrameLayout
import com.byron.kline.adapter.KLineChartAdapter
import com.byron.kline.formatter.ValueFormatter
import com.byron.kline.utils.SlidListener
import com.byron.kline.utils.Status
import com.byron.kline.view.KChartView
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.events.Event
import com.facebook.react.uimanager.events.EventDispatcher
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.util.Locale

/**
 * Host view for the ByronKline Fabric component.
 *
 * Owns all per-instance chart state (adapter, chart view, request status).
 * The legacy implementation kept this state on the ViewManager singleton,
 * which broke multi-instance usage; moving it here fixes that.
 */
class RNKlineView(context: Context) : FrameLayout(context) {

  private val chartView: KChartView
  private val adapter = KLineChartAdapter<KChartBean>()
  private val gson = Gson()

  @Volatile private var requestStatus = false

  // Latent colors that are applied together (same behavior as legacy manager).
  private var selectedInfoBoxTextColor: String? = null
  private var selectedInfoBoxBorderColor: String? = null
  private var selectedInfoBoxBackgroundColor: String? = null
  private var macdIncreaseColor: String? = null
  private var macdDecreaseColor: String? = null

  private var pricePrecision = 2
  private var volumePrecision = 2

  init {
    inflate(context, R.layout.kline, this)
    findViewById<View>(R.id.container).visibility = VISIBLE
    chartView = findViewById(R.id.kLineChartView)
    initChartView()
  }

  private fun initChartView() {
    val dm = resources.displayMetrics
    chartView.setGridColumns(5).setGridRows(5).setOverScrollRange(dm.widthPixels / 5.0f)
    chartView.setAdapter(adapter)
    chartView.setSlidListener(object : SlidListener {
      override fun onSlidLeft() {
        if (requestStatus) {
          return
        }
        requestStatus = true
        emitMoreKLineData()
      }

      override fun onSlidRight() {}
    })
  }

  // ---------------------------------------------------------------------
  // Commands ('byronController')
  // ---------------------------------------------------------------------

  fun handleByronController(event: String?, list: ReadableArray?) {
    when (event) {
      "init" -> {
        // The chart is fully configured in init{}; kept for API compatibility.
      }
      "update" -> {
        val datas = adapter.datas ?: return
        if (datas.size < 2) {
          return
        }
        val beans = parseBeans(list) ?: return
        if (beans.isEmpty()) {
          return
        }
        val bar = beans[0]
        val count = datas.size
        val last1 = count - 1
        val last2 = count - 2
        val differ = datas[last1].id - datas[last2].id
        val limit = datas[last1].id + differ
        if (bar.id < limit) {
          bar.id = datas[last1].id
          adapter.changeItem(last1, bar)
        } else {
          adapter.addLast(bar)
        }
      }
      "add" -> {
        val beans = parseBeans(list) ?: return
        adapter.addFooterData(beans)
        if (requestStatus) {
          requestStatus = false
        }
      }
    }
  }

  private fun parseBeans(list: ReadableArray?): List<KChartBean>? {
    if (list == null) {
      return null
    }
    val array = list.toArrayList()
    if (array.isEmpty()) {
      return null
    }
    val json = gson.toJson(array)
    return gson.fromJson(json, object : TypeToken<List<KChartBean>>() {}.type)
  }

  // ---------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------

  private fun emitMoreKLineData() {
    val datas = adapter.datas
    if (datas.isNullOrEmpty()) {
      return
    }
    val reactContext = context as? ThemedReactContext ?: return
    val eventDispatcher: EventDispatcher? =
        UIManagerHelper.getEventDispatcherForReactTag(reactContext, id)
    if (eventDispatcher == null) {
      return
    }
    val surfaceId = UIManagerHelper.getSurfaceId(reactContext)
    eventDispatcher.dispatchEvent(MoreKLineDataEvent(surfaceId, id, datas[0].id))
  }

  private class MoreKLineDataEvent(
      surfaceId: Int,
      viewId: Int,
      private val dataId: Long,
  ) : Event<MoreKLineDataEvent>(surfaceId, viewId) {

    override fun getEventName(): String = "onMoreKLineData"

    override fun getEventData(): WritableMap =
        Arguments.createMap().apply { putDouble("id", dataId.toDouble()) }
  }

  // ---------------------------------------------------------------------
  // Data props
  // ---------------------------------------------------------------------

  fun updateDatas(datas: ReadableArray?) {
    if (datas == null) {
      return
    }
    val size = datas.size()
    if (size == 0) {
      adapter.resetData(ArrayList(), true)
      return
    }
    val beans: List<KChartBean> =
        gson.fromJson(gson.toJson(datas.toArrayList()), object : TypeToken<List<KChartBean>>() {}.type)
    adapter.resetData(beans, true)
  }

  fun updateLocales(locales: ReadableArray?) {
    if (locales == null || locales.size() == 0) {
      return
    }
    val labels: Array<String> =
        gson.fromJson(gson.toJson(locales.toArrayList()), object : TypeToken<Array<String>>() {}.type)
    chartView.setSelectedInfoLabels(labels)
  }

  fun updateIndicators(indicators: ReadableArray?) {
    if (indicators == null) {
      return
    }
    val list = indicators.toArrayList()
    if (list.isEmpty()) {
      initKLineState()
      return
    }
    for (item in list) {
      changeKLineState(item)
    }
  }

  fun updatePricePrecision(value: Int) {
    pricePrecision = value
    chartView.setValueFormatter(object : ValueFormatter() {
      override fun format(value: Float): String =
          String.format(Locale.CHINA, "%." + pricePrecision + "f", value)
    })
  }

  fun updateVolumePrecision(value: Int) {
    volumePrecision = value
    chartView.setVolFormatter(object : ValueFormatter() {
      override fun format(value: Float): String =
          String.format(Locale.CHINA, "%." + volumePrecision + "f", value)
    })
  }

  // ---------------------------------------------------------------------
  // Indicator state (ported from legacy manager)
  // ---------------------------------------------------------------------

  private fun initKLineState() {
    chartView.hideSelectData()
    chartView.changeMainDrawType(Status.MainStatus.NONE)
    chartView.setIndexDraw(Status.IndexStatus.NONE)
    chartView.setKlineState(Status.KlineStatus.K_LINE)
    chartView.setVolShowState(false)
  }

  private fun changeKLineState(status: Any?) {
    if (status == null) {
      return
    }
    when (status.toString()) {
      "0.0" -> { // MainMA
        chartView.hideSelectData()
        chartView.changeMainDrawType(Status.MainStatus.MA)
      }
      "1.0" -> { // MainBOLL
        chartView.hideSelectData()
        chartView.changeMainDrawType(Status.MainStatus.BOLL)
      }
      "2.0" -> { // MainNONE
        chartView.hideSelectData()
        chartView.changeMainDrawType(Status.MainStatus.NONE)
      }
      "3.0" -> { // ChildMACD
        chartView.hideSelectData()
        chartView.setIndexDraw(Status.IndexStatus.MACD)
      }
      "4.0" -> { // ChildKDJ
        chartView.hideSelectData()
        chartView.setIndexDraw(Status.IndexStatus.KDJ)
      }
      "5.0" -> { // ChildRSI
        chartView.hideSelectData()
        chartView.setIndexDraw(Status.IndexStatus.RSI)
      }
      "6.0" -> { // ChildWR
        chartView.hideSelectData()
        chartView.setIndexDraw(Status.IndexStatus.WR)
      }
      "7.0" -> { // ChildNONE
        chartView.hideSelectData()
        chartView.setIndexDraw(Status.IndexStatus.NONE)
      }
      "8.0" -> { // TimeLineShow
        chartView.hideSelectData()
        chartView.setKlineState(Status.KlineStatus.TIME_LINE)
      }
      "9.0" -> { // TimeLineHide
        chartView.hideSelectData()
        chartView.setKlineState(Status.KlineStatus.K_LINE)
      }
      "10.0" -> chartView.setVolShowState(true) // VolumeShow
      "11.0" -> chartView.setVolShowState(false) // VolumeHide
    }
  }

  // ---------------------------------------------------------------------
  // Style props (mapping preserved 1:1 from the legacy ByronKlineManager)
  // ---------------------------------------------------------------------

  private fun color(value: String?): Int = Color.parseColor(value)

  fun setMainBackgroundColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setBackgroundColor(color(value))
  }

  fun setIncreaseColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setIncreaseColor(color(value))
  }

  fun setDecreaseColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setDecreaseColor(color(value))
  }

  fun setSelectedXLabelBackgroundColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setSelectedXLabelBackgroundColor(color(value))
  }

  fun setPriceLabelInLineTextColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setPriceLabelInLineTextColor(color(value))
  }

  fun setPriceLabelInLineTextSize(value: Double) {
    if (value == 0.0) return
    chartView.setPriceLabelInLineTextSize(value.toFloat())
  }

  fun setSelectedLabelTextColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setSelectedXLabelTextColor(color(value))
  }

  fun setSelectedLabelTextSize(value: Double) {
    if (value == 0.0) return
    chartView.setSelectedXLabelTextSize(value.toFloat())
  }

  fun setPriceLabelInLineBoxMarginRight(value: Double) {
    if (value == 0.0) return
    chartView.setPriceLabelInLineMarginRight(value.toFloat())
  }

  fun setPriceLabelInLineShapeWidth(value: Double) {
    if (value == 0.0) return
    chartView.setPriceLabelInLineShapeWidth(value.toFloat())
  }

  fun setPriceLabelInLineShapeHeight(value: Double) {
    if (value == 0.0) return
    chartView.setPriceLabelInLineShapeHeight(value.toFloat())
  }

  fun setPriceLabelInLineBoxHeight(value: Double) {
    if (value == 0.0) return
    chartView.setPriceLabelInLineBoxHeight(value.toFloat())
  }

  fun setPriceLabelInLineBoxPadding(value: Double) {
    if (value == 0.0) return
    chartView.setPriceLabelInLineBoxPadding(value.toFloat())
  }

  fun setPriceLabelInLineBoxShapeTextMargin(value: Double) {
    if (value == 0.0) return
    chartView.setPriceLabelInLineShapeTextMargin(value.toFloat())
  }

  fun setPriceLabelInLineClickable(value: Boolean) {
    if (!value) return
    chartView.setPriceLabelInLineClickable(value)
  }

  fun setPriceLabelInLineBoxBackgroundColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setPriceLabelInLineBoxBackgroundColor(color(value))
  }

  fun setPriceLabelRightBackgroundColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setPriceLabelRightBackgroundColor(color(value))
  }

  fun setPriceLabelInLineBoxBorderColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setPriceLabelInLineBoxBorderColor(color(value))
  }

  fun setPriceLabelInLineBoxBorderWidth(value: Double) {
    if (value == 0.0) return
    chartView.setPriceLabelInLineBoxBorderWidth(value.toFloat())
  }

  fun setPriceLabelInLineBoxRadius(value: Double) {
    if (value == 0.0) return
    chartView.setPriceLabelInLineBoxRadius(value.toFloat())
  }

  fun setPriceLineRightLabelBackGroundAlpha(value: Double) {
    if (value == 0.0) return
    chartView.setPriceLabelRightBackgroundAlpha(value.toInt())
  }

  fun setPriceLabelRightTextColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setPriceLabelRightTextColor(color(value))
  }

  fun setPriceLineRightColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setPriceLineRightColor(color(value))
  }

  fun setPriceLineWidth(value: Double) {
    if (value == 0.0) return
    chartView.setPriceLineWidth(value.toFloat())
  }

  fun setPriceLineColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setPriceLineColor(color(value))
  }

  fun setPriceLineDotSolidWidth(value: Double) {
    if (value == 0.0) return
    chartView.setPriceLineDotSolidWidth(value.toFloat())
  }

  fun setPriceLineDotStrokeWidth(value: Double) {
    if (value == 0.0) return
    chartView.setPriceLineDotStrokeWidth(value.toFloat())
  }

  fun setSelectedXLineWidth(value: Double) {
    if (value == 0.0) return
    chartView.setSelectedXLineWidth(value.toFloat())
  }

  fun setSelectedYLineWidth(value: Double) {
    if (value == 0.0) return
    chartView.setSelectedYLineWidth(value.toFloat())
  }

  fun setSelectedXLineColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setSelectedXLineColor(color(value))
  }

  fun setSelectedYLineColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setSelectedYLineColor(color(value))
  }

  fun setSelectedYColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setSelectedYColor(color(value))
  }

  fun setSelectedCrossBigColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setSelectedCrossBigColor(color(value))
  }

  fun setSelectedCrossPointRadius(value: Double) {
    if (value == 0.0) return
    chartView.setSelectedPointRadius(value.toFloat())
  }

  fun setSelectedCrossPointColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setSelectedPointColor(color(value))
  }

  fun setSelectedShowCrossPoint(value: Boolean) {
    if (!value) return
    chartView.setSelectedShowCrossPoint(value)
  }

  fun setSelectedPriceBoxBackgroundColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setSelectedPriceBoxBackgroundColor(color(value))
  }

  fun setSelectedInfoTextSize(value: Double) {
    if (value == 0.0) return
    chartView.setSelectedInfoTextSize(value.toFloat())
  }

  fun setSelectedPriceBoxHorizontalPadding(value: Double) {
    if (value == 0.0) return
    chartView.setSelectedPriceBoxHorizentalPadding(value.toFloat())
  }

  fun setSelectedPriceBoxVerticalPadding(value: Double) {
    if (value == 0.0) return
    chartView.setSelectedPriceboxVerticalPadding(value.toFloat())
  }

  fun setSelectedInfoBoxPadding(value: Double) {
    if (value == 0.0) return
    chartView.setSelectInfoBoxPadding(value.toFloat())
  }

  fun setSelectedInfoBoxMargin(value: Double) {
    if (value == 0.0) return
    chartView.setSelectInfoBoxMargin(value.toFloat())
  }

  fun setSelectedInfoBoxTextColor(value: String?) {
    if (value.isNullOrBlank()) return
    selectedInfoBoxTextColor = value
    refreshInfoBoxColors()
  }

  fun setSelectedInfoBoxBorderColor(value: String?) {
    if (value.isNullOrBlank()) return
    selectedInfoBoxBorderColor = value
    refreshInfoBoxColors()
  }

  fun setSelectedInfoBoxBackgroundColor(value: String?) {
    if (value.isNullOrBlank()) return
    selectedInfoBoxBackgroundColor = value
    refreshInfoBoxColors()
  }

  private fun refreshInfoBoxColors() {
    val textColor = selectedInfoBoxTextColor
    val borderColor = selectedInfoBoxBorderColor
    val backgroundColor = selectedInfoBoxBackgroundColor
    if (textColor == null || borderColor == null || backgroundColor == null) {
      return
    }
    chartView.setSelectInfoBoxColors(color(textColor), color(borderColor), color(backgroundColor))
  }

  fun setSelectedLabelBorderWidth(value: Double) {
    if (value == 0.0) return
    chartView.setSelectedXLabelBorderWidth(value.toFloat())
  }

  fun setSelectedLabelBorderColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setSelectedXLabelBorderColor(color(value))
  }

  fun setBackgroundFillTopColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setBackGroundFillTopColor(color(value))
  }

  fun setBackgroundFillBottomColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setBackGroundFillBottomColor(color(value))
  }

  fun setTimeLineColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setTimeLineColor(color(value))
  }

  fun setTimeLineFillTopColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setTimeLineFillTopColor(color(value))
  }

  fun setTimeLineFillBottomColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setTimeLineFillBottomColor(color(value))
  }

  fun setTimeLineEndPointColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setTimeLineEndColor(color(value))
  }

  fun setTimeLineEndRadius(value: Double) {
    if (value == 0.0) return
    chartView.setTimeLineEndRadius(value.toFloat())
  }

  fun setSelectedDateBoxVerticalPadding(value: Double) {
    if (value == 0.0) return
    chartView.setSelectedDateBoxVerticalPadding(value.toFloat())
  }

  fun setSelectedDateBoxHorizontalPadding(value: Double) {
    if (value == 0.0) return
    chartView.setSelectedDateBoxHorizontalPadding(value.toFloat())
  }

  fun setMainLegendMarginTop(value: Double) {
    if (value == 0.0) return
    chartView.setMainLegendMarginTop(value.toFloat())
  }

  fun setLegendMarginLeft(value: Double) {
    if (value == 0.0) return
    chartView.setLegendMarginLeft(value.toFloat())
  }

  fun setBetterXLabel(value: Boolean) {
    if (!value) return
    chartView.setBetterX(value)
  }

  fun setLabelTextSize(value: Double) {
    if (value == 0.0) return
    chartView.setXLabelTextSize(value.toFloat())
    chartView.setYLabelTextSize(value.toFloat())
  }

  fun setLabelTextColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setXlabelTextColor(color(value))
    chartView.setYLabelTextColor(color(value))
  }

  fun setBetterSelectedXLabel(value: Boolean) {
    if (!value) return
    chartView.setBetterSelectedX(value)
  }

  fun setCommonTextSize(value: Double) {
    if (value == 0.0) return
    chartView.setCommonTextSize(value.toFloat())
  }

  fun setMainMarginTop(value: Double) {
    if (value == 0.0) return
    // Kept identical to the legacy implementation (which mapped this prop to
    // setMainLegendMarginTop).
    chartView.setMainLegendMarginTop(value.toFloat())
  }

  fun setPaddingBottom(value: Double) {
    if (value == 0.0) return
    chartView.setChartPaddingBottom(value.toFloat())
  }

  fun setChildPaddingTop(value: Double) {
    if (value == 0.0) return
    chartView.setChildPaddingTop(value.toFloat())
  }

  fun setCommonTextColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setCommonTextColor(color(value))
  }

  fun setLineWidth(value: Double) {
    if (value == 0.0) return
    chartView.setLineWidth(value.toFloat())
  }

  fun setCandleWidth(value: Double) {
    if (value == 0.0) return
    chartView.setCandleWidth(value.toFloat())
  }

  fun setCandleLineWidth(value: Double) {
    if (value == 0.0) return
    chartView.setCandleLineWidth(value.toFloat())
  }

  fun setLimitTextColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setLimitTextColor(color(value))
  }

  fun setCandleHollow(value: Int) {
    if (value == 0) return
    chartView.setCandleSolid(Status.HollowModel.getStrokeModel(value))
  }

  fun setGridLineWidth(value: Double) {
    if (value == 0.0) return
    chartView.setGridLineWidth(value.toFloat())
  }

  fun setGridLineColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setGridLineColor(color(value))
  }

  fun setGridLineRows(value: Double) {
    if (value == 0.0) return
    chartView.setGridRows(value.toInt())
  }

  fun setGridLineColumns(value: Double) {
    if (value == 0.0) return
    chartView.setGridColumns(value.toInt())
  }

  fun setMacdStrokeWidth(value: Double) {
    if (value == 0.0) return
    chartView.setMacdStrockWidth(value.toFloat())
  }

  fun setMacdIncreaseColor(value: String?) {
    if (value.isNullOrBlank()) return
    macdIncreaseColor = value
    refreshMacdColors()
  }

  fun setMacdDecreaseColor(value: String?) {
    if (value.isNullOrBlank()) return
    macdDecreaseColor = value
    refreshMacdColors()
  }

  private fun refreshMacdColors() {
    val increase = macdIncreaseColor
    val decrease = macdDecreaseColor
    if (increase == null || decrease == null) {
      return
    }
    chartView.setMacdChartColor(color(increase), color(decrease))
  }

  fun setMacdWidth(value: Double) {
    if (value == 0.0) return
    chartView.setMACDWidth(value.toFloat())
  }

  fun setDifColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setDIFColor(color(value))
  }

  fun setDeaColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setDEAColor(color(value))
  }

  fun setMacdColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setMACDColor(color(value))
  }

  fun setWr1Color(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setR1Color(color(value))
  }

  fun setWr2Color(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setR2Color(color(value))
  }

  fun setWr3Color(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setR3Color(color(value))
  }

  fun setKColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setKColor(color(value))
  }

  fun setDColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setDColor(color(value))
  }

  fun setJColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setJColor(color(value))
  }

  fun setRsi1Color(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setRSI1Color(color(value))
  }

  fun setRsi2Color(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setRSI2Color(color(value))
  }

  fun setRsi3Color(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setRSI3Color(color(value))
  }

  fun setMa1Color(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setMa1Color(color(value))
  }

  fun setMa2Color(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setMa2Color(color(value))
  }

  fun setMa3Color(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setMa3Color(color(value))
  }

  fun setVolMa1Color(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setVolMa1Color(color(value))
  }

  fun setVolMa2Color(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setVolMa2Color(color(value))
  }

  fun setVolLegendColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setVolLegendColor(color(value))
  }

  fun setVolLineChartColor(value: String?) {
    if (value.isNullOrBlank()) return
    chartView.setVolLineChartColor(color(value))
  }

  fun setVolLegendMarginTop(value: Double) {
    if (value == 0.0) return
    chartView.setVolLegendMarginTop(value.toFloat())
  }
}
