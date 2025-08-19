import pytest
import json
import os
from unittest.mock import patch, MagicMock
from app import app, AdviceService, validate_advice_request

@pytest.fixture
def client():
    """Create a test client"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

@pytest.fixture
def sample_advice_request():
    """Sample valid advice request"""
    return {
        'usage_duration': 30,
        'time_of_day': 'afternoon',
        'app_categories': ['social', 'entertainment']
    }

class TestHealthEndpoint:
    """Test cases for health check endpoint"""
    
    def test_health_check_success(self, client):
        """Test successful health check"""
        response = client.get('/api/health')
        assert response.status_code == 200
        
        data = json.loads(response.data)
        assert data['status'] == 'healthy'
        assert 'timestamp' in data
        assert 'gemini_configured' in data

class TestAdviceEndpoint:
    """Test cases for advice endpoint"""
    
    def test_advice_endpoint_success(self, client, sample_advice_request):
        """Test successful advice generation"""
        with patch.object(AdviceService, 'generate_advice') as mock_generate:
            mock_generate.return_value = {
                'advice': 'Take a short walk outside!',
                'success': True,
                'fallback_used': False
            }
            
            response = client.post('/api/advice',
                                 data=json.dumps(sample_advice_request),
                                 content_type='application/json')
            
            assert response.status_code == 200
            data = json.loads(response.data)
            assert data['advice'] == 'Take a short walk outside!'
            assert data['success'] is True
            assert data['fallback_used'] is False
    
    def test_advice_endpoint_missing_content_type(self, client, sample_advice_request):
        """Test advice endpoint with missing content type"""
        response = client.post('/api/advice', data=json.dumps(sample_advice_request))
        assert response.status_code == 400
        
        data = json.loads(response.data)
        assert 'Content-Type must be application/json' in data['error']
    
    def test_advice_endpoint_empty_body(self, client):
        """Test advice endpoint with empty request body"""
        response = client.post('/api/advice',
                             data='',
                             content_type='application/json')
        assert response.status_code == 400
        
        data = json.loads(response.data)
        assert 'Request body is required' in data['error']
    
    def test_advice_endpoint_missing_required_fields(self, client):
        """Test advice endpoint with missing required fields"""
        invalid_request = {'usage_duration': 30}  # missing time_of_day
        
        response = client.post('/api/advice',
                             data=json.dumps(invalid_request),
                             content_type='application/json')
        assert response.status_code == 400
        
        data = json.loads(response.data)
        assert 'Missing required field: time_of_day' in data['error']
    
    def test_advice_endpoint_invalid_usage_duration(self, client):
        """Test advice endpoint with invalid usage duration"""
        invalid_request = {
            'usage_duration': -5,
            'time_of_day': 'morning'
        }
        
        response = client.post('/api/advice',
                             data=json.dumps(invalid_request),
                             content_type='application/json')
        assert response.status_code == 400
        
        data = json.loads(response.data)
        assert 'usage_duration must be a non-negative number' in data['error']
    
    def test_advice_endpoint_invalid_time_of_day(self, client):
        """Test advice endpoint with invalid time of day"""
        invalid_request = {
            'usage_duration': 30,
            'time_of_day': 'invalid_time'
        }
        
        response = client.post('/api/advice',
                             data=json.dumps(invalid_request),
                             content_type='application/json')
        assert response.status_code == 400
        
        data = json.loads(response.data)
        assert 'time_of_day must be one of:' in data['error']
    
    def test_advice_endpoint_server_error(self, client, sample_advice_request):
        """Test advice endpoint with server error"""
        with patch.object(AdviceService, 'generate_advice') as mock_generate:
            mock_generate.side_effect = Exception("Test error")
            
            response = client.post('/api/advice',
                                 data=json.dumps(sample_advice_request),
                                 content_type='application/json')
            
            assert response.status_code == 500
            data = json.loads(response.data)
            assert 'Internal server error' in data['error']
            assert data['fallback_used'] is True

class TestAdviceService:
    """Test cases for AdviceService"""
    
    def test_get_fallback_advice_short_duration(self):
        """Test fallback advice for short duration"""
        advice = AdviceService.get_fallback_advice(10, 'morning')
        assert isinstance(advice, str)
        assert len(advice) > 0
    
    def test_get_fallback_advice_medium_duration(self):
        """Test fallback advice for medium duration"""
        advice = AdviceService.get_fallback_advice(30, 'afternoon')
        assert isinstance(advice, str)
        assert len(advice) > 0
    
    def test_get_fallback_advice_long_duration(self):
        """Test fallback advice for long duration"""
        advice = AdviceService.get_fallback_advice(60, 'evening')
        assert isinstance(advice, str)
        assert len(advice) > 0
    
    def test_build_prompt(self):
        """Test prompt building"""
        context = {
            'usage_duration': 45,
            'time_of_day': 'evening',
            'app_categories': ['social', 'games']
        }
        
        prompt = AdviceService.build_prompt(context)
        assert '45 minutes' in prompt
        assert 'evening' in prompt
        assert 'social, games' in prompt
    
    @patch('app.model')
    def test_generate_advice_success(self, mock_model):
        """Test successful advice generation with Gemini API"""
        mock_response = MagicMock()
        mock_response.text = "Take a break and go for a walk!"
        mock_model.generate_content.return_value = mock_response
        
        context = {
            'usage_duration': 30,
            'time_of_day': 'afternoon',
            'app_categories': ['social']
        }
        
        result = AdviceService.generate_advice(context)
        assert result['advice'] == "Take a break and go for a walk!"
        assert result['success'] is True
        assert result['fallback_used'] is False
    
    @patch('app.model', None)
    def test_generate_advice_no_model(self):
        """Test advice generation when Gemini model is not configured"""
        context = {
            'usage_duration': 30,
            'time_of_day': 'afternoon',
            'app_categories': ['social']
        }
        
        result = AdviceService.generate_advice(context)
        assert isinstance(result['advice'], str)
        assert result['success'] is True
        assert result['fallback_used'] is True
    
    @patch('app.model')
    def test_generate_advice_api_error(self, mock_model):
        """Test advice generation with API error"""
        mock_model.generate_content.side_effect = Exception("API Error")
        
        context = {
            'usage_duration': 30,
            'time_of_day': 'afternoon',
            'app_categories': ['social']
        }
        
        result = AdviceService.generate_advice(context)
        assert isinstance(result['advice'], str)
        assert result['success'] is True
        assert result['fallback_used'] is True

class TestValidation:
    """Test cases for request validation"""
    
    def test_validate_advice_request_valid(self):
        """Test validation with valid request"""
        data = {
            'usage_duration': 30,
            'time_of_day': 'morning',
            'app_categories': ['social', 'games']
        }
        
        is_valid, error = validate_advice_request(data)
        assert is_valid is True
        assert error == ""
    
    def test_validate_advice_request_missing_field(self):
        """Test validation with missing required field"""
        data = {'usage_duration': 30}  # missing time_of_day
        
        is_valid, error = validate_advice_request(data)
        assert is_valid is False
        assert 'Missing required field: time_of_day' in error
    
    def test_validate_advice_request_invalid_duration(self):
        """Test validation with invalid usage duration"""
        data = {
            'usage_duration': -10,
            'time_of_day': 'morning'
        }
        
        is_valid, error = validate_advice_request(data)
        assert is_valid is False
        assert 'usage_duration must be a non-negative number' in error
    
    def test_validate_advice_request_invalid_time(self):
        """Test validation with invalid time of day"""
        data = {
            'usage_duration': 30,
            'time_of_day': 'invalid'
        }
        
        is_valid, error = validate_advice_request(data)
        assert is_valid is False
        assert 'time_of_day must be one of:' in error
    
    def test_validate_advice_request_invalid_categories(self):
        """Test validation with invalid app categories"""
        data = {
            'usage_duration': 30,
            'time_of_day': 'morning',
            'app_categories': 'not_a_list'
        }
        
        is_valid, error = validate_advice_request(data)
        assert is_valid is False
        assert 'app_categories must be a list' in error

if __name__ == '__main__':
    pytest.main([__file__])