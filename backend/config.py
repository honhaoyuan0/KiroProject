import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Config:
    """Base configuration class"""
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
    GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
    PORT = int(os.getenv('PORT', 5000))
    
    # Rate limiting
    RATELIMIT_STORAGE_URL = os.getenv('RATELIMIT_STORAGE_URL', 'memory://')
    
    # CORS settings
    CORS_ORIGINS = os.getenv('CORS_ORIGINS', '*').split(',')

class DevelopmentConfig(Config):
    """Development configuration"""
    DEBUG = True
    FLASK_ENV = 'development'

class ProductionConfig(Config):
    """Production configuration"""
    DEBUG = False
    FLASK_ENV = 'production'

class TestingConfig(Config):
    """Testing configuration"""
    TESTING = True
    DEBUG = True
    GEMINI_API_KEY = 'test-key'

# Configuration mapping
config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}