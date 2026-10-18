export const environment = {
  production: false,
  // apiUrl: 'http://localhost:8080/api',
  apiUrl: 'http://backend-sw1-workflow.us-east-2.elasticbeanstalk.com/api',
  // wsUrl: 'http://localhost:8080/ws',
  wsUrl: 'http://backend-sw1-workflow.us-east-2.elasticbeanstalk.com/ws',
  // iaUrl: 'http://localhost:8000/api/ia',
  iaUrl: 'http://servicio-fastapi.us-east-2.elasticbeanstalk.com/api/ia',
  onlyOfficeUrl: 'http://localhost:8081',
  onlyOfficeCallbackUrl: 'http://host.docker.internal:8080/api/archivos/callback',
  clearSessionOnStart: true
};
  