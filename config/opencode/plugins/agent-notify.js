/**
 * agent-notify.js — desktop notifications for opencode sessions that carry
 * clickable actions.
 *
 * When a session goes idle, errors, or asks for permission, we send a
 * notification with buttons. Clicking "Buka terminal" focuses (or opens) a
 * terminal attached to this session; "Lihat log" copies the last error.
 *
 * Requires: notify-send, kitty, wl-copy.
 */

import { spawn } from "node:child_process"

const APP_NAME = "opencode"

function notify({ summary, body, urgency = "normal", actions = [] }) {
  const args = ["-a", APP_NAME, "-u", urgency, "-i", "utilities-terminal"]

  for (const { key, label } of actions) {
    args.push("-A", `${key}=${label}`)
  }

  args.push(summary, body)

  return new Promise((resolve) => {
    const child = spawn("notify-send", args, { stdio: ["ignore", "pipe", "ignore"] })
    let out = ""
    child.stdout.on("data", (d) => (out += d.toString()))
    child.on("close", () => resolve(out.trim()))
    child.on("error", () => resolve(""))
  })
}

function openSession(directory, sessionID) {
  const target = directory || process.env.HOME
  const args = ["--directory", target, "-e", "opencode"]

  if (sessionID) {
    args.push("--session", sessionID)
  }

  spawn("kitty", args, { detached: true, stdio: "ignore" }).unref()
}

function copyToClipboard(text) {
  const child = spawn("wl-copy", { detached: true, stdio: ["pipe", "ignore", "ignore"] })
  child.stdin.end(text)
  child.unref()
}

export const AgentNotify = async ({ directory }) => {
  return {
    event: async ({ event }) => {
      // Session finished responding: let the user jump back in.
      if (event.type === "session.idle") {
        const sessionID = event.properties?.sessionID
        const action = await notify({
          summary: "Session finished",
          body: directory ? `Ready in ${directory}` : "Ready",
          actions: [
            { key: "open", label: "Buka terminal" },
            { key: "dismiss", label: "Tutup" },
          ],
        })

        if (action === "open") {
          openSession(directory, sessionID)
        }
        return
      }

      // Something broke: offer to reopen the session or copy the message.
      if (event.type === "session.error") {
        const message = event.properties?.error?.message || "Unknown error"
        const sessionID = event.properties?.sessionID

        const action = await notify({
          summary: "Session error",
          body: message.slice(0, 180),
          urgency: "critical",
          actions: [
            { key: "open", label: "Buka terminal" },
            { key: "copy", label: "Copy error" },
          ],
        })

        if (action === "open") {
          openSession(directory, sessionID)
        } else if (action === "copy") {
          copyToClipboard(message)
        }
        return
      }

      // The agent needs a decision before it can continue.
      if (event.type === "permission.asked") {
        const action = await notify({
          summary: "Permission needed",
          body: event.properties?.permission?.title || "opencode is waiting for approval",
          urgency: "normal",
          actions: [
            { key: "open", label: "Buka terminal" },
            { key: "dismiss", label: "Nanti" },
          ],
        })

        if (action === "open") {
          openSession(directory, event.properties?.sessionID)
        }
      }
    },
  }
}
