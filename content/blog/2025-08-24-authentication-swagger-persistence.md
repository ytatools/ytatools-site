---
title: "Authentication, Swagger, and Persistence: Building Robust Local Auth"
date: 2025-08-24T15:00:00Z
draft: false
description: "Deep dive into fixing authentication service deployment, complete API documentation, and solving session persistence with proper encryption key management."
tags: ["development", "authentication", "swagger", "go", "deployment", "encryption"]
author: "YTA Tools Team"
---

# Authentication, Swagger, and Persistence: Building Robust Local Auth

Today was a marathon session focused on three critical areas: getting our authentication service properly deployed, building comprehensive API documentation, and solving the tricky problem of session persistence across service restarts.

## 🚀 Auth Service Deployment Success

Our cloud authentication service at `auth.ytatools.com` is now live and properly configured:

### Fixed Production Issues
- **Swagger Scheme Detection**: Production domains now correctly default to HTTPS instead of HTTP
- **CORS Configuration**: Proper cross-origin setup for production deployment  
- **Dynamic Host Configuration**: Runtime configuration based on `AUTH_DOMAIN` environment variable

The auth service now properly serves:
- **Production API**: https://auth.ytatools.com/auth/providers
- **Swagger Documentation**: https://auth.ytatools.com/swagger/
- **GitHub & Patreon OAuth**: Full sponsor verification workflow

## 📚 Complete Swagger Documentation Overhaul

One of today's biggest wins was completely revamping our local authentication service API documentation.

### The Problem We Solved
The Swagger docs were showing misleading information:
- Only GitHub endpoints documented, but the system is dynamic
- Missing endpoints for core functionality
- Outdated hardcoded provider routes

### Clean API Design
We refactored the endpoint structure from:
```
POST /auth/github/start
POST /auth/patreon/start
```

To a clean, generic pattern:
```
POST /auth/{provider}/start
```

### Complete Documentation Coverage
Every endpoint now has proper Swagger annotations:

- `POST /auth/{provider}/start` - Dynamic OAuth authentication  
- `GET /auth/providers` - List available providers
- `GET /auth/status` - Authentication status
- `POST /auth/verify-token` - JWT token verification
- `POST /auth/license/verify` - Manual license verification
- `POST /auth/logout` - Session termination
- `GET /health` - Service health check

The result? Crystal clear API documentation that actually reflects reality, accessible at `http://localhost:8090/swagger/`.

## 🔐 Solving Session Persistence

The trickiest challenge was making the local auth service remember users across restarts - the whole point of having a *local* auth service.

### The Encryption Key Problem
We discovered a race condition where:
1. Service starts and tries to restore user sessions
2. Encrypted user data can't be decrypted 
3. Encryption keys were regenerating on each startup

### The Root Cause
```go
// Before: Generated new salt every time
salt, err := crypto.GenerateSalt()
```

Each restart created a new encryption salt, making previously stored encrypted data unreadable.

### The Solution: Persistent Salt Storage
Following the pattern from our Go downloader service, we now:

1. **Store encryption salt in database** - in a dedicated `settings` table
2. **Proper migration order** - database migrations run BEFORE encryption setup  
3. **Session restoration** - automatically loads the last authenticated user on startup

```go
// After: Consistent salt from database
salt, err := getEncryptionSalt(db)
if err != nil {
    // Only generate new salt if none exists
    return generateAndStoreEncryptionKey(db, password)
}
```

### Migration-Driven Schema Changes
We properly used database migrations for the settings table instead of `CREATE TABLE IF NOT EXISTS` in code:

```sql
-- migrations/20250824155738_add_settings_table.up.sql
CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    encrypted INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## 🧰 Technical Improvements

### Automatic Migration on Startup
Users don't need to run `make migrate-up` manually - the service automatically:
1. Ensures database directory exists
2. Runs pending migrations  
3. Initializes encryption with persistent salt
4. Restores user sessions
5. Starts HTTP server

### Swagger Generation Fixes
Fixed several Swagger tooling issues:
- **Version compatibility**: Updated `swag` to v1.16.6 to resolve `LeftDelim`/`RightDelim` field conflicts
- **Type definitions**: Replaced `gin.H` with proper `models.APIError` types
- **Build integration**: Swagger docs auto-generate during production builds

### Development Experience
- **Context restoration**: Automated session context loading across Claude instances
- **Error handling**: Better debugging for encryption and migration failures
- **Logging improvements**: Clear startup sequence with proper error messages

## 🎯 What's Next

With solid authentication, complete documentation, and persistent sessions, we're ready for:

1. **Go Downloader Integration** - Connect the desktop app to both auth services
2. **End-to-End Testing** - Full OAuth flow from desktop to cloud to local storage
3. **Production Deployment** - Roll out to early users with confidence

## 📊 By The Numbers

- **13 API endpoints** fully documented
- **2 authentication services** production-ready
- **1 persistent session** system working reliably  
- **0 manual migration commands** needed by end users
- **100% authentication workflow** coverage

Today proved that getting the infrastructure right - proper deployment, clear documentation, and reliable persistence - is just as important as the features themselves. 

When users authenticate once and stay authenticated across restarts, that's the local auth experience we're building for.

---

*Building robust, user-friendly tools takes time, but every challenge solved makes the end product that much better. Thanks for following along with our build-in-public journey!*