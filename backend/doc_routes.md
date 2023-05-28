## Route: ***/store***

- Method: POST
- Receives: JSON ```{'message': 'AwesomeMessageHere', 'password': 'GreatPasswordHere'}```
- Returns code 200 with JSON ```{"key":"KeyForTheMessageHere"}```
- May also return code 400 with a JSON ```{"message":"Description of the problem"}```

## Route: ***/retrieve***

- Method: PATCH
- Receives: JSON ```{'key': 'KeyHere', 'password': 'PasswordHere'}``` 
- Returns code 200 with JSON ```{"message":"AwesomeMessageHere"}```
- May also return code 400 or 404 with a JSON ```{"message":"Description of the problem"}```
