# API Quick Reference

## Base URL
```
http://localhost:3000
```

## Inventory Endpoints

| Method | Endpoint | Description | Body Required |
|--------|----------|-------------|---------------|
| GET | `/api/movies` | Get all movies | No |
| GET | `/api/movies?title=<search>` | Search movies by title | No |
| GET | `/api/movies/<id>` | Get movie by ID | No |
| POST | `/api/movies` | Create new movie | Yes |
| PUT | `/api/movies/<id>` | Update movie | Yes |
| DELETE | `/api/movies/<id>` | Delete movie by ID | No |
| DELETE | `/api/movies` | Delete all movies | No |

## Billing Endpoints

| Method | Endpoint | Description | Body Required |
|--------|----------|-------------|---------------|
| POST | `/api/billing/` | Create order (async) | Yes |

---

## Request Examples

### Create Movie
```bash
POST /api/movies
Content-Type: application/json

{
  "title": "The Matrix",
  "description": "A hacker discovers reality is a simulation"
}
```

### Update Movie
```bash
PUT /api/movies/1
Content-Type: application/json

{
  "title": "Updated Title",
  "description": "Updated description"
}
```

### Create Order
```bash
POST /api/billing/
Content-Type: application/json

{
  "user_id": 1,
  "number_of_items": 2,
  "total_amount": 29.99
}
```

---

## Response Codes

| Code | Meaning | When |
|------|---------|------|
| 200 | OK | Successful GET, PUT, DELETE |
| 201 | Created | Successful POST (movie created) |
| 400 | Bad Request | Invalid JSON or missing fields |
| 404 | Not Found | Movie ID doesn't exist |
| 500 | Server Error | Internal server error |

---

## Postman Quick Setup

1. **Import Collection**: `postman_collection.json`
2. **Set Base URL**: Create environment variable `base_url = http://localhost:3000`
3. **Add Header**: `Content-Type: application/json` for POST/PUT requests
4. **Test**: Start with GET /api/movies

---

## Common Mistakes

❌ **Wrong**: `http://localhost:3000/movies`  
✅ **Correct**: `http://localhost:3000/api/movies`

❌ **Wrong**: `http://localhost:3000/api/billing` (no trailing slash)  
✅ **Correct**: `http://localhost:3000/api/billing/`

❌ **Wrong**: Missing Content-Type header  
✅ **Correct**: Add `Content-Type: application/json`

❌ **Wrong**: Invalid JSON (trailing comma)  
✅ **Correct**: Valid JSON syntax

---

## Testing Checklist

- [ ] GET all movies (empty)
- [ ] POST create 3 movies
- [ ] GET all movies (3 items)
- [ ] GET movie by ID
- [ ] GET movies with filter
- [ ] PUT update movie
- [ ] POST create billing order
- [ ] DELETE movie by ID
- [ ] DELETE all movies
- [ ] Verify orders in database

---

## Verify Orders in Database

```bash
# Wait 2 seconds after creating orders
sleep 2

# Check orders table
sudo docker compose exec billing-db psql -U user01 -d billing_db -c "SELECT * FROM orders;"
```

---

## Need Help?

- Full documentation: `README.md`
- Postman guide: `POSTMAN_GUIDE.md`
- View logs: `sudo docker compose logs -f`
- Check status: `sudo docker compose ps`
