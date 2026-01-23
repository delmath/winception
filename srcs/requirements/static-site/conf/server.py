#!/usr/bin/env python3

import http.server
import os
import socketserver

PORT = 8000


class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="/app/static", **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate")
        self.send_header("Expires", "0")
        super().end_headers()


def run_server():
    handler = MyHTTPRequestHandler

    with socketserver.TCPServer(("", PORT), handler) as httpd:
        print(f"Starting HTTP server on port {PORT}")
        print(f"Serving files from /app/static")
        print(f"Server running at http://0.0.0.0:{PORT}/")
        httpd.serve_forever()


if __name__ == "__main__":
    run_server()
