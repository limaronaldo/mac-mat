# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a DevOps/infrastructure management repository for MBRAS web properties. It contains helper scripts and documentation for managing Vercel deployments and GitHub repository connections across the MBRAS ecosystem.

## Related Repositories

All repositories are under the **MBRAS-Emprendimentos** GitHub organization:

| Repository | Domain | Framework |
|------------|--------|-----------|
| administracao-bens | gestaoadm.mbras.com.br | SolidStart/Vinxi |
| condominio-fendi | condominio-cj.mbras.com.br | Next.js |
| mbras-web-lp | lp.mbras.com.br | Next.js |
| mbras-web-lux | lux600.mbras.com.br | React/Vite |
| stoc-re | stoc.mbras.com.br | Next.js |

## Vercel Configuration

- **Team:** mbras
- **Project:** mac-mat

### Common Vercel Commands

vercel switch mbras          # Switch to MBRAS team
vercel project ls            # List all projects
vercel project inspect NAME  # Check project status
vercel ls NAME               # View recent deployments
vercel link --yes            # Link local directory to Vercel

## Analytics Configuration

All MBRAS sites should use:
- **GTM ID:** GTM-KRXT5L6C
- **GA4 ID:** G-LN2CTCN83S

When adding GTM to a new project, always include a hardcoded fallback to ensure tracking works even if environment variables are not set.

## Helper Scripts

- link-vercel-projects.py - Analyzes local projects and their Vercel/GitHub connection status
- connect-repos.sh - Connects local projects to their GitHub remotes
