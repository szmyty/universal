import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
import type { Message, MessageCreate, MessageUpdate } from "@universal/models";

const localStorageKey = `oidc.user:${import.meta.env.VITE_KEYCLOAK_URL}:${import.meta.env.VITE_KEYCLOAK_CLIENT_ID}`;

const baseQuery = fetchBaseQuery({
  baseUrl: '/api',
  prepareHeaders: (headers) => {
    try {
      const raw = localStorage.getItem(localStorageKey);
      if (raw) {
        const data = JSON.parse(raw);
        if (data?.access_token) {
          headers.set('Authorization', `Bearer ${data.access_token}`);
        }
        if (data?.profile?.sub) {
          headers.set('X-User-Id', data.profile.sub);
        }
      }
    } catch {
      // Ignore parsing errors
    }
    return headers;
  },
});

export const api = createApi({
  reducerPath: 'api',
  baseQuery,
  tagTypes: ['Message'],
  endpoints: (builder) => ({
    listMyMessages: builder.query<Message[], void>({
      query: () => "/messages/me",
      providesTags: (result) =>
        result
          ? [
              ...result.map(({ id }) => ({ type: "Message" as const, id })),
              { type: "Message", id: "LIST" },
            ]
          : [{ type: "Message", id: "LIST" }],
    }),
    getMessage: builder.query<Message, number>({
      query: (id) => `/messages/${id}`,
      providesTags: (result, error, id) => [{ type: "Message", id }],
    }),
    createMessage: builder.mutation<Message, MessageCreate>({
      query: (body) => ({
        url: "/messages",
        method: "POST",
        body,
      }),
      invalidatesTags: [{ type: "Message", id: "LIST" }],
    }),
    updateMessage: builder.mutation<Message, MessageUpdate & { id: number }>({
      query: ({ id, ...patch }) => ({
        url: `/messages/${id}`,
        method: "PUT",
        body: patch,
      }),
      invalidatesTags: (result, error, { id }) => [{ type: "Message", id }],
    }),
    deleteMessage: builder.mutation<{ success: boolean }, number>({
      query: (id) => ({
        url: `/messages/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: (result, error, id) => [
        { type: "Message", id },
        { type: "Message", id: "LIST" },
      ],
    }),
  }),
});
export const {
  useListMyMessagesQuery,
  useGetMessageQuery,
  useCreateMessageMutation,
  useUpdateMessageMutation,
  useDeleteMessageMutation,
} = api;
