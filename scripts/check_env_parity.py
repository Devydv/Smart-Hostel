#!/usr/bin/env python3
"""Environment parity checks across local compose, CI, and server deploy workflow."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COMPOSE = ROOT / "docker-compose.yml"
CI_WORKFLOW = ROOT / ".github/workflows/ci.yml"
DOCKERFILE = ROOT / "Dockerfile"
DEPLOY_PLAYBOOK = ROOT / "infra/ansible/deploy.yml"

REQUIRED_DB_KEYS = {"DB_HOST", "DB_USER", "DB_PASSWORD", "DB_NAME"}


def fail(message: str) -> None:
    print(f"[parity-check] FAIL: {message}")
    raise SystemExit(1)


def parse_python_version_from_dockerfile(content: str) -> str:
    match = re.search(r"^FROM\s+python:(\d+\.\d+)", content, flags=re.MULTILINE)
    if not match:
        fail("Unable to find Python base image version in Dockerfile")
    return match.group(1)


def parse_python_version_from_ci(content: str) -> str:
    match = re.search(r"python-version:\s*\"?(\d+\.\d+)\"?", content)
    if not match:
        fail("Unable to find python-version in CI workflow")
    return match.group(1)


def parse_env_block_keys(lines: list[str], section_header: str, env_indent: int, key_indent: int) -> set[str]:
    keys: set[str] = set()
    in_section = False
    in_env = False

    for line in lines:
        stripped = line.strip()
        indent = len(line) - len(line.lstrip(" "))

        if stripped == section_header:
            in_section = True
            in_env = False
            continue

        if in_section and indent <= env_indent - 2 and stripped.endswith(":") and stripped != "env:":
            in_section = False
            in_env = False

        if not in_section:
            continue

        if stripped == "env:" and indent == env_indent:
            in_env = True
            continue

        if in_env:
            if indent < key_indent or not stripped:
                in_env = False
                continue
            if indent == key_indent and ":" in stripped:
                key = stripped.split(":", 1)[0].strip()
                keys.add(key)

    return keys


def parse_compose_web_env_keys(content: str) -> set[str]:
    lines = content.splitlines()
    keys: set[str] = set()
    in_web = False
    in_env = False

    for line in lines:
        stripped = line.strip()
        indent = len(line) - len(line.lstrip(" "))

        if stripped == "web:":
            in_web = True
            in_env = False
            continue

        if in_web and indent <= 2 and stripped.endswith(":") and stripped != "web:":
            in_web = False
            in_env = False

        if not in_web:
            continue

        if stripped == "environment:" and indent == 4:
            in_env = True
            continue

        if in_env:
            if indent < 6 or not stripped:
                in_env = False
                continue
            if indent == 6 and ":" in stripped:
                key = stripped.split(":", 1)[0].strip()
                keys.add(key)

    return keys


def main() -> None:
    compose_content = COMPOSE.read_text(encoding="utf-8")
    ci_content = CI_WORKFLOW.read_text(encoding="utf-8")
    dockerfile_content = DOCKERFILE.read_text(encoding="utf-8")
    deploy_content = DEPLOY_PLAYBOOK.read_text(encoding="utf-8")

    compose_env = parse_compose_web_env_keys(compose_content)
    if not REQUIRED_DB_KEYS.issubset(compose_env):
        fail(f"docker-compose web env missing required DB keys: {sorted(REQUIRED_DB_KEYS - compose_env)}")

    ci_env = parse_env_block_keys(ci_content.splitlines(), section_header="ci:", env_indent=4, key_indent=6)
    if not REQUIRED_DB_KEYS.issubset(ci_env):
        fail(f"CI env missing required DB keys: {sorted(REQUIRED_DB_KEYS - ci_env)}")

    docker_py = parse_python_version_from_dockerfile(dockerfile_content)
    ci_py = parse_python_version_from_ci(ci_content)
    if docker_py != ci_py:
        fail(f"Python version mismatch: Dockerfile uses {docker_py}, CI uses {ci_py}")

    if "docker compose up -d --build web" not in deploy_content:
        fail("Deploy playbook is not using docker compose web build/start command")

    if "docker compose config >/dev/null" not in deploy_content:
        fail("Deploy playbook missing compose parity validation step")

    print("[parity-check] PASS: local compose, CI, and deploy runtime parity checks succeeded")


if __name__ == "__main__":
    main()
