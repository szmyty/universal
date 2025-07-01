import styled from "styled-components";
import { PanelResizeHandle } from "react-resizable-panels";
import { panelBorderColor } from "@kepler.gl/styles";

export const StyledContainer = styled.div`
  transition: margin 1s, height 1s;
  position: absolute;
  width: 100%;
  height: 100%;
  left: 0;
  top: 0;
  display: flex;
  flex-direction: column;
  background-color: #333;
`;

export const StyledResizeHandle = styled(PanelResizeHandle)`
  background-color: ${panelBorderColor};
  width: 100%;
  height: 5px;
  cursor: row-resize;

  &:hover {
    background-color: #555;
  }
`;

export const StyledVerticalResizeHandle = styled(PanelResizeHandle)`
  background-color: ${panelBorderColor};
  width: 4px;
  height: 100%;
  cursor: col-resize;

  &:hover {
    background-color: #555;
  }
`;
