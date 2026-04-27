import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const opencodeConfigDir = path.join(os.homedir(), ".config", "opencode");
const opencodeConfigNames = ["opencode.jsonc", "opencode.json"];

function exists(targetPath) {
  try {
    fs.accessSync(targetPath, fs.constants.F_OK);
    return true;
  } catch {
    return false;
  }
}

function isFile(targetPath) {
  try {
    return fs.statSync(targetPath).isFile();
  } catch {
    return false;
  }
}

function isDirectory(targetPath) {
  try {
    return fs.statSync(targetPath).isDirectory();
  } catch {
    return false;
  }
}

function listAncestorDirectories(cwd) {
  const directories = [];
  let current = path.resolve(cwd);

  while (true) {
    directories.unshift(current);

    const parent = path.dirname(current);
    if (parent === current) {
      return directories;
    }

    current = parent;
  }
}

function uniqueExistingPaths(paths) {
  const seen = new Set();
  const result = [];

  for (const candidate of paths) {
    const resolved = path.resolve(candidate);
    if (!exists(resolved) || seen.has(resolved)) {
      continue;
    }

    seen.add(resolved);
    result.push(resolved);
  }

  return result;
}

function findOpencodeConfig(directory) {
  for (const configName of opencodeConfigNames) {
    const candidate = path.join(directory, configName);
    if (isFile(candidate)) {
      return candidate;
    }
  }

  return undefined;
}

function stripJsonComments(source) {
  let output = "";
  let inString = false;
  let escaped = false;
  let inLineComment = false;
  let inBlockComment = false;

  for (let i = 0; i < source.length; i += 1) {
    const current = source[i];
    const next = source[i + 1];

    if (inLineComment) {
      if (current === "\n") {
        inLineComment = false;
        output += current;
      }
      continue;
    }

    if (inBlockComment) {
      if (current === "*" && next === "/") {
        inBlockComment = false;
        i += 1;
      }
      continue;
    }

    if (!inString && current === "/" && next === "/") {
      inLineComment = true;
      i += 1;
      continue;
    }

    if (!inString && current === "/" && next === "*") {
      inBlockComment = true;
      i += 1;
      continue;
    }

    output += current;

    if (escaped) {
      escaped = false;
      continue;
    }

    if (current === "\\") {
      escaped = true;
      continue;
    }

    if (current === '"') {
      inString = !inString;
    }
  }

  return output;
}

function stripTrailingCommas(source) {
  let output = "";
  let inString = false;
  let escaped = false;

  for (let i = 0; i < source.length; i += 1) {
    const current = source[i];

    if (!inString && current === ",") {
      let j = i + 1;
      while (j < source.length && /\s/.test(source[j])) {
        j += 1;
      }

      if (source[j] === "}" || source[j] === "]") {
        continue;
      }
    }

    output += current;

    if (escaped) {
      escaped = false;
      continue;
    }

    if (current === "\\") {
      escaped = true;
      continue;
    }

    if (current === '"') {
      inString = !inString;
    }
  }

  return output;
}

function parseOpencodeConfig(configPath) {
  try {
    const source = fs.readFileSync(configPath, "utf8");
    const normalized = stripTrailingCommas(stripJsonComments(source));
    const parsed = JSON.parse(normalized);
    return parsed && typeof parsed === "object" && !Array.isArray(parsed) ? parsed : undefined;
  } catch {
    return undefined;
  }
}

function collectOpencodeConfigPaths(cwd) {
  const configPaths = [];

  const globalConfig = findOpencodeConfig(opencodeConfigDir);
  if (globalConfig) {
    configPaths.push(globalConfig);
  }

  for (const directory of listAncestorDirectories(cwd)) {
    const configPath = findOpencodeConfig(directory);
    if (configPath) {
      configPaths.push(configPath);
    }
  }

  return uniqueExistingPaths(configPaths);
}

function collectInstructionFiles(cwd) {
  const instructionFiles = [];

  for (const configPath of collectOpencodeConfigPaths(cwd)) {
    const config = parseOpencodeConfig(configPath);
    const instructions = Array.isArray(config?.instructions) ? config.instructions : [];

    for (const instruction of instructions) {
      if (typeof instruction !== "string" || instruction.length === 0) {
        continue;
      }

      const resolved = path.resolve(path.dirname(configPath), instruction);
      if (isFile(resolved)) {
        instructionFiles.push(resolved);
      }
    }
  }

  return uniqueExistingPaths(instructionFiles);
}

function collectResourcePaths(cwd) {
  const promptPaths = [path.join(opencodeConfigDir, "commands")];
  const skillPaths = [path.join(opencodeConfigDir, "skills")];
  const themePaths = [path.join(opencodeConfigDir, "themes")];

  for (const directory of listAncestorDirectories(cwd)) {
    const opencodeDirectory = path.join(directory, ".opencode");
    promptPaths.push(path.join(opencodeDirectory, "commands"));
    skillPaths.push(path.join(opencodeDirectory, "skills"));
    themePaths.push(path.join(opencodeDirectory, "themes"));
  }

  return {
    promptPaths: uniqueExistingPaths(promptPaths).filter(isDirectory),
    skillPaths: uniqueExistingPaths(skillPaths).filter((resourcePath) => isDirectory(resourcePath) || isFile(resourcePath)),
    themePaths: uniqueExistingPaths(themePaths).filter((resourcePath) => isDirectory(resourcePath) || isFile(resourcePath)),
  };
}

function buildInstructionBlock(cwd) {
  const sections = [];

  for (const instructionPath of collectInstructionFiles(cwd)) {
    try {
      const content = fs.readFileSync(instructionPath, "utf8").trim();
      if (!content) {
        continue;
      }

      const displayPath = path.relative(cwd, instructionPath) || instructionPath;
      sections.push(`### ${displayPath}\n\n${content}`);
    } catch {
      // Ignore unreadable instruction files so pi can keep running.
    }
  }

  if (sections.length === 0) {
    return undefined;
  }

  return `## OpenCode Instructions\n\nThe following instruction files were loaded from OpenCode config. Follow them the same way OpenCode would.\n\n${sections.join("\n\n")}`;
}

export default function opencodeBridge(pi) {
  pi.on("resources_discover", (_event, ctx) => {
    return collectResourcePaths(ctx.cwd);
  });

  pi.on("before_agent_start", (event, ctx) => {
    const instructionBlock = buildInstructionBlock(ctx.cwd);
    if (!instructionBlock) {
      return;
    }

    return {
      systemPrompt: `${event.systemPrompt}\n\n${instructionBlock}`,
    };
  });
}
