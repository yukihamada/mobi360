export function errorHandler(error, c) {
  console.error('Error:', error);
  
  if (error.status) {
    return c.json({
      success: false,
      error: error.message || 'Internal Server Error',
      status: error.status
    }, error.status);
  }
  
  return c.json({
    success: false,
    error: 'Internal Server Error',
    message: 'An unexpected error occurred'
  }, 500);
}