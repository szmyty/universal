<HomePage
  isAiAssistantPanelOpen={isAiAssistantPanelOpen}
  isSqlPanelOpen={isSqlPanelOpen}
  query={query}
  keplerGlGetState={keplerGlGetState}
  cloudProvidersConfig={CLOUD_PROVIDERS_CONFIGURATION}
  cloudProviders={CLOUD_PROVIDERS}
  messages={messages}
  onExportFileSuccess={onExportFileSuccess}
  onLoadCloudMapSuccess={onLoadCloudMapSuccess}
  onViewStateChange={onViewStateChange}
  screenshotProps={{
    start: props.demo.aiAssistant.screenshotToAsk.startScreenCapture,
    setStart: _setStartScreenCapture,
    setCaptured: _setScreenCaptured,
  }}
  bannerProps={{
    show: showBanner,
    onClose: hideBanner,
    onDisable: _disableBanner,
  }}
/>
