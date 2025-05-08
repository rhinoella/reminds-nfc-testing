# Survey Endpoints Documentation

This document describes the available endpoints for managing surveys and survey submissions.

## Get Survey

Retrieves the survey configuration for a specific trial.

**Endpoint:** `GET /survey/:trialId`

### Parameters
- `trialId` (path parameter): The ID of the trial to get the survey for

### Response
If a survey exists:
```json
{
  "title": "string",
  "questions": [
    {
      "id": "string",
      "question": "string",
      "options": ["string"]
    }
  ],
  "videoLink": "string"
}
```

If no survey exists:
```json
{
  "title": "",
  "questions": [],
  "videoLink": ""
}
```

### Error Responses
- `500 Internal Server Error`: If there was an error fetching the survey

## Submit Survey

Submits a survey response for a specific trial.

**Endpoint:** `POST /survey-submissions`

### Request Body
```json
{
  "trialId": "string",
  "surveyId": "string",
  "answers": [
    {
      "questionId": "string",
      "answer": "string"
    }
  ]
}
```

### Validation Rules
- All fields (trialId, surveyId, answers) are required
- The answers array must contain responses for all questions in the survey
- All question IDs in the answers must exist in the survey
- The survey must exist for the given trial

### Response
```json
{
  "id": "string",
  "trialId": "string",
  "surveyId": "string",
  "answers": [
    {
      "questionId": "string",
      "answer": "string"
    }
  ],
  "submittedAt": "date"
}
```

### Error Responses
- `400 Bad Request`: If required fields are missing or validation fails
- `404 Not Found`: If the survey doesn't exist
- `500 Internal Server Error`: If there was an error submitting the survey 