import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { SelectList, type SelectItem } from "@earendil-works/pi-tui";
import { execFileSync } from "node:child_process";
import { existsSync, statSync } from "node:fs";
import { isAbsolute, resolve, relative, dirname } from "node:path";

interface FileCandidate {
	path: string;
	display: string;
}

function lastAssistantText(ctx: ExtensionCommandContext): string | undefined {
	for (const entry of [...ctx.sessionManager.getBranch()].reverse()) {
		if (entry.type !== "message" || entry.message.role !== "assistant") continue;
		const text = entry.message.content
			.filter((part): part is { type: "text"; text: string } => part.type === "text")
			.map((part) => part.text)
			.join("\n")
			.trim();
		if (text) return text;
	}
	return undefined;
}

function candidateTokens(text: string): string[] {
	const tokens = new Set<string>();
	const add = (value: string) => {
		const cleaned = value
			.trim()
			.replace(/^['"`([{<]+/, "")
			.replace(/[\]'"`.,;:!?)}\]>]+$/, "")
			.replace(/#L\d+(?:-L\d+)?$/, "")
			.replace(/:\d+(?::\d+)?$/, "");
		if (!cleaned || cleaned.includes("://") || cleaned.startsWith("$") || cleaned.startsWith("-") || cleaned.length > 300) return;
		tokens.add(cleaned);
	};

	// Markdown links and inline code are the least ambiguous sources of paths.
	for (const match of text.matchAll(/\[[^\]]+\]\(([^)]+)\)|`([^`]+)`/g)) add(match[1] ?? match[2] ?? "");
	// Also inspect ordinary prose for relative and absolute path-shaped tokens.
	for (const match of text.matchAll(/(?:^|\s)((?:\.\.?\/|\/|~\/)[^\s]+|[\w@.-]+\/(?:[\w@.-]+\/)*[\w@.-]+\.[A-Za-z0-9_-]+)/g)) add(match[1] ?? "");
	return [...tokens];
}

function extractFiles(text: string, cwd: string): FileCandidate[] {
	const results = new Map<string, FileCandidate>();
	for (const token of candidateTokens(text)) {
		const expanded = token.startsWith("~/") ? resolve(process.env.HOME ?? cwd, token.slice(2)) : token;
		const absolute = isAbsolute(expanded) ? expanded : resolve(cwd, expanded);
		try {
			if (!existsSync(absolute) || !statSync(absolute).isFile()) continue;
		} catch {
			continue;
		}
		const display = isAbsolute(token) ? token : relative(cwd, absolute) || token;
		results.set(absolute, { path: absolute, display });
	}
	return [...results.values()].sort((a, b) => a.display.localeCompare(b.display));
}

function cmux(args: string[]): string {
	return execFileSync("cmux", args, { encoding: "utf8", env: process.env, timeout: 10_000 }).trim();
}

function shellQuote(value: string): string {
	return `'${value.replaceAll("'", "'\\''")}'`;
}

function openInCmux(filePath: string, cwd: string): void {
	const paneResult = cmux(["new-pane", "--direction", "right", "--focus", "true"]);
	const surface = paneResult.match(/surface:\d+/)?.[0];
	const pane = paneResult.match(/pane:\d+/)?.[0];
	if (!surface || !pane) throw new Error(`Could not determine the new cmux pane: ${paneResult}`);
	cmux(["send", "--surface", surface, `cd ${shellQuote(dirname(filePath) || cwd)} && nvim -- ${shellQuote(filePath)}\n`]);
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("nvim", {
		description: "Pick a file path from the last response and open it in nvim to the right",
		handler: async (_args, ctx) => {
			if (ctx.mode !== "tui") {
				ctx.ui.notify("/nvim requires interactive mode", "error");
				return;
			}

			const response = lastAssistantText(ctx);
			if (!response) {
				ctx.ui.notify("No assistant response found", "warning");
				return;
			}
			const files = extractFiles(response, ctx.cwd);
			if (files.length === 0) {
				ctx.ui.notify("No existing file paths found in the last response", "warning");
				return;
			}

			const items: SelectItem[] = files.map((file) => ({ value: file.path, label: file.display }));
			const selected = await ctx.ui.custom((tui, theme, _keybindings, done) => {
				const list = new SelectList(items, Math.min(12, items.length), {
					selectedPrefix: (value) => theme.fg("accent", value),
					selectedText: (value) => theme.fg("accent", value),
					description: (value) => theme.fg("muted", value),
					noMatch: (value) => theme.fg("warning", value),
				});
				list.onSelect = (item) => done(item.value);
				list.onCancel = () => done(null);
				return {
					render: (width: number) => list.render(width),
					invalidate: () => list.invalidate(),
					handleInput: (data: string) => {
						list.handleInput(data);
						tui.requestRender();
					},
				};
			});
			if (!selected) return;

			try {
				openInCmux(selected, ctx.cwd);
				ctx.ui.notify(`Opened ${relative(ctx.cwd, selected) || selected} in nvim`, "info");
			} catch (error) {
				ctx.ui.notify(`Could not open cmux surface: ${error instanceof Error ? error.message : String(error)}`, "error");
			}
		},
	});
}
