# Screen Time Manager Backend

A Flask-based REST API server that provides personalized screen time advice using Google's Gemini Pro API.

## Features

- **Personalized Advice Generation**: Uses Google Gemini Pro API to generate contextual advice
- **Fallback System**: Provides pre-defined advice when AI service is unavailable
- **Rate Limiting**: Prevents API abuse with configurable rate limits
- **Request Validation**: Comprehensive input validation and error handling
- **CORS Support**: Enables cross-origin requests from mobile app
- **Health Monitoring**: Health check endpoint for service monitoring
- **Comprehensive Testing**: Full test suite with mocking for external dependencies

## API Endpoints

### Health Check
```
GET /api/health
```
Returns server health status and configuration info.

### Generate Advice
```
POST /api/advice
Content-Type: application/json

{
  "usage_duration": 30,
  "time_of_day": "afternoon",
  "app_categories": ["social", "entertainment"]
}
```

Returns personalized advice based on usage context.

## Setup

1. **Install Dependencies**
```bash
pip install -r requirements.txt
```

2. **Environment Configuration**
```bash
cp .env.example .env
# Edit .env and add your GEMINI_API_KEY
```

3. **Get Gemini API Key**
- Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
- Create a new API key
- Add it to your `.env` file

4. **Run the Server**
```bash
python app.py
```

The server will start on `http://localhost:5000`

## Testing

Run the test suite:
```bash
pytest test_app.py -v
```

Run with coverage:
```bash
pytest test_app.py --cov=app --cov-report=html
```

## Configuration

Environment variables:

- `GEMINI_API_KEY`: Google Gemini Pro API key (required for AI features)
- `FLASK_ENV`: Environment mode (development/production)
- `PORT`: Server port (default: 5000)
- `CORS_ORIGINS`: Allowed CORS origins (default: *)
- `RATELIMIT_STORAGE_URL`: Rate limiting storage backend

## Rate Limiting

- Default: 100 requests per hour per IP
- Advice endpoint: 10 requests per minute per IP
- Returns 429 status code when exceeded

## Error Handling

The API provides comprehensive error handling:

- **400 Bad Request**: Invalid request format or missing fields
- **429 Too Many Requests**: Rate limit exceeded
- **500 Internal Server Error**: Server errors with fallback advice

All error responses include helpful error messages and fallback advice when appropriate.

## Deployment

For production deployment:

1. Set `FLASK_ENV=production`
2. Use a production WSGI server like Gunicorn
3. Configure proper CORS origins
4. Set up monitoring and logging
5. Use Redis for rate limiting storage in distributed environments

Example with Gunicorn:
```bash
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```