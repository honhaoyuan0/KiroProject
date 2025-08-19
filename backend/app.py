from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import logging
import os
from datetime import datetime
import google.generativeai as genai
from typing import Dict, Any, Optional
import json

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Rate limiting
limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["100 per hour"]
)

# Configure Gemini API
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)
    model = genai.GenerativeModel('gemini-pro')
else:
    logger.warning("GEMINI_API_KEY not found in environment variables")
    model = None

class AdviceService:
    """Service for generating personalized advice using Gemini Pro API"""
    
    @staticmethod
    def get_fallback_advice(usage_duration: int, time_of_day: str) -> str:
        """Return fallback advice when Gemini API is unavailable"""
        fallback_templates = {
            "short": [
                "Take a quick 5-minute break and stretch your legs!",
                "Try some deep breathing exercises to refresh your mind.",
                "Step outside for a moment and get some fresh air."
            ],
            "medium": [
                "Consider reading an article or practicing a new skill.",
                "This might be a good time to organize your workspace.",
                "Try a short meditation or mindfulness exercise."
            ],
            "long": [
                "Take a longer break and engage in a physical activity.",
                "Consider working on a hobby or creative project.",
                "Connect with friends or family for meaningful conversation."
            ]
        }
        
        if usage_duration <= 15:
            category = "short"
        elif usage_duration <= 45:
            category = "medium"
        else:
            category = "long"
            
        import random
        return random.choice(fallback_templates[category])
    
    @staticmethod
    def build_prompt(context: Dict[str, Any]) -> str:
        """Build a contextual prompt for Gemini API"""
        usage_duration = context.get('usage_duration', 0)
        time_of_day = context.get('time_of_day', 'unknown')
        app_categories = context.get('app_categories', [])
        
        prompt = f"""
        You are a helpful digital wellness assistant. A user has been using their phone for {usage_duration} minutes during {time_of_day}.
        
        The apps they've been using fall into these categories: {', '.join(app_categories) if app_categories else 'general apps'}.
        
        Please provide a brief, encouraging, and respectful suggestion (2-3 sentences max) for what they could do instead. 
        Be supportive and avoid being judgmental or intimidating. Focus on positive alternatives that match the time of day and duration of use.
        
        Keep the tone friendly and motivational.
        """
        
        return prompt.strip()
    
    @classmethod
    def generate_advice(cls, context: Dict[str, Any]) -> Dict[str, Any]:
        """Generate advice using Gemini API with fallback"""
        usage_duration = context.get('usage_duration', 0)
        time_of_day = context.get('time_of_day', 'unknown')
        
        try:
            if model is None:
                raise Exception("Gemini API not configured")
                
            prompt = cls.build_prompt(context)
            response = model.generate_content(prompt)
            
            if response.text:
                return {
                    'advice': response.text.strip(),
                    'success': True,
                    'fallback_used': False
                }
            else:
                raise Exception("Empty response from Gemini API")
                
        except Exception as e:
            logger.error(f"Error generating advice with Gemini API: {str(e)}")
            fallback_advice = cls.get_fallback_advice(usage_duration, time_of_day)
            return {
                'advice': fallback_advice,
                'success': True,
                'fallback_used': True
            }

def validate_advice_request(data: Dict[str, Any]) -> tuple[bool, str]:
    """Validate advice request data"""
    required_fields = ['usage_duration', 'time_of_day']
    
    for field in required_fields:
        if field not in data:
            return False, f"Missing required field: {field}"
    
    # Validate usage_duration
    if not isinstance(data['usage_duration'], (int, float)) or data['usage_duration'] < 0:
        return False, "usage_duration must be a non-negative number"
    
    # Validate time_of_day
    valid_times = ['morning', 'afternoon', 'evening', 'night']
    if data['time_of_day'] not in valid_times:
        return False, f"time_of_day must be one of: {', '.join(valid_times)}"
    
    # Validate app_categories if present
    if 'app_categories' in data:
        if not isinstance(data['app_categories'], list):
            return False, "app_categories must be a list"
        if not all(isinstance(cat, str) for cat in data['app_categories']):
            return False, "all app_categories must be strings"
    
    return True, ""

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'gemini_configured': model is not None
    })

@app.route('/api/advice', methods=['POST'])
@limiter.limit("10 per minute")
def get_advice():
    """Generate personalized advice based on usage context"""
    try:
        # Validate request content type
        if not request.is_json:
            return jsonify({'error': 'Content-Type must be application/json'}), 400
        
        data = request.get_json()
        if not data:
            return jsonify({'error': 'Request body is required'}), 400
        
        # Validate request data
        is_valid, error_message = validate_advice_request(data)
        if not is_valid:
            return jsonify({'error': error_message}), 400
        
        # Log the request (without sensitive data)
        logger.info(f"Advice request: duration={data['usage_duration']}, time={data['time_of_day']}")
        
        # Generate advice
        advice_response = AdviceService.generate_advice(data)
        
        return jsonify(advice_response)
        
    except Exception as e:
        logger.error(f"Error in advice endpoint: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'advice': 'Take a moment to step away from your device and do something you enjoy.',
            'success': True,
            'fallback_used': True
        }), 500

@app.errorhandler(429)
def ratelimit_handler(e):
    """Handle rate limit exceeded"""
    return jsonify({
        'error': 'Rate limit exceeded. Please try again later.',
        'advice': 'Take this as a sign to take a break from your device!',
        'success': True,
        'fallback_used': True
    }), 429

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('FLASK_ENV') == 'development'
    app.run(host='0.0.0.0', port=port, debug=debug)