# Express + TypeScript Boilerplate

A minimal, batteries‑included Express 5 backend starter written in TypeScript. It ships with strict TypeScript config, fast DX with ts-node-dev, Jest + Supertest for testing, ESLint 9 + typescript-eslint + Prettier, Husky pre-commit hooks, CORS/cookies/env setup, and structured logging with Winston.

## Features

- Express 5 with TypeScript (strict mode) and clean project layout
- Fast local dev with ts-node-dev (auto-restart, transpile-only)
- Testing with Jest + ts-jest + Supertest
- Linting with ESLint 9 and typescript-eslint; formatting with Prettier
- Husky pre-commit hook with lint-staged that auto-fixes linting and formatting issues
- Environment variables via dotenv (.env/.env.example)
- CORS and cookie-parser pre-wired
- Structured, colored logs via Winston (console + `logs/all.log` + `logs/error.log`)
- Health check endpoint and example feature (`hello-world`) with controller/service layering
- Graceful shutdown and basic process-level error handlers

## Tech stack

- Node.js, Express 5
- TypeScript 5, ts-node-dev
- Jest + ts-jest, Supertest
- ESLint 9, typescript-eslint, Prettier, lint-staged, Husky
- Winston

## Project structure

```
.
├─ .env                # Local environment (gitignored)
├─ .env.example        # Example env vars to copy
├─ eslint.config.mjs   # ESLint 9 flat config
├─ jest.config.js      # Jest + ts-jest config
├─ package.json
├─ tsconfig.json       # Strict TS config, outDir=dist
├─ logs/               # Winston file transports (created at runtime)
└─ src/
   ├─ index.ts         # Server bootstrap and signal handlers
   ├─ app.ts           # Express app wiring (middlewares, routes)
   ├─ app.test.ts      # Sample Jest + Supertest tests
   ├─ controllers/
   │  └─ helloWorld.controller.ts
   ├─ routes/
   │  └─ helloWorld.route.ts
   ├─ services/
   │  └─ helloWorld.service.ts
   ├─ middlewares/
   │  └─ logger.middleware.ts
   └─ utils/
      └─ logger.ts
```

## Quick start

Prerequisites:

- Node.js 18+ (recommended) and npm

1. Install dependencies

```bash
npm install
```

2. Configure environment

```bash
cp .env.example .env
# Edit .env as needed
```

`.env` variables used:

- `PORT` (default 3000)
- `NODE_ENV` (e.g., development, production)
- `SITE_URL` (e.g., http://localhost:3000) — used for log messages and CORS origin

3. Start in development

```bash
npm run dev
```

4. Build and run (production)

```bash
npm run build
npm start
```

## NPM scripts

- `dev` — start in watch mode with ts-node-dev
- `build` — compile TypeScript to `dist/`
- `start` — run compiled app from `dist/index.js`
- `test` — run Jest test suite
- `lint` — run ESLint across the repo
- `format` — apply Prettier formatting
- `typecheck` — run TypeScript type checking without emitting files
- `prepare` — install Husky hooks

Note: The pre-commit hook uses lint-staged to automatically fix linting and formatting issues on staged files:

```
.husky/pre-commit
npx lint-staged
```

Lint-staged is configured in `package.json` to run ESLint with auto-fix and Prettier on all staged `*.{ts,js,json,md}` files.

## API

Base app mounts endpoints in `src/app.ts`.

- Health check
  - GET `/health`
  - Response (200):
    ```json
    {
      "status": "OK",
      "timestamp": "2025-01-01T00:00:00.000Z",
      "uptime": 12.345,
      "environment": "development",
      "version": "1.0.0"
    }
    ```
  - Example:
    ```bash
    curl -s http://localhost:3000/health | jq
    ```

- Hello World
  - GET `/hello-world`
  - Response (200):
    ```json
    { "message": "Hello World" }
    ```

## Middlewares

- JSON body parser and urlencoded parser (built-in Express)
- cookie-parser
- CORS with credentials enabled; origin comes from `SITE_URL` (fallback `http://localhost:3000`)
- Request logging middleware (`src/middlewares/logger.middleware.ts`) logs method, URL, status, duration, and user-agent. 4xx/5xx are logged at `warn`, others at `http` level.

## Logging

`src/utils/logger.ts` configures Winston with:

- Log levels: error, warn, info, http, debug; level auto-sets to `debug` in development and `warn` otherwise
- Console output with timestamp and colors
- File outputs:
  - `logs/error.log` (level >= error)
  - `logs/all.log` (all levels)

## Graceful shutdown & resilience

`src/index.ts` includes:

- Graceful shutdown on `SIGTERM`/`SIGINT` with a 10s force-exit fallback
- Handlers for `uncaughtException` and `unhandledRejection`

## Testing

Jest is preconfigured with ts-jest and Supertest.

- Run tests:
  ```bash
  npm test
  ```
- Add tests under `src/**/*.test.ts`. Example: `src/app.test.ts` covers `/health` and `/hello-world`.

Config: see `jest.config.js` (Node environment; ts-jest transform; ignores `dist/`).

## Linting & formatting

- ESLint flat config at `eslint.config.mjs` with `@eslint/js`, `typescript-eslint`, and integrated Prettier
- ESLint now enforces Prettier formatting rules via `eslint-plugin-prettier`
- Prettier for formatting via `npm run format`

Ignore patterns (excerpt):

```js
globalIgnores(["dist/", "jest.config.js", "temp/"]),
```

## TypeScript

Key `tsconfig.json` options:

- `rootDir: src`, `outDir: dist`
- `strict: true`, `noUncheckedIndexedAccess: true`, `exactOptionalPropertyTypes: true`
- `esModuleInterop: true`, `isolatedModules: true`

Build with `npm run build` and run from `dist/` using `npm start`.

## Common tasks

- Add a new route
  1. Create a controller in `src/controllers/`
  2. Create a service in `src/services/` (optional but encouraged)
  3. Add a router in `src/routes/` and mount it in `src/app.ts`

- Add environment variables
  1. Add to `.env` and `.env.example`
  2. Read via `process.env.MY_VAR` (dotenv is loaded at app startup)

## Troubleshooting

- CORS errors: ensure `SITE_URL` in `.env` matches your frontend origin; credentials are enabled.
- Logs directory: Winston will write to `logs/all.log` and `logs/error.log`. Ensure the process has file write permissions.
- Port conflicts: set `PORT` in `.env` to an available port.

## Acknowledgements

- Express 5
- TypeScript, ts-node-dev
- Jest, ts-jest, Supertest
- ESLint, Prettier, Lint-staged, Husky
- Winston
