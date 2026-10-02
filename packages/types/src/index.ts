// API contracts shared by frontend and backend. Keep this package type-only.
export interface HealthResponse {
  status: 'ok';
  message: string;
}
