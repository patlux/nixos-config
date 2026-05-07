import { Type } from "typebox";

const DEFAULT_SEARXNG_URL = "http://127.0.0.1:8888";
const DEFAULT_CATEGORIES = "general";
const SEARCH_PRESETS = {
  general: {
    categories: "general",
    description: "Broad web search for current facts, docs, and general pages.",
  },
  code: {
    categories: "general,it",
    description: "Developer-focused search across web, docs, repositories, and programming resources.",
  },
  docs: {
    categories: "it,software wikis",
    description: "Documentation and software wiki search.",
  },
  packages: {
    categories: "packages",
    description: "Package registry search, e.g. npm, PyPI, crates.io, pkg.go.dev, RubyGems.",
  },
  qa: {
    categories: "q&a",
    description: "Question-and-answer search, e.g. Stack Overflow.",
  },
};
const SEARCH_PRESET_NAMES = Object.keys(SEARCH_PRESETS);
const DEFAULT_MAX_RESULTS = 8;
const MAX_RESULTS = 20;
const MAX_TEXT_BYTES = 50 * 1024;
const MAX_TEXT_LINES = 2_000;

function clampResultCount(value) {
  if (typeof value !== "number" || !Number.isFinite(value)) {
    return DEFAULT_MAX_RESULTS;
  }

  return Math.max(1, Math.min(MAX_RESULTS, Math.floor(value)));
}

function truncateText(text, maxBytes = MAX_TEXT_BYTES, maxLines = MAX_TEXT_LINES) {
  let output = String(text ?? "");
  let truncated = false;

  const lines = output.split(/\r?\n/);
  if (lines.length > maxLines) {
    output = lines.slice(0, maxLines).join("\n");
    truncated = true;
  }

  if (Buffer.byteLength(output, "utf8") > maxBytes) {
    output = Buffer.from(output, "utf8").subarray(0, maxBytes).toString("utf8");
    truncated = true;
  }

  return truncated ? `${output}\n\n[Truncated to ${maxLines} lines / ${maxBytes} bytes.]` : output;
}

function decodeHtmlEntities(value) {
  return String(value ?? "")
    .replace(/&#(\d+);/g, (_match, code) => String.fromCodePoint(Number(code)))
    .replace(/&#x([0-9a-f]+);/gi, (_match, code) => String.fromCodePoint(Number.parseInt(code, 16)))
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'");
}

function htmlToText(html) {
  return decodeHtmlEntities(
    String(html ?? "")
      .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, " ")
      .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, " ")
      .replace(/<noscript[^>]*>[\s\S]*?<\/noscript>/gi, " ")
      .replace(/<\/(p|div|section|article|h[1-6]|li|tr|blockquote)>/gi, "\n")
      .replace(/<br\s*\/?>/gi, "\n")
      .replace(/<[^>]+>/g, " ")
      .replace(/[ \t]+/g, " ")
      .replace(/\n\s+/g, "\n")
      .replace(/\n{3,}/g, "\n\n")
      .trim(),
  );
}

function absoluteSearxngUrl() {
  const raw = process.env.SEARXNG_URL || DEFAULT_SEARXNG_URL;
  return raw.replace(/\/+$/, "");
}

function resolveSearchProfile({ categories, preset }) {
  if (typeof categories === "string" && categories.trim()) {
    return {
      name: "custom",
      categories: categories.trim(),
      description: "Custom SearXNG categories.",
    };
  }

  const rawPreset = typeof preset === "string" && preset.trim() ? preset.trim().toLowerCase() : DEFAULT_CATEGORIES;
  const config = SEARCH_PRESETS[rawPreset];
  if (!config) {
    throw new Error(`Unknown search preset "${preset}". Use one of: ${SEARCH_PRESET_NAMES.join(", ")}.`);
  }

  return {
    name: rawPreset,
    categories: process.env.SEARXNG_CATEGORIES || config.categories,
    description: config.description,
  };
}

function formatSearchResult(result, index) {
  const title = decodeHtmlEntities(result.title || "Untitled").trim();
  const url = result.url || result.parsed_url?.join("") || "";
  const snippet = decodeHtmlEntities(result.content || "").replace(/\s+/g, " ").trim();
  const engine = result.engine ? ` [${result.engine}]` : "";
  const published = result.publishedDate || result.published_date;

  return [
    `${index}. **${title}**${engine}`,
    url ? `   ${url}` : undefined,
    published ? `   Published: ${published}` : undefined,
    snippet ? `   ${snippet}` : undefined,
  ]
    .filter(Boolean)
    .join("\n");
}

async function searchSearxng({ query, maxResults }, profile, signal) {
  const limit = clampResultCount(maxResults);
  const searchUrl = new URL(`${absoluteSearxngUrl()}/search`);
  searchUrl.searchParams.set("q", query);
  searchUrl.searchParams.set("format", "json");
  searchUrl.searchParams.set("language", "en-US");
  searchUrl.searchParams.set("safesearch", "0");
  searchUrl.searchParams.set("categories", profile.categories);

  const response = await fetch(searchUrl, {
    signal,
    headers: {
      Accept: "application/json",
      "User-Agent": "pi-searxng-search/1.0",
    },
  });

  if (!response.ok) {
    throw new Error(`SearXNG ${response.status}: ${truncateText(await response.text(), 1_000, 20)}`);
  }

  const payload = await response.json();
  const seen = new Set();
  const results = [];

  for (const result of payload.results || []) {
    const url = result.url || "";
    const key = url.replace(/[#?].*$/, "") || `${result.title}:${result.engine}`;
    if (seen.has(key)) {
      continue;
    }

    seen.add(key);
    results.push(result);
    if (results.length >= limit) {
      break;
    }
  }

  if (results.length === 0) {
    const suggestions = (payload.suggestions || []).slice(0, 5).join(", ");
    return suggestions ? `No results found. Suggestions: ${suggestions}` : "No results found.";
  }

  return results.map((result, index) => formatSearchResult(result, index + 1)).join("\n\n");
}

function assertHttpUrl(value) {
  const url = new URL(value);
  if (url.protocol !== "http:" && url.protocol !== "https:") {
    throw new Error("Only http:// and https:// URLs are supported.");
  }

  return url;
}

async function fetchWebPage(url, signal) {
  const target = assertHttpUrl(url);
  const response = await fetch(target, {
    signal,
    headers: {
      Accept: "text/html,text/plain,application/json,application/xml,text/xml;q=0.9,*/*;q=0.1",
      "User-Agent": "Mozilla/5.0 (compatible; pi-searxng-fetch/1.0)",
    },
  });

  if (!response.ok) {
    throw new Error(`Fetch ${response.status} ${response.statusText}`);
  }

  const contentType = response.headers.get("content-type") || "";
  if (!/(text\/|json|xml|javascript)/i.test(contentType)) {
    return `Unsupported content type: ${contentType || "unknown"}`;
  }

  const body = await response.text();
  const text = /html/i.test(contentType) ? htmlToText(body) : body;
  return truncateText(text);
}

function textResult(text, details = {}) {
  return {
    content: [{ type: "text", text }],
    details,
  };
}

const searchParameters = Type.Object({
  query: Type.String({ description: "Search query." }),
  preset: Type.Optional(
    Type.String({
      description: `Search preset. One of: ${SEARCH_PRESET_NAMES.join(", ")}. Default: general.`,
    }),
  ),
  categories: Type.Optional(
    Type.String({
      description:
        "Advanced override for raw SearXNG categories, comma-separated. Overrides preset. Useful values: general,it,q&a,packages,software wikis.",
    }),
  ),
  maxResults: Type.Optional(Type.Number({ description: `Maximum results, 1-${MAX_RESULTS}. Default: ${DEFAULT_MAX_RESULTS}.` })),
});

const fetchParameters = Type.Object({
  url: Type.String({ description: "HTTP(S) URL to fetch." }),
});

export default function searxngSearchExtension(pi) {
  pi.registerTool({
    name: "web_search",
    label: "Web Search",
    description: "Search the web through the local SearXNG instance.",
    promptSnippet: "Search the web through local SearXNG.",
    promptGuidelines: [
      "Use web_search when current internet information is needed; choose preset 'general', 'code', 'docs', 'packages', or 'qa' before using raw categories.",
      "Use preset 'code' for developer topics, 'docs' for official documentation, 'packages' for registry lookup, and 'qa' for Stack Overflow style questions.",
      "Use web_fetch after web_search when the content of a specific result URL is needed.",
    ],
    parameters: searchParameters,
    async execute(_toolCallId, params, signal, onUpdate) {
      let profile;

      try {
        profile = resolveSearchProfile(params);
        onUpdate?.(textResult(`Searching SearXNG (${profile.name}: ${profile.categories}) for: ${params.query}`));

        const text = await searchSearxng(params, profile, signal);
        return textResult(text, {
          query: params.query,
          preset: profile.name,
          categories: profile.categories,
          searxngUrl: absoluteSearxngUrl(),
        });
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        return {
          ...textResult(`SearXNG search failed: ${message}`, {
            query: params.query,
            preset: profile?.name,
            categories: profile?.categories,
            searxngUrl: absoluteSearxngUrl(),
          }),
          isError: true,
        };
      }
    },
  });

  pi.registerTool({
    name: "web_fetch",
    label: "Web Fetch",
    description: "Fetch a web page's text content. Truncated to 50KB / 2000 lines.",
    promptSnippet: "Fetch web page text content by URL.",
    promptGuidelines: ["Use web_fetch for a known URL; prefer web_search first when discovering sources."],
    parameters: fetchParameters,
    async execute(_toolCallId, params, signal, onUpdate) {
      onUpdate?.(textResult(`Fetching URL: ${params.url}`));

      try {
        const text = await fetchWebPage(params.url, signal);
        return textResult(text, { url: params.url });
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        return {
          ...textResult(`Web fetch failed: ${message}`, { url: params.url }),
          isError: true,
        };
      }
    },
  });
}
