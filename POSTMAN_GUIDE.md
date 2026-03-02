# Postman Testing Guide

## Quick Start

### Step 1: Install Postman
1. Download from [postman.com/downloads](https://www.postman.com/downloads/)
2. Install and launch Postman

### Step 2: Import Collection
1. Click **Import** button (top left corner)
2. Drag and drop `postman_collection.json` or click "Upload Files"
3. Select the file from your project directory
4. Click **Import**

### Step 3: Start Testing
1. Expand **Movie Streaming Platform API** collection in the sidebar
2. Click on any request
3. Click **Send** button
4. View response in the bottom panel

---

## Manual Request Setup

If you prefer to create requests manually, follow these instructions:

### Setting Up the Collection

1. Click **New** → **Collection**
2. Name: `Movie Streaming Platform`
3. Description: `Microservices API Testing`
4. Click **Create**

### Creating Requests

#### 1. GET All Movies

```
Method: GET
URL: http://localhost:3000/api/movies
```

**Expected Response (200 OK):**
```json
{
  "movies": []
}
```

---

#### 2. POST Create Movie

```
Method: POST
URL: http://localhost:3000/api/movies
```

**Headers:**
- Key: `Content-Type`
- Value: `application/json`

**Body (select "raw" and "JSON"):**
```json
{
  "title": "The Matrix",
  "description": "A computer hacker learns about the true nature of reality and his role in the war against its controllers"
}
```

**Expected Response (201 Created):**
```json
{
  "message": "movie The Matrix inserted successfully"
}
```

---

#### 3. GET Movie by ID

```
Method: GET
URL: http://localhost:3000/api/movies/1
```

**Expected Response (200 OK):**
```json
{
  "id": 1,
  "title": "The Matrix",
  "description": "A computer hacker learns about the true nature of reality and his role in the war against its controllers"
}
```

---

#### 4. GET Movies with Filter

```
Method: GET
URL: http://localhost:3000/api/movies?title=Matrix
```

**Query Parameters:**
- Key: `title`
- Value: `Matrix`

**Expected Response (200 OK):**
```json
{
  "movies": [
    {
      "id": 1,
      "title": "The Matrix",
      "description": "A computer hacker learns about the true nature of reality and his role in the war against its controllers"
    }
  ]
}
```

---

#### 5. PUT Update Movie

```
Method: PUT
URL: http://localhost:3000/api/movies/1
```

**Headers:**
- Key: `Content-Type`
- Value: `application/json`

**Body (raw JSON):**
```json
{
  "title": "The Matrix Reloaded",
  "description": "Neo and the rebel leaders estimate that they have 72 hours until Zion is destroyed"
}
```

**Expected Response (200 OK):**
```json
{
  "message": "movie 1 updated"
}
```

---

#### 6. POST Create Billing Order

```
Method: POST
URL: http://localhost:3000/api/billing/
```

**Important:** Note the trailing slash `/` in the URL!

**Headers:**
- Key: `Content-Type`
- Value: `application/json`

**Body (raw JSON):**
```json
{
  "user_id": 1,
  "number_of_items": 2,
  "total_amount": 29.99
}
```

**Expected Response (200 OK):**
```json
{
  "message": "{'user_id': 1, 'number_of_items': 2, 'total_amount': 29.99} sent"
}
```

**Note:** The order is queued in RabbitMQ and processed asynchronously by the billing service.

---

#### 7. DELETE Movie by ID

```
Method: DELETE
URL: http://localhost:3000/api/movies/1
```

**Expected Response (200 OK):**
```json
{
  "message": "The Matrix deleted"
}
```

---

#### 8. DELETE All Movies

```
Method: DELETE
URL: http://localhost:3000/api/movies
```

**Expected Response (200 OK):**
```json
{
  "message": "all movies deleted successfully"
}
```

---

## Testing Workflow

### Scenario 1: Basic CRUD Operations

1. **GET All Movies** - Verify empty list
2. **POST Create Movie** - Add "The Matrix"
3. **POST Create Movie** - Add "Inception"
4. **POST Create Movie** - Add "Interstellar"
5. **GET All Movies** - Verify 3 movies exist
6. **GET Movie by ID** - Get movie with ID 1
7. **PUT Update Movie** - Update movie 1
8. **GET Movie by ID** - Verify update
9. **DELETE Movie by ID** - Delete movie 1
10. **GET All Movies** - Verify 2 movies remain

### Scenario 2: Search and Filter

1. **POST Create Movie** - Add "The Matrix"
2. **POST Create Movie** - Add "The Matrix Reloaded"
3. **POST Create Movie** - Add "Inception"
4. **GET Movies with Filter** - Search for "Matrix" (should return 2)
5. **GET Movies with Filter** - Search for "Inception" (should return 1)

### Scenario 3: Billing Orders

1. **POST Create Order** - user_id: 1, items: 2, amount: 29.99
2. **POST Create Order** - user_id: 2, items: 5, amount: 99.99
3. **POST Create Order** - user_id: 3, items: 1, amount: 14.99
4. **Verify in Terminal:**
   ```bash
   sudo docker compose exec billing-db psql -U user01 -d billing_db -c "SELECT * FROM orders;"
   ```

### Scenario 4: Message Queue Resilience

1. **Stop Billing Service:**
   ```bash
   sudo docker compose stop billing-app
   ```

2. **POST Create Order** - Send multiple orders (they'll queue)

3. **Restart Billing Service:**
   ```bash
   sudo docker compose start billing-app
   ```

4. **Wait 3 seconds** - Let the service process queued messages

5. **Verify Orders** - Check database to confirm all orders were processed

---

## Advanced Postman Features

### Using Environment Variables

1. Click **Environments** (left sidebar)
2. Click **+** to create new environment
3. Name: `Local Development`
4. Add variables:
   - `base_url` = `http://localhost:3000`
   - `api_version` = `api`

5. Update URLs to use variables:
   ```
   {{base_url}}/{{api_version}}/movies
   ```

### Adding Tests

Click the **Tests** tab in any request and add:

```javascript
// Test status code
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

// Test response time
pm.test("Response time is less than 500ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(500);
});

// Test response structure
pm.test("Response has correct structure", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('movies');
    pm.expect(jsonData.movies).to.be.an('array');
});

// Save data for next request
pm.test("Save movie ID", function () {
    var jsonData = pm.response.json();
    if (jsonData.movies && jsonData.movies.length > 0) {
        pm.environment.set("movie_id", jsonData.movies[0].id);
    }
});
```

### Using Collection Runner

1. Click **Runner** button (bottom right)
2. Select your collection
3. Set iterations (how many times to run)
4. Set delay between requests
5. Click **Run**
6. View results and test passes/failures

### Pre-request Scripts

Generate dynamic data before sending requests:

```javascript
// Generate random user ID
pm.environment.set("random_user_id", Math.floor(Math.random() * 1000));

// Generate timestamp
pm.environment.set("timestamp", new Date().toISOString());

// Generate random amount
pm.environment.set("random_amount", (Math.random() * 100).toFixed(2));
```

Then use in body:
```json
{
  "user_id": {{random_user_id}},
  "number_of_items": 2,
  "total_amount": {{random_amount}}
}
```

---

## Troubleshooting

### Connection Refused
- **Problem:** Cannot connect to localhost:3000
- **Solution:** Ensure Docker containers are running:
  ```bash
  sudo docker compose ps
  ```

### 404 Not Found
- **Problem:** Endpoint not found
- **Solution:** Check URL path. Common mistakes:
  - Missing `/api/` prefix
  - Missing trailing `/` for billing endpoint
  - Wrong HTTP method

### 400 Bad Request
- **Problem:** Invalid request body
- **Solution:** 
  - Verify `Content-Type: application/json` header
  - Check JSON syntax (no trailing commas)
  - Ensure required fields are present

### 500 Internal Server Error
- **Problem:** Server error
- **Solution:** Check container logs:
  ```bash
  sudo docker compose logs api-gateway-app
  sudo docker compose logs inventory-app
  ```

### Orders Not Appearing in Database
- **Problem:** Billing orders sent but not in database
- **Solution:** 
  - Wait 2-3 seconds for async processing
  - Check billing-app logs:
    ```bash
    sudo docker compose logs billing-app
    ```
  - Verify RabbitMQ is running:
    ```bash
    sudo docker compose ps rabbit-queue
    ```

---

## Sample Data

Use these sample movies for testing:

```json
{
  "title": "The Matrix",
  "description": "A computer hacker learns about the true nature of reality and his role in the war against its controllers"
}
```

```json
{
  "title": "Inception",
  "description": "A thief who steals corporate secrets through dream-sharing technology is given the inverse task of planting an idea"
}
```

```json
{
  "title": "Interstellar",
  "description": "A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival"
}
```

```json
{
  "title": "The Shawshank Redemption",
  "description": "Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency"
}
```

```json
{
  "title": "Pulp Fiction",
  "description": "The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in four tales of violence and redemption"
}
```

---

## Next Steps

1. ✅ Import the collection
2. ✅ Test all endpoints
3. ✅ Add custom tests
4. ✅ Create environment variables
5. ✅ Run collection with Runner
6. ✅ Export and share with team

Happy Testing! 🚀
