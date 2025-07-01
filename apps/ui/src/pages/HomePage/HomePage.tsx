import React from "react";
import { ScreenshotWrapper } from "@openassistant/ui";
import { Map } from "@/components/Map";
import { Banner } from "@/components/Banner"; // if you modularized it
import { Announcement } from "@/components/Announcement";

import type { HomePageProps } from "./HomePage.types";

export const HomePage = ({
  isAiAssistantPanelOpen,
  isSqlPanelOpen,
  query,
  keplerGlGetState,
  cloudProvidersConfig,
  cloudProviders,
  messages,
  onExportFileSuccess,
  onLoadCloudMapSuccess,
  onViewStateChange,
  screenshotProps,
  bannerProps,
}: HomePageProps): JSX.Element => {
  return (
    <ScreenshotWrapper
      startScreenCapture={screenshotProps.start}
      setStartScreenCapture={screenshotProps.setStart}
      setScreenCaptured={screenshotProps.setCaptured}
      className="h-screen"
    >
      {bannerProps.show && (
        <Banner show={bannerProps.show} height={48} bgColor="#2E7CF6" onClose={bannerProps.onClose}>
          <Announcement onDisable={bannerProps.onDisable} />
        </Banner>
      )}

      <Map
        isAiAssistantPanelOpen={isAiAssistantPanelOpen}
        isSqlPanelOpen={isSqlPanelOpen}
        query={query}
        keplerGlGetState={keplerGlGetState}
        cloudProvidersConfig={cloudProvidersConfig}
        cloudProviders={cloudProviders}
        messages={messages}
        onExportFileSuccess={onExportFileSuccess}
        onLoadCloudMapSuccess={onLoadCloudMapSuccess}
        onViewStateChange={onViewStateChange}
      />
    </ScreenshotWrapper>
  );
};
