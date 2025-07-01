import React from "react";
import { Meta, StoryObj } from "@storybook/react";
import { Map } from "./Map";
import type { MapProps } from "./Map.types";

const meta: Meta<typeof Map> = {
  title: "Map/Map",
  component: Map,
  parameters: {
    layout: "fullscreen",
  },
};

export default meta;

type Story = StoryObj<typeof Map>;

export const Basic: Story = {
  args: {
    isAiAssistantPanelOpen: false,
    isSqlPanelOpen: false,
    query: {},
    keplerGlGetState: () => ({}),
    cloudProvidersConfig: { MAPBOX_TOKEN: "YOUR_MAPBOX_TOKEN" },
    cloudProviders: [],
    messages: {},
    onExportFileSuccess: () => {},
    onLoadCloudMapSuccess: () => {},
    onViewStateChange: () => {},
  },
};
