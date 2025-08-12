# Requirements Document

## Introduction

A Flutter-based Android mobile application that helps users manage their screen time by setting shared timers for app groups, providing intelligent reminders with personalized advice, and offering detailed screen time analytics. The app uses system overlay capabilities to enforce time limits and integrates with Google's Gemini Pro API for generating customized feedback and advice.

## Requirements

### Requirement 1

**User Story:** As a user, I want to create groups of apps with shared time limits, so that I can control my overall usage across related applications.

#### Acceptance Criteria

1. WHEN the user accesses the app group setup page THEN the system SHALL display options to create new app groups
2. WHEN the user creates an app group THEN the system SHALL allow them to select multiple installed apps to include in the group
3. WHEN the user sets a timer for an app group THEN the system SHALL apply that time limit as a shared pool across all apps in the group
4. WHEN the user opens any app within a group THEN the system SHALL start the shared timer for that group
5. WHEN the user switches between apps within the same group THEN the system SHALL continue the same timer without resetting
6. WHEN multiple app groups are active simultaneously THEN the system SHALL track each group's timer independently

### Requirement 2

**User Story:** As a user, I want to receive intelligent reminders when my time limit is reached, so that I'm motivated to stop using the apps without feeling intimidated.

#### Acceptance Criteria

1. WHEN a group's timer reaches the set limit THEN the system SHALL display a system overlay reminder that cannot be dismissed by the target apps
2. WHEN the reminder is displayed THEN the system SHALL show personalized advice based on the timer duration and context
3. IF the timer was set for 15 minutes or less THEN the system SHALL suggest short break activities like "take a quick walk" or "do some stretches"
4. IF the timer was set for 30 minutes or more THEN the system SHALL suggest productive alternatives like "read an article" or "practice a skill"
5. WHEN displaying advice THEN the system SHALL use respectful and encouraging language to avoid intimidating the user
6. WHEN the reminder is shown THEN the system SHALL provide options to extend time, take a break, or end the session

### Requirement 3

**User Story:** As a user, I want to view detailed screen time analytics with personalized insights, so that I can understand my usage patterns and receive helpful feedback.

#### Acceptance Criteria

1. WHEN the user accesses the screen insights page THEN the system SHALL display daily, weekly, and monthly screen time statistics
2. WHEN displaying analytics THEN the system SHALL show usage breakdowns by app groups and individual apps
3. WHEN generating insights THEN the system SHALL use the Gemini Pro API to provide personalized feedback based on usage patterns
4. WHEN the user has excessive usage in certain categories THEN the system SHALL suggest specific strategies for improvement
5. WHEN the user shows positive usage trends THEN the system SHALL provide encouraging feedback and tips to maintain progress
6. WHEN displaying insights THEN the system SHALL respect user privacy and process data locally where possible

### Requirement 4

**User Story:** As a developer, I want the app to use Android's system overlay permissions, so that reminders can be displayed over other applications effectively.

#### Acceptance Criteria

1. WHEN the app is first launched THEN the system SHALL request system overlay permissions from the user
2. WHEN overlay permission is granted THEN the system SHALL be able to display reminders over any running application
3. WHEN overlay permission is denied THEN the system SHALL explain the limitation and provide guidance to enable it
4. WHEN displaying overlays THEN the system SHALL ensure they are non-intrusive but attention-grabbing
5. WHEN the target app tries to dismiss the overlay THEN the system SHALL prevent dismissal until user interaction with the reminder

### Requirement 5

**User Story:** As a user, I want the app to have a purple and white theme similar to Twitch, so that the interface is visually appealing and modern.

#### Acceptance Criteria

1. WHEN the user opens the app THEN the system SHALL display a consistent purple and white color scheme throughout
2. WHEN designing UI elements THEN the system SHALL use purple as the primary accent color with white backgrounds
3. WHEN displaying interactive elements THEN the system SHALL use appropriate contrast ratios for accessibility
4. WHEN the user navigates between pages THEN the system SHALL maintain visual consistency in theming
5. WHEN displaying overlays and reminders THEN the system SHALL apply the same theme for brand consistency

### Requirement 6

**User Story:** As a developer, I want a simple Flask backend to handle AI advice generation, so that the mobile app can request personalized insights through a lightweight API.

#### Acceptance Criteria

1. WHEN the mobile app needs personalized advice THEN the system SHALL send requests to a Flask backend API
2. WHEN the Flask backend receives advice requests THEN the system SHALL use Google's Gemini Pro free tier API to generate responses
3. WHEN the backend processes requests THEN the system SHALL implement proper error handling for API failures and rate limits
4. WHEN the Gemini API is unavailable THEN the backend SHALL return pre-defined fallback advice
5. WHEN handling API keys THEN the backend SHALL securely manage the Gemini Pro API key through environment variables
6. WHEN generating advice THEN the backend SHALL consider user context like usage duration, time of day, and app categories

### Requirement 7

**User Story:** As a user, I want to navigate between app group setup and screen insights easily, so that I can manage my screen time efficiently.

#### Acceptance Criteria

1. WHEN the user opens the app THEN the system SHALL display a bottom navigation bar with two main sections
2. WHEN the user taps the setup section THEN the system SHALL navigate to the app group management page
3. WHEN the user taps the insights section THEN the system SHALL navigate to the screen time analytics page
4. WHEN navigating between pages THEN the system SHALL maintain the current state and data
5. WHEN the user is setting up app groups THEN the system SHALL provide clear visual feedback on their progress
6. WHEN displaying insights THEN the system SHALL organize information in an easily digestible format