package com.byron.kline

import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider
import com.facebook.react.uimanager.ViewManager

/**
 * Fabric-ready package for the ByronKline chart component.
 *
 * The component itself is provided through codegen (see `codegenConfig` in
 * package.json): the generated `ByronKlineManagerDelegate` drives prop updates
 * on both architectures, while this package exposes the ViewManager to the
 * interop/legacy machinery when needed.
 */
class ByronKlinePackage : BaseReactPackage() {

  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? = null

  override fun getReactModuleInfoProvider(): ReactModuleInfoProvider = ReactModuleInfoProvider {
    // No turbo modules; the package only ships a ViewManager.
    emptyMap<String, ReactModuleInfo>()
  }

  override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> =
      listOf(ByronKlineManager())
}
