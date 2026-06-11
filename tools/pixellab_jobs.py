#!/usr/bin/env python3
"""Slot-aware PixelLab background-job pool (tier 2: priority queue, up to
10 concurrent jobs — we keep 8 in flight and refill as renders finish).

Usage:
    from pixellab_jobs import run_jobs
    results = run_jobs([(label, submit_fn), ...])  # submit_fn() -> job_id
"""
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from pixellab_v2 import call  # noqa: E402

MAX_IN_FLIGHT = 8
POLL_SECONDS = 12


def run_jobs(jobs: list, max_in_flight: int = MAX_IN_FLIGHT,
             retries: int = 2, log=print) -> dict:
    """jobs: [(label, submit_fn)]. Keeps <= max_in_flight rendering; failed
    jobs resubmit up to `retries` times. Returns {label: succeeded}."""
    pending = list(jobs)
    in_flight: dict = {}   # label -> job_id
    attempts: dict = {}    # label -> count
    results: dict = {}
    while pending or in_flight:
        while pending and len(in_flight) < max_in_flight:
            label, submit_fn = pending.pop(0)
            attempts[label] = attempts.get(label, 0) + 1
            try:
                in_flight[label] = submit_fn()
                log(f"submitted {label} (attempt {attempts[label]})")
            except Exception as e:  # noqa: BLE001 — 429/502: back off, retry
                log(f"{label}: submit error ({str(e)[:100]})")
                if attempts[label] <= retries:
                    pending.append((label, submit_fn))
                    time.sleep(30)
                else:
                    results[label] = False
        time.sleep(POLL_SECONDS)
        for label, jid in list(in_flight.items()):
            try:
                status = call(f"background-jobs/{jid}", method="GET").get("status")
            except Exception as e:  # noqa: BLE001
                log(f"{label}: poll error ({str(e)[:80]})")
                continue
            if status == "completed":
                log(f"  {label}: completed")
                results[label] = True
                del in_flight[label]
            elif status == "failed":
                log(f"  {label}: failed")
                del in_flight[label]
                if attempts[label] <= retries:
                    pending.append((label, next(fn for l, fn in jobs if l == label)))
                else:
                    results[label] = False
    return results
