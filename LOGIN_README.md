# Flutter Login Screen

This Flutter app implements a login screen with Material UI that closely matches the design from the web version.

## Features

-   Modern Material UI design
-   Email and password validation
-   Login API integration
-   Cookie support for credentials
-   Environment variable configuration
-   Error handling and loading states
-   Responsive design

## API Configuration

The app uses environment variables for API configuration:

-   `API_BASE_URL`: Base URL for the API (default: http://localhost)
-   `API_PORT`: Port for the API (default: 8080)

The login endpoint is constructed as: `{API_BASE_URL}:{API_PORT}/auth/login`

## Setup

1. Install dependencies:

    ```bash
    flutter pub get
    ```

2. Run the app:
    ```bash
    flutter run
    ```

## API Integration

The app sends a POST request to the login endpoint with the following structure:

```json
{
	"email": "user@example.com",
	"password": "userpassword"
}
```

The API response should include:

-   Success status
-   Token (if successful)
-   Error message (if failed)

## Environment Variables

The `.env` file contains:

```
API_BASE_URL=http://localhost
API_PORT=8080
```

## Files Structure

-   `lib/screens/auth/login_screen.dart`: Main login screen UI
-   `lib/services/auth_service.dart`: Authentication service for API calls
-   `lib/models/api_response.dart`: Response models for API data
-   `lib/models/login_input.dart`: Login input model
-   `.env`: Environment configuration

## Testing

To test the login functionality:

1. Set up your API server on localhost:8080
2. Ensure the `/auth/login` endpoint is available
3. Test with valid credentials
4. The app will display success/error messages accordingly

## Notes

-   The app supports cookie-based authentication
-   Form validation is implemented for email and password fields
-   Loading states are shown during API calls
-   Error messages are displayed for failed attempts
