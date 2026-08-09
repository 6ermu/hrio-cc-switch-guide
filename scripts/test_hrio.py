#!/usr/bin/env python3
"""Safely test HrioAPI authentication, model listing, and one text request."""

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


def extract_models(payload: object) -> list[str]:
    if not isinstance(payload, dict):
        return []
    rows = payload.get("data")
    if not isinstance(rows, list):
        return []
    return [str(row["id"]) for row in rows if isinstance(row, dict) and row.get("id")]


def print_result(label: str, status: int, payload: object) -> None:
    print(f"\n[{label}] HTTP {status}")
    print(json.dumps(payload, ensure_ascii=False, indent=2)[:6000])


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
    models = extract_models(models_payload)
    print_result("模型列表与 Key 鉴权", status, models_payload)
    if status in (401, 403):
        print("结论：Key 无效、已禁用，或没有访问权限。", file=sys.stderr)
        return 1
    if status >= 400:
        print("结论：模型列表请求失败，请检查 Base URL、网络或平台状态。", file=sys.stderr)
        return 1
    if args.list_models:
        print("\n可复制的模型 ID：")
        for model in models:
            print(f"- {model}")
        if not args.model:
            return 0

    model = args.model or (models[0] if models else None)
    if not model:
        print("错误：没有可用模型。请使用 --model 指定控制台中的模型 ID。", file=sys.stderr)
        return 2

    if args.endpoint == "responses":
        path = "/v1/responses"
        body = {"model": model, "input": "只回复 OK", "max_output_tokens": 16, "stream": False}
    else:
        path = "/v1/chat/completions"
        body = {
            "model": model,
            "messages": [{"role": "user", "content": "只回复 OK"}],
            "max_tokens": 16,
            "stream": False,
        }
    status, payload = request_json("POST", f"{args.base}{path}", args.key, body, args.timeout)
    print_result(f"最小文本请求 {path}", status, payload)
    if status >= 400:
        print("结论：鉴权可能已通过，但模型、协议或路由不匹配。", file=sys.stderr)
        return 1
    print("\n结论：HrioAPI 已连通。现在可以把相同 Base URL、Key 和模型 ID 填入 CC Switch。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

