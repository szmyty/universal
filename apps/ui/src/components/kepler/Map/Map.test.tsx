import { render } from "@testing-library/react";
import { Map } from "./Map";
import { vi } from "vitest";
import type { MapProps } from "./Map.types";

describe("Map", () => {
  it("renders without crashing", () => {
    const props: MapProps = {
      isAiAssistantPanelOpen: false,
      isSqlPanelOpen: false,
      query: {},
      keplerGlGetState: () => ({}),
      cloudProvidersConfig: { MAPBOX_TOKEN: "test-token" },
      cloudProviders: [],
      messages: {},
      onExportFileSuccess: vi.fn(),
      onLoadCloudMapSuccess: vi.fn(),
      onViewStateChange: vi.fn(),
    };

    render(<Map {...props} />);
  });
});
