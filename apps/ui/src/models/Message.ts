import type { OIDCUser } from './User';

export interface Message {
  id: number;
  user_id: string;
  user: OIDCUser;
  content: string;
  created_at: string;
  updated_at: string;
}

export interface MessageCreate {
  content: string;
}

export interface MessageUpdate {
  content: string;
}
