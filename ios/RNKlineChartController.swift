import UIKit

/**
 * Swift host controller for the ByronKline Fabric component.
 *
 * Replaces the legacy ObjC `ByronController`: it owns the `KLineChartView`
 * engine view and translates the (codegen-driven) prop/command calls into
 * engine state. All prop values are first stored, then applied — the chart
 * view is created lazily on the `init` command, exactly like the legacy
 * implementation, so props that arrive before `init` are replayed afterwards.
 */
@objc(RNKlineChartController)
public final class RNKlineChartController: UIView, KLineDelegate {

  // Engine default colors (mirrors of ChartStyle.h macros, which are not
  // visible to Swift).
  private static let defaultUpColor = UIColor.rgb(fromHex: 0xffDF1A3A)
  private static let defaultDownColor = UIColor.rgb(fromHex: 0xff23915C)
  private static let defaultMa5Color = UIColor.rgb(fromHex: 0xffC9B885)
  private static let defaultMa10Color = UIColor.rgb(fromHex: 0xff6CB0A6)
  private static let defaultMa30Color = UIColor.rgb(fromHex: 0xff9979C6)
  private static let defaultMaxMinTextColor = UIColor.rgb(fromHex: 0xffffffff)

  private var chartView: KLineChartView?

  // Stored props, replayed when the chart view is created.
  private var pendingDatas: [Any]?
  private var pendingLocales: [Any]?
  private var pendingIndicators: [Any]?
  private var pendingPricePrecision: NSNumber?
  private var pendingVolumePrecision: NSNumber?
  private var pendingMainBackgroundColor: String?
  private var pendingIncreaseColor: String?
  private var pendingDecreaseColor: String?
  private var pendingMa1Color: String?
  private var pendingMa2Color: String?
  private var pendingMa3Color: String?
  private var pendingLimitTextColor: String?

  private var requestStatus = false

  /// Set by the Fabric component view; emits the onMoreKLineData event.
  @objc public var onMoreKLineDataHandler: ((Double) -> Void)?

  // MARK: - Lifecycle

  public override init(frame: CGRect) {
    super.init(frame: frame)
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    // Fabric: the `init` command dispatched from useEffect at mount time can
    // be dropped when it races the initial mount transaction, leaving the
    // chart engine un-created and all `datas` prop updates stuck in
    // `pendingDatas` (chart rendered as a black box on cold launch).
    // Creating the engine on first layout removes the timing dependency.
    if chartView == nil {
      initChartView()
    }
    chartView?.frame = bounds
  }

  // MARK: - Commands

  @objc public func handleCommand(event: String, list: [Any]?) {
    switch event {
    case "init":
      initChartView()
    case "update":
      addHeaderData(list ?? [])
    case "add":
      addFooterData(list ?? [])
    default:
      break
    }
  }

  // MARK: - Chart setup

  @objc public func initChartView() {
    guard chartView == nil else { return }
    let view = KLineChartView(frame: bounds)
    // Assign before replaying props: the setters below early-return while
    // `chartView` is nil, which previously swallowed every replayed value
    // (background color / datas / precision that arrived before `init`).
    chartView = view
    view.delegate = self
    KLineStateManager().klineChart = view
    initKLineState()
    // Replay stored props.
    if let datas = pendingDatas { setDatas(datas) }
    if let locales = pendingLocales { setLocales(locales) }
    if let indicators = pendingIndicators { setIndicators(indicators) }
    if let precision = pendingPricePrecision { setPricePrecision(precision) }
    if let precision = pendingVolumePrecision { setVolumePrecision(precision) }
    if let color = pendingIncreaseColor { setIncreaseColor(color) }
    if let color = pendingDecreaseColor { setDecreaseColor(color) }
    if let color = pendingMainBackgroundColor { setMainBackgroundColor(color) }
    initColors()
    addSubview(view)
  }

  // MARK: - Data commands (ported from legacy ByronController)

  @objc public func addHeaderData(_ list: [Any]) {
    guard chartView != nil, let first = list.first as? [String: Any] else { return }

    let item = KLineModel(dict: first)
    let manager = KLineStateManager()
    guard let models = manager.datas as? [KLineModel], models.count > 1,
          let model = models.first else { return }

    let last1 = models[0]
    let last2 = models[1]
    let differ = Int(last1.id) - Int(last2.id)
    let limit = Int(item.id) - Int(last1.id)

    let entity = KLineModel()
    entity.open = item.open
    entity.high = item.high
    entity.low = item.low
    entity.close = item.close
    entity.vol = item.vol
    entity.amount = item.amount

    let newDatas = NSMutableArray(array: models)
    if limit < differ {
      entity.id = model.id
      newDatas.replaceObject(at: 0, with: entity)
      if manager.isLine {
        DataUtil.addLastData(models, data: entity)
      } else {
        DataUtil.calculate(newDatas as! [KLineModel])
      }
      manager.datas = (newDatas.copy() as? [Any]) ?? []
    } else {
      entity.id = item.id
      newDatas.insert(entity, at: 0)
      if manager.isLine {
        DataUtil.addLastData(models, data: entity)
      } else {
        DataUtil.calculate(newDatas as! [KLineModel])
      }
      manager.datas = (newDatas.copy() as? [Any]) ?? []
    }
  }

  @objc public func addFooterData(_ list: [Any]) {
    guard chartView != nil else { return }
    let manager = KLineStateManager()
    let models = (manager.datas as? [KLineModel]) ?? []
    let newDatas = NSMutableArray(array: models)
    for item in list.reversed() {
      if let dict = item as? [String: Any] {
        newDatas.add(KLineModel(dict: dict))
      }
    }
    DataUtil.calculate(newDatas as! [KLineModel])
    manager.datas = (newDatas.copy() as? [Any]) ?? []
    if requestStatus {
      requestStatus = false
    }
  }

  // MARK: - Props (ported from legacy ByronController)

  @objc public func setDatas(_ datas: [Any]?) {
    pendingDatas = datas
    guard chartView != nil, let datas = datas, !datas.isEmpty else { return }
    let list = NSMutableArray(capacity: datas.count)
    for item in datas.reversed() {
      if let dict = item as? [String: Any] {
        list.add(KLineModel(dict: dict))
      }
    }
    DataUtil.calculate(list as! [KLineModel])
    KLineStateManager().datas = (list.copy() as? [Any]) ?? []
  }

  @objc public func setLocales(_ locales: [Any]?) {
    pendingLocales = locales
    guard chartView != nil, let locales = locales as? [String], !locales.isEmpty else { return }
    KLineStateManager().locales = locales
  }

  @objc public func setIndicators(_ indicators: [Any]?) {
    pendingIndicators = indicators
    guard chartView != nil, let indicators = indicators else { return }
    if indicators.isEmpty {
      initKLineState()
      return
    }
    for item in indicators {
      changeKLineState(item as? NSNumber)
    }
  }

  @objc public func setPricePrecision(_ precision: NSNumber?) {
    pendingPricePrecision = precision
    guard chartView != nil, let precision = precision else { return }
    KLineStateManager().pricePrecision = precision
  }

  @objc public func setVolumePrecision(_ precision: NSNumber?) {
    pendingVolumePrecision = precision
    guard chartView != nil, let precision = precision else { return }
    KLineStateManager().volumePrecision = precision
  }

  @objc public func setMainBackgroundColor(_ color: String?) {
    pendingMainBackgroundColor = color
    if let color = color, let chartView = chartView {
      chartView.setMainBackgroundColor(color)
    }
  }

  @objc public func setIncreaseColor(_ color: String?) {
    pendingIncreaseColor = color
    if chartView == nil { return }
    initColors()
  }

  @objc public func setDecreaseColor(_ color: String?) {
    pendingDecreaseColor = color
    if chartView == nil { return }
    initColors()
  }

  @objc public func setMa1Color(_ color: String?) {
    pendingMa1Color = color
    if chartView == nil { return }
    initColors()
  }

  @objc public func setMa2Color(_ color: String?) {
    pendingMa2Color = color
    if chartView == nil { return }
    initColors()
  }

  @objc public func setMa3Color(_ color: String?) {
    pendingMa3Color = color
    if chartView == nil { return }
    initColors()
  }

  @objc public func setLimitTextColor(_ color: String?) {
    pendingLimitTextColor = color
    if chartView == nil { return }
    initColors()
  }

  // MARK: - KLineDelegate

  public func onMoreKLineData() {
    if requestStatus { return }
    requestStatus = true
    guard let last = (KLineStateManager().datas as? [KLineModel])?.last else { return }
    onMoreKLineDataHandler?(last.id)
  }

  // MARK: - State

  private func initKLineState() {
    guard chartView != nil else { return }
    let manager = KLineStateManager()
    manager.mainState = MainStateNONE
    manager.secondaryState = SecondaryStateNONE
    manager.isLine = false
  }

  private func changeKLineState(_ index: NSNumber?) {
    guard chartView != nil, let index = index else { return }
    let manager = KLineStateManager()
    switch index.intValue {
    case 0: manager.mainState = MainStateMA
    case 1: manager.mainState = MainStateBOLL
    case 2: manager.mainState = MainStateNONE
    case 3: manager.secondaryState = SecondaryStateMacd
    case 4: manager.secondaryState = SecondaryStateKDJ
    case 5: manager.secondaryState = SecondaryStateRSI
    case 6: manager.secondaryState = SecondaryStateWR
    case 7: manager.secondaryState = SecondaryStateNONE
    case 8: manager.isLine = true
    case 9: manager.isLine = false
    case 10: chartView?.volState = VolStateVOL
    case 11: chartView?.volState = VolStateNONE
    default: break
    }
  }

  private func initColors() {
    let manager = KLineStateManager()
    manager.increaseColor = pendingIncreaseColor.map { UIColor(hexString: $0) }
      ?? RNKlineChartController.defaultUpColor
    manager.decreaseColor = pendingDecreaseColor.map { UIColor(hexString: $0) }
      ?? RNKlineChartController.defaultDownColor
    manager.ma1Color = pendingMa1Color.map { UIColor(hexString: $0) }
      ?? RNKlineChartController.defaultMa5Color
    manager.ma2Color = pendingMa2Color.map { UIColor(hexString: $0) }
      ?? RNKlineChartController.defaultMa10Color
    manager.ma3Color = pendingMa3Color.map { UIColor(hexString: $0) }
      ?? RNKlineChartController.defaultMa30Color
    manager.limitTextColor = pendingLimitTextColor.map { UIColor(hexString: $0) }
      ?? RNKlineChartController.defaultMaxMinTextColor
  }
}
