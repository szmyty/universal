import React from "react";
import AutoSizer from "react-virtualized/dist/commonjs/AutoSizer";
import { PanelGroup, Panel } from "react-resizable-panels";
import { KeplerGl } from "@kepler.gl/components";

import { SqlPanel } from "@kepler.gl/duckdb";
import { AiAssistantPanel } from "@kepler.gl/ai-assistant";
import { StyledContainer, StyledResizeHandle, StyledVerticalResizeHandle } from "./Map.styles";
import type { MapProps } from "./Map.types";

export const Map = ({
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
}: MapProps): React.JSX.Element => {
  return (
    <StyledContainer>
      <PanelGroup direction="horizontal">
        <Panel defaultSize={isAiAssistantPanelOpen ? 70 : 100}>
          <PanelGroup direction="vertical">
            <Panel defaultSize={isSqlPanelOpen ? 60 : 100}>
              <AutoSizer>
                {({ height, width }: { height: number; width: number }) => (
                  <KeplerGl
                    mapboxApiAccessToken={cloudProvidersConfig.MAPBOX_TOKEN}
                    id="map"
                    getState={keplerGlGetState}
                    width={width}
                    height={height}
                    cloudProviders={cloudProviders}
                    localeMessages={messages}
                    onExportToCloudSuccess={onExportFileSuccess}
                    onLoadCloudMapSuccess={onLoadCloudMapSuccess}
                    featureFlags={{ exportImage: true }}
                    onViewStateChange={onViewStateChange}
                  />
                )}
              </AutoSizer>
            </Panel>
            {isSqlPanelOpen && (
              <>
                <StyledResizeHandle />
                <Panel defaultSize={40} minSize={20}>
                  <SqlPanel initialSql={query?.sql || ""} />
                </Panel>
              </>
            )}
          </PanelGroup>
        </Panel>

        {isAiAssistantPanelOpen && (
          <>
            <StyledVerticalResizeHandle />
            <Panel defaultSize={30} minSize={20}>
              <AiAssistantPanel />
            </Panel>
          </>
        )}
      </PanelGroup>
    </StyledContainer>
  );
};
export default Map;
