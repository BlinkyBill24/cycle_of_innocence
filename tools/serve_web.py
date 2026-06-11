#!/usr/bin/env python3
"""Serve the web export locally (NAS unavailable — 2026-06-11 workflow).

Plain HTTP on localhost is a secure context, so SharedArrayBuffer works as
long as the COOP/COEP headers are present (needed if we ever switch to the
threaded export template).

Usage: python3 tools/serve_web.py [port]   # default 8081, serves exports/web
"""
import http.server
import sys
from pathlib import Path

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8081
ROOT = Path(__file__).resolve().parent.parent / "exports" / "web"


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


if __name__ == "__main__":
    print(f"serving {ROOT} at http://localhost:{PORT}")
    http.server.ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
