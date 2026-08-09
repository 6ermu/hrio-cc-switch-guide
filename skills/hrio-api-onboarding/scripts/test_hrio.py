#!/usr/bin/env python3
"""HrioAPI connectivity test bundled with the skill."""

from __future__ import annotations

import argparse
import json
import os
import ssl
import sys
import urllib.error
import urllib.request


DEFAULT_BASE = "https://hrioapi.hrio.site/api"


def request_json(method: str, url: str, api_key: str, body: dict | None, timeout: int) -> tuple[int, object]:
    data = None if body is None else json.dumps(body, ensure_ascii=False).encode("utf-8")
    headers = {"Authorization": f"Bearer {api_key}", "Accept": "application/json"}
    if data is not None:
        headers["Content-Type"] = "application/json"
    request = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(request, timeout=timeout, context=ssl.create_default_context()) as response:
            raw = response.read().decode("utf-8", errors="replace")
            return response.status, json.loads(raw) if raw else {}
    except urllib.error.HTTPError as error:
        raw = error.read().decode("utf-8", errors="replace")
        try:
            payload: object = json.loads(raw) if raw else {}
        except json.JSONDecodeError:
            payload = {"raw": raw[:1000]}
        return error.code, payload


def main() -> int:
    parser = argparse.ArgumentParser(description="HrioAPI connectivity test")
    parser.add_argument("--base", default=os.getenv("HRIO_API_BASE", DEFAULT_BASE).rstrip("/"))
    parser.add_argument("--key", default=os.getenv("HRIO_API_KEY"))
    parser.add_argument("--model", default=os.getenv("HRIO_MODEL"))
    parser.add_argument("--list-models", action="store_true")
    parser.add_argument("--endpoint", choices=("chat", "responses"), default="chat")
    parser.add_argument("--timeout", type=int, default=45)
    args = parser.parse_args()
    if not args.key or args.key == "YOUR_API_KEY":
        print("错误：请通过 HRIO_API_KEY 环境变量或 --key 提供真实 Key。", file=sys.stderr)
        return 2
    status, models_payload = request_json("GET", f"{args.base}/v1/models", args.key, None, args.timeout)
    print(f"[模型列表与 Key 鉴权] HTTP {status}")
    print(json.dumps(models_payload, ensure_ascii=False, indent=2)[:6000])
    if status >= 400:
        return 1
    rows = models_payload.get("data", []) if isinstance(models_payload, dict) else []
    models = [str(row["id"]) for row in rows if isinstance(row, dict) and row.get("id")]
    if args.list_models:
        for model in models:
            print(f"- {model}")
        if not args.model:
            return 0
    model = args.model or (models[0] if models else None)
    if not model:
        return 2
    if args.endpoint == "responses":
        path = "/v1/responses"
        body = {"model": model, "input": "只回复 OK", "max_output_tokens": 16, "stream": False}
    else:
        path = "/v1/chat/completions"
        body = {"model": model, "messages": [{"role": "user", "content": "只回复 OK"}], "max_tokens": 16, "stream": False}
    status, payload = request_json("POST", f"{args.base}{path}", args.key, body, args.timeout)
    print(f"[最小文本请求] HTTP {status}")
    print(json.dumps(payload, ensure_ascii=False, indent=2)[:6000])
    return 0 if status < 400 else 1


if __name__ == "__main__":
    raise SystemExit(main())

