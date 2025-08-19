#!/usr/bin/env python3
"""
Development server runner for Screen Time Manager Backend
"""

import os
import sys
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Add current directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app

if __name__ == '__main__':
    # Development configuration
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('FLASK_ENV', 'development') == 'development'
    
    print(f"Starting Screen Time Manager Backend...")
    print(f"Environment: {os.getenv('FLASK_ENV', 'development')}")
    print(f"Port: {port}")
    print(f"Debug: {debug}")
    print(f"Gemini API configured: {'Yes' if os.getenv('GEMINI_API_KEY') else 'No'}")
    
    app.run(
        host='0.0.0.0',
        port=port,
        debug=debug,
        use_reloader=debug
    )