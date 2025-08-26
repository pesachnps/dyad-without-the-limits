# Dyad

Dyad is a local, open-source AI app builder. It's fast, private, and fully under your control — like Lovable, v0, or Bolt, but running right on your machine.

![Image](https://github.com/user-attachments/assets/f6c83dfc-6ffd-4d32-93dd-4b9c46d17790)

## 🚀 Features

- ⚡️ **Local**: Fast, private and no lock-in.
- 🛠 **Bring your own keys**: Use your own AI API keys — no vendor lock-in.
- 🖥️ **Cross-platform**: Easy to run on Mac or Windows.

## 🧰 Prerequisites

- Node.js >= 20
- npm (comes with Node.js)
- Git

You can verify your versions:

```bash
node -v
npm -v
```

## 🏗️ Install (from source)

```bash
git clone https://github.com/dyad-sh/dyad.git
cd dyad
npm install
```

## ▶️ Run locally (development)

- Start the app with the default configuration:

```bash
npm start
```

- Optionally, point the app to a locally running engine (on http://localhost:8080/v1):

```bash
npm run dev:engine
```

### Environment variables (optional)

- `DYAD_ENGINE_URL`: URL of the Dyad engine (defaults to built-in configuration).
- `DYAD_GATEWAY_URL`: URL of a compatible gateway if you prefer to route requests.

Example:

```bash
DYAD_ENGINE_URL=http://localhost:8080/v1 npm start
```

## 📦 Build installers (make)

Create platform-specific distributables:

```bash
npm run make
```

Outputs are written to the `out/` directory.

## 🧪 Tests and linting

```bash
# Unit tests
npm test

# Lint
npm run lint

# Prettier check
npm run prettier:check
```

## 🤝 Community

Join our growing community of AI app builders on **Reddit**: [r/dyadbuilders](https://www.reddit.com/r/dyadbuilders/) — share your projects and get help from the community!

## 🛠️ Contributing

If you're interested in contributing to Dyad, please read our [contributing](./CONTRIBUTING.md) doc.

## 📄 License

MIT License — see [LICENSE](./LICENSE).
