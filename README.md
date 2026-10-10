# @auroraview/sdk

[![npm version](https://img.shields.io/npm/v/@auroraview/sdk.svg)](https://www.npmjs.com/package/@auroraview/sdk)
[![CI](https://github.com/try-auroraview/auroraview-web-sdk/actions/workflows/ci.yml/badge.svg)](https://github.com/try-auroraview/auroraview-web-sdk/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Framework-agnostic SDK for AuroraView WebView bridge. Provides type-safe APIs for communication between JavaScript and Python in AuroraView applications.

This is the **web (TypeScript) SDK** only. It is maintained as a standalone repository so it can version, test and release independently of the AuroraView core. The Rust core and the Python host API live in [`try-auroraview/auroraview`](https://github.com/try-auroraview/auroraview).

> **Migrated from** `try-auroraview/auroraview` at `packages/auroraview-sdk` (v0.5.13). The full commit history of that subtree is preserved here.

## Features

- 🎯 **Type-safe** - Full TypeScript support with comprehensive type definitions
- 🔌 **Framework Adapters** - First-class support for React and Vue 3
- 📡 **IPC Communication** - Call Python methods, invoke plugin commands, and emit events
- 🔄 **State Sync** - Reactive shared state between JavaScript and Python
- 📁 **File System API** - Read, write, and manage files
- 💬 **Dialog API** - Native file dialogs and message boxes
- 📋 **Clipboard API** - Read and write clipboard content
- 🐚 **Shell API** - Execute commands and open URLs

## Installation

```bash
npm install @auroraview/sdk
# or
pnpm add @auroraview/sdk
# or
yarn add @auroraview/sdk
```

## Quick Start

### Vanilla JavaScript/TypeScript

```typescript
import { createAuroraView } from '@auroraview/sdk';

const av = createAuroraView();

// Wait for bridge to be ready
await av.whenReady();

// Call a Python method
const result = await av.call('api.greet', { name: 'World' });

// Invoke a plugin command
const files = await av.invoke('plugin:fs|read_dir', { path: '/tmp' });

// Subscribe to events
av.on('custom:event', (data) => {
  console.log('Received:', data);
});

// Emit events to Python
av.emit('user:action', { type: 'click' });
```

### React

```tsx
import { useAuroraView, useAuroraEvent, useAuroraCall, useAuroraState } from '@auroraview/sdk/react';

function App() {
  const { client, isReady } = useAuroraView();
  
  // Subscribe to events
  useAuroraEvent('notification', (data) => {
    console.log('Notification:', data);
  });

  // Call API with loading/error states
  const { execute, loading, data, error } = useAuroraCall<string>('api.greet');

  // Reactive shared state
  const [theme, setTheme] = useAuroraState<string>('theme', 'light');

  return (
    <div>
      <button onClick={() => execute({ name: 'World' })} disabled={loading || !isReady}>
        {loading ? 'Loading...' : 'Greet'}
      </button>
      {data && <p>Result: {data}</p>}
      {error && <p>Error: {error.message}</p>}
      <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
        Theme: {theme}
      </button>
    </div>
  );
}
```

### Vue 3

```vue
<script setup lang="ts">
import { useAuroraView, useAuroraEvent, useAuroraCall, useAuroraState } from '@auroraview/sdk/vue';

const { client, isReady } = useAuroraView();

// Subscribe to events
useAuroraEvent('notification', (data) => {
  console.log('Notification:', data);
});

// Call API with loading/error states
const { execute, loading, data, error } = useAuroraCall<string>('api.greet');

// Reactive shared state
const theme = useAuroraState<string>('theme', 'light');
</script>

<template>
  <div>
    <button @click="execute({ name: 'World' })" :disabled="loading || !isReady">
      {{ loading ? 'Loading...' : 'Greet' }}
    </button>
    <p v-if="data">Result: {{ data }}</p>
    <p v-if="error">Error: {{ error.message }}</p>
    <button @click="theme = theme === 'light' ? 'dark' : 'light'">
      Theme: {{ theme }}
    </button>
  </div>
</template>
```

## API Reference

### Core Client

```typescript
interface AuroraViewClient {
  // RPC-style call to Python method
  call<T>(method: string, params?: unknown): Promise<T>;
  
  // Invoke plugin command
  invoke<T>(cmd: string, args?: Record<string, unknown>): Promise<T>;
  
  // Fire-and-forget event to Python
  emit(event: string, data?: unknown): void;
  
  // Subscribe to events from Python
  on<T>(event: string, handler: (data: T) => void): () => void;
  
  // Subscribe once
  once<T>(event: string, handler: (data: T) => void): () => void;
  
  // Unsubscribe
  off(event: string, handler?: EventHandler): void;
  
  // Check if bridge is ready
  isReady(): boolean;
  
  // Wait for bridge to be ready
  whenReady(): Promise<AuroraViewClient>;
  
  // Built-in APIs
  readonly fs: FileSystemAPI | undefined;
  readonly dialog: DialogAPI | undefined;
  readonly clipboard: ClipboardAPI | undefined;
  readonly shell: ShellAPI | undefined;
  readonly state: AuroraViewState | undefined;
}
```

### React Hooks

| Hook | Description |
|------|-------------|
| `useAuroraView()` | Get client instance and ready state |
| `useAuroraEvent(event, handler)` | Subscribe to an event |
| `useAuroraEvents(events)` | Subscribe to multiple events |
| `useAuroraCall<T>(method)` | Call API with loading/error states |
| `useAuroraInvoke<T>(cmd)` | Invoke plugin with loading/error states |
| `useAuroraState<T>(key, default?)` | Reactive shared state |
| `useProcessEvents(options)` | Subscribe to process stdout/stderr/exit |

### Vue Composables

| Composable | Description |
|------------|-------------|
| `useAuroraView()` | Get client ref and ready state |
| `useAuroraEvent(event, handler)` | Subscribe to an event |
| `useAuroraEvents(events)` | Subscribe to multiple events |
| `useAuroraCall<T>(method)` | Call API with reactive loading/error |
| `useAuroraInvoke<T>(cmd)` | Invoke plugin with reactive loading/error |
| `useAuroraState<T>(key, default?)` | Two-way reactive shared state |
| `useProcessEvents(options)` | Subscribe to process events |

### File System API

```typescript
const av = createAuroraView();

// Read file
const content = await av.fs?.readFile('/path/to/file.txt');

// Write file
await av.fs?.writeFile('/path/to/file.txt', 'Hello World');

// Read directory
const entries = await av.fs?.readDir('/path/to/dir', true); // recursive

// Check existence
const exists = await av.fs?.exists('/path/to/file.txt');

// Get file stats
const stat = await av.fs?.stat('/path/to/file.txt');

// Create directory
await av.fs?.createDir('/path/to/new/dir', true); // recursive

// Copy/Move/Delete
await av.fs?.copy('/from', '/to');
await av.fs?.rename('/from', '/to');
await av.fs?.remove('/path', true); // recursive
```

### Dialog API

```typescript
const av = createAuroraView();

// Open file dialog
const { path, cancelled } = await av.dialog?.openFile({
  title: 'Select File',
  filters: [{ name: 'Images', extensions: ['png', 'jpg'] }]
});

// Open folder dialog
const { path } = await av.dialog?.openFolder();

// Save file dialog
const { path } = await av.dialog?.saveFile({
  defaultName: 'document.txt'
});

// Message dialogs
await av.dialog?.info('Operation completed', 'Success');
await av.dialog?.warning('Are you sure?', 'Warning');
await av.dialog?.error('Something went wrong', 'Error');

// Confirmation
const confirmed = await av.dialog?.ask('Delete this file?', 'Confirm');
```

### Clipboard API

```typescript
const av = createAuroraView();

// Text
await av.clipboard?.writeText('Hello');
const text = await av.clipboard?.readText();

// Image (base64)
const imageData = await av.clipboard?.readImage();
await av.clipboard?.writeImage(base64Data);

// Clear
await av.clipboard?.clear();
```

### Shell API

```typescript
const av = createAuroraView();

// Open URL in browser
await av.shell?.open('https://example.com');

// Open file with default app
await av.shell?.openPath('/path/to/document.pdf');

// Show in file manager
await av.shell?.showInFolder('/path/to/file');

// Execute command
const { code, stdout, stderr } = await av.shell?.execute('ls', ['-la']);

// Spawn process (non-blocking)
const { pid } = await av.shell?.spawn('node', ['server.js']);

// Get environment
const path = await av.shell?.getEnv('PATH');
const allEnv = await av.shell?.getEnvAll();
```

## TypeScript Support

The SDK is written in TypeScript and provides comprehensive type definitions. All APIs are fully typed.

```typescript
import type {
  AuroraViewClient,
  EventHandler,
  FileFilter,
  DirEntry,
  FileStat,
  ExecuteResult,
  // ... and more
} from '@auroraview/sdk';
```

## Browser Compatibility

The SDK is designed to work within AuroraView's WebView environment. It requires:
- ES2020+ support
- `window.auroraview` bridge object (injected by AuroraView runtime)

## Development

Commands run through [`vx`](https://github.com/loonghao/vx) so the toolchain is pinned for every contributor.

```bash
just              # list recipes
just install      # bun install
just typecheck    # tsc --noEmit
just test         # vitest
just test-cov     # vitest with coverage thresholds
just build        # dist/ (npm package)
just build-assets # assets/ (inject scripts consumed by the Rust core)
just test-e2e     # playwright
just ci           # typecheck + test + build-assets
```

`just build-assets` produces `assets/core`, `assets/plugins` and `assets/extensions`. Those scripts are embedded into the Rust binary by `auroraview-core` / `auroraview-extensions`; each release attaches them as `sdk-assets-v<version>.tar.gz` and the core repo vendors a pinned copy via its `sync-sdk-assets` workflow.

## Releasing

Releases are fully automated by [release-please](https://github.com/googleapis/release-please):

1. Land [conventional commits](https://www.conventionalcommits.org/) on `main`.
2. release-please opens/updates a release PR with the changelog and version bump.
3. Merging it tags `v<version>`, runs the full CI suite, publishes `@auroraview/sdk` to npm via OIDC trusted publishing, and attaches the inject assets to the GitHub release.

No `NPM_TOKEN` is required — authentication uses GitHub's OIDC token. A one-time trusted-publisher entry must exist on npm for `try-auroraview/auroraview-web-sdk` + `release.yml` + environment `npm`.

## License

MIT © [AuroraView Contributors](https://github.com/try-auroraview/auroraview-web-sdk)

## Links

- [Documentation](https://try-auroraview.github.io/auroraview/)
- [AuroraView core (Rust + Python)](https://github.com/try-auroraview/auroraview)
- [Issue Tracker](https://github.com/try-auroraview/auroraview-web-sdk/issues)
