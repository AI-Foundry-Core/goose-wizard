"""Reads Goose stream-json output and detects turn completion.

When Goose runs with `--output-format stream-json`, it emits
newline-delimited JSON events. The critical signal is:

    {"type":"complete","total_tokens":...}

This means the agent finished its turn and is waiting for user input.
No timeout guessing — this is a protocol-level signal.
"""

import json
import queue
import threading
from typing import Optional


class WaitDetector:
    """Reads Goose stream-json events and detects turn boundaries."""

    def __init__(self, pipe, safety_timeout: float = 300.0):
        """
        Args:
            pipe: The stdout pipe from the Goose process.
            safety_timeout: Max seconds to wait for a complete event
                before giving up (safety valve, not the detection mechanism).
        """
        self._pipe = pipe
        self._safety_timeout = safety_timeout
        self._queue: queue.Queue[Optional[str]] = queue.Queue()
        self._thread = threading.Thread(target=self._reader, daemon=True)
        self._thread.start()

    def _reader(self):
        """Read lines from pipe into queue. Runs in daemon thread."""
        try:
            for line in iter(self._pipe.readline, ""):
                self._queue.put(line)
        except (ValueError, OSError):
            pass  # Pipe closed
        finally:
            self._queue.put(None)  # Sentinel: pipe closed

    def collect_until_turn_complete(self) -> tuple[str, bool]:
        """Collect teacher output until a 'complete' event or process exit.

        Parses stream-json events. Accumulates message content.
        Returns when it sees {"type":"complete",...} or the pipe closes.

        Returns:
            (output_text, finished)
            - output_text: All message content from this turn
            - finished: True if the process exited (no more turns)
        """
        text_parts = []
        while True:
            try:
                line = self._queue.get(timeout=self._safety_timeout)
            except queue.Empty:
                # Safety timeout — agent took too long
                return "".join(text_parts), False

            if line is None:
                # Pipe closed — process exited
                return "".join(text_parts), True

            line = line.strip()
            if not line:
                continue

            # Try to parse as JSON event
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                # Non-JSON output (e.g., the goose banner). Capture as text.
                text_parts.append(line + "\n")
                continue

            event_type = event.get("type", "")

            if event_type == "complete":
                # Agent finished its turn — this is the signal we want
                return "".join(text_parts), False

            elif event_type == "message":
                # Agent is producing content — accumulate it
                content = event.get("content", "")
                if content:
                    text_parts.append(content)

            elif event_type == "error":
                error_msg = event.get("message", "unknown error")
                text_parts.append(f"[ERROR: {error_msg}]\n")

            # Ignore other event types (notification, etc.)
