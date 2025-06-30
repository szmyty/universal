import type { OIDCUser } from './User';

export interface MapState {
  id: number;
  user_id: string;
  user: OIDCUser;
  name: string;
  description: string;
  state: string;
  created_at: string;
  updated_at: string;
}

export interface MapStateCreate {
  name: string;
  description: string;
  state: string;
}

export interface MapStateUpdate {
  name: string;
  description: string;
  state: string;
}
