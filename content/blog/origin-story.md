---
title: "The Origin Story: From Community Problem to Go Microservices"
description: "How a blocked video downloader sparked the creation of YTATools - a complete ecosystem for content creator automation"
date: 2025-08-23
tags: ["origin-story", "build-in-public", "go", "python", "oauth2"]
readingTime: 8
---

## The Problem: When cobalt.tools Got Blocked

It all started in a YouTube automation community. The goal was simple: teach members to use AI tools, outsourcing strategies, and algorithm optimization to produce daily 15+ minute videos with minimal effort.

Our secret weapon? [cobalt.tools](https://cobalt.tools) - an online video downloader that let us analyze competitor content and create new videos based on successful patterns. It was working great until... YouTube started blocking online downloaders.

Suddenly, our entire workflow was broken.

## The Developer's Advantage

As a software developer, I already had a solution sitting in my project folder - a Python desktop app using `yt-dlp` for video downloads. It was part of a larger, unfinished project, but it did exactly what we needed.

Instead of keeping it to myself, I decided to share it with the community. Not for free, of course - I saw an opportunity to build something bigger.

That's when I registered `ytatools.com` - **"You Too Automation Tools"** - envisioning an entire ecosystem of automation tools for content creators and side hustlers.

## Phase 1: The Python Struggle

The original YTA downloader was a Python desktop application with these specs:
- **Core**: yt-dlp wrapper for video downloads
- **GUI**: Cross-platform desktop interface
- **Targets**: macOS, Windows, Linux
- **Distribution**: GitHub Actions with artifact storage

### The Build Size Nightmare

Everything seemed great until I hit the first major roadblock: **build sizes**.

- macOS: ~250MB ✅
- Windows: ~250MB ✅  
- Linux: **3GB** 💥

I ran out of GitHub's free artifact storage quota almost immediately. But the real killer wasn't the storage - it was the second problem.

### The OAuth2 Desktop Dilemma

I wanted to implement a freemium model:
- **Base users**: Limited features (1080p downloads only)
- **Sponsored users**: Premium features (4K, playlists, metadata, API access)

To verify sponsorship status, I needed to check GitHub Sponsors and Patreon APIs. This requires OAuth2 with client secrets.

**The problem**: Desktop applications can't securely store client secrets. They're distributed to users' machines where anyone can extract them.

## Phase 2: The Service Architecture Evolution

### First Attempt: Auth Service

My solution was to extract authentication into a separate service. I created `auth-service` in Go - a dedicated OAuth2 handler that would:
1. Handle GitHub/Patreon OAuth flows
2. Verify sponsorship status  
3. Issue JWT tokens to the desktop app

But I misunderstood the OAuth2 flow initially. I was still trying to do local authentication, which meant the client secret problem remained unsolved.

### The VPS Deployment Reality Check

When I tried to deploy the auth service to a VPS, I hit another wall: **legal complexity**.

- Terms of Service required
- Privacy Policy needed
- GDPR compliance for EU users
- Personal data handling responsibilities

**I didn't want to handle ANY personal data.** I only needed to know: "Is this user a sponsor or not?"

### The Token Exchange Breakthrough

This led to the **token exchange architecture**:

```
Desktop App → Local Auth Service → VPS Auth Service → GitHub/Patreon
```

**Key insight**: Keep ALL personal data on the client machine. The VPS only handles:
1. OAuth2 client credentials (secure)
2. Token exchange (no data storage)
3. Sponsorship verification (API calls only)

This approach is completely GDPR-compliant because we never store personal information.

## Phase 3: The Go Migration Decision

With the authentication architecture sorted, I revisited the Python desktop app. The build size issue was still a blocker, and I realized something:

**If I have to package the entire Python runtime anyway, why not rewrite it in Go?**

Benefits of Go migration:
- **Smaller binaries**: Single executable, no runtime dependencies
- **Better performance**: Compiled language advantages  
- **Easier deployment**: No Python environment setup
- **Consistent language**: Same as the auth services

## Current Architecture: Multi-Service Ecosystem

Today, YTATools consists of four main components:

### 1. `go-downloader/` - Desktop Application
- **Language**: Go with Fyne GUI framework
- **Features**: Video downloads with tier-based limitations
- **APIs**: REST API and MCP server for sponsored users
- **Database**: SQLite with encryption for local data

### 2. `auth-service/` - VPS Authentication
- **Language**: Go with Gin framework
- **Purpose**: OAuth2 flows and sponsorship verification
- **Deployment**: VPS with Docker + Traefik
- **Security**: PKCE flows, JWT tokens, rate limiting

### 3. `local-auth-service/` - Client Authentication  
- **Language**: Go
- **Purpose**: Local authentication handling and token management
- **Benefits**: No personal data leaves user's machine
- **Integration**: Communicates with VPS auth service for verification

### 4. `yta-tools-site/` - Marketing Site
- **Technology**: Hugo static site with TailwindCSS
- **Content**: Data-driven with YAML configuration
- **Deployment**: Docker with Traefik SSL termination  
- **Features**: Blog (this post!), tool showcase, pricing

## The Freemium Model in Action

### Base Users Get:
- Unlimited video downloads up to 1080p
- GUI-only access
- No playlists, thumbnails, metadata, or subtitles

### Sponsored Users Get:
- Downloads up to 4K resolution
- Playlist downloads with organized subfolders
- Complete metadata, thumbnails, and subtitles
- Whisper AI subtitle generation
- REST API access for automation
- MCP server for AI tool integration

## What's Next: Build in Public

This origin story is the beginning of a **build in public** journey. I'll be documenting:

- Development challenges and solutions
- Architecture decisions and trade-offs  
- Community feedback and feature requests
- Performance optimizations and scaling
- New tool additions to the ecosystem

## The Meta Lesson

This project taught me that **real problems lead to better solutions**. What started as a simple "let's share this tool" became a complete rethinking of:
- Desktop application security
- Privacy-first architecture  
- Freemium business models
- Service-oriented design

Sometimes the best way to solve a problem is to rebuild everything from first principles.

---

*Want to follow the journey? [Star the project on GitHub](https://github.com/YTAtools) or check back here for regular updates. The download will be available soon!*