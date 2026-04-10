import json
import re
import time
import argparse
from concurrent.futures import ThreadPoolExecutor, TimeoutError
from pathlib import Path

from deep_translator import GoogleTranslator


ROOT = Path(r"c:\Users\suren\flutter_app\truecircle")
SRC_DIR = ROOT / "assets" / "data"
DST_DIR = ROOT / "assets" / "data_hi"
MAP_PATH = DST_DIR / "dataset_map_hi.json"
PROGRESS_PATH = ROOT / "tools" / "translate_cbt_hindi_progress.json"

FILES = [
    "CBT_Thoughts_En.json",
    "Coping_cards_En.json",
    "micro_lessons.json",
    "cbt_pack.json",
    "Cognitive_Distortions_Detector.json",
    "Complete_Belief_Restructuring_Worksheet.json",
    "behavioral_activation_data.json",
    "exposure_ladder.json",
    "trigger_response_chain_analysis.json",
    "relapse_prevention_plan.json",
    "core_belief_tracker.json",
    "weekly_cbt_progress_scorecard.json",
]


def clean_text(text: str) -> str:
    return (
        text.replace("â€™", "'")
        .replace("â€œ", '"')
        .replace("â€\x9d", '"')
        .replace("â€”", "-")
        .replace("â€“", "-")
    )


def should_translate(s: str) -> bool:
    t = s.strip()
    if not t:
        return False
    if re.fullmatch(r"[0-9\s\-\+\.,:%/()]+", t):
        return False
    if re.fullmatch(r"[a-z0-9_]+", t):
        return False
    if t.startswith("assets/"):
        return False
    if re.fullmatch(r"[A-Z0-9_]+", t):
        return False
    if re.search(r"[\u0900-\u097F]", t):
        return False
    return re.search(r"[A-Za-z]", t) is not None


class TranslatorCache:
    def __init__(self) -> None:
        self.translator = GoogleTranslator(source="en", target="hi")
        self.cache: dict[str, str] = {}

    def _reset_translator(self) -> None:
        self.translator = GoogleTranslator(source="en", target="hi")

    def _with_timeout(self, fn, timeout_sec: float):
        with ThreadPoolExecutor(max_workers=1) as pool:
            future = pool.submit(fn)
            return future.result(timeout=timeout_sec)

    def translate(self, s: str) -> str:
        s = clean_text(s)
        if not should_translate(s):
            return s
        if s in self.cache:
            return self.cache[s]
        for _ in range(3):
            try:
                out = self._with_timeout(
                    lambda: self.translator.translate(s),
                    timeout_sec=12,
                )
                if out:
                    self.cache[s] = out
                    return out
            except Exception:
                self._reset_translator()
                time.sleep(0.4)
        self.cache[s] = s
        return s

    def translate_batch(self, values: list[str]) -> list[str]:
        if not values:
            return values
        out = list(values)
        indexes: list[int] = []
        pending: list[str] = []
        for idx, s in enumerate(values):
            s2 = clean_text(s)
            if not should_translate(s2):
                out[idx] = s2
                continue
            if s2 in self.cache:
                out[idx] = self.cache[s2]
                continue
            indexes.append(idx)
            pending.append(s2)
        if not pending:
            return out

        chunk_size = 30
        for start in range(0, len(pending), chunk_size):
            chunk = pending[start : start + chunk_size]
            translated_chunk = None
            for _ in range(3):
                try:
                    translated_chunk = self._with_timeout(
                        lambda: self.translator.translate_batch(chunk),
                        timeout_sec=20,
                    )
                    break
                except TimeoutError:
                    self._reset_translator()
                    time.sleep(0.6)
                except Exception:
                    self._reset_translator()
                    time.sleep(0.6)
            if translated_chunk is None:
                translated_chunk = chunk
            for i, src in enumerate(chunk):
                dst = translated_chunk[i] if i < len(translated_chunk) else src
                self.cache[src] = dst

        for idx, s in zip(indexes, pending):
            out[idx] = self.cache.get(s, s)
        return out


def walk_and_translate(node, tc: TranslatorCache):
    if isinstance(node, dict):
        out = {}
        for k, v in node.items():
            if isinstance(v, str):
                out[k] = tc.translate(v)
            else:
                out[k] = walk_and_translate(v, tc)
        return out
    if isinstance(node, list):
        if all(isinstance(item, str) for item in node):
            return tc.translate_batch([str(item) for item in node])
        out = []
        for item in node:
            if isinstance(item, str):
                out.append(tc.translate(item))
            else:
                out.append(walk_and_translate(item, tc))
        return out
    return node


def target_name(src_name: str) -> str:
    if src_name.endswith(".json"):
        return src_name[:-5] + "_hi.json"
    if src_name.endswith(".JSON"):
        return src_name[:-5] + "_hi.JSON"
    return src_name + "_hi"


def load_progress() -> dict:
    if not PROGRESS_PATH.exists():
        return {}
    try:
        return json.loads(PROGRESS_PATH.read_text(encoding="utf-8-sig"))
    except Exception:
        return {}


def save_progress(progress: dict) -> None:
    PROGRESS_PATH.write_text(
        json.dumps(progress, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--max-file-kb",
        type=int,
        default=120,
        help="Skip translating files larger than this size (KB). Mapping still updates.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Re-translate even if file marked done in progress file.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    max_file_bytes = max(args.max_file_kb, 1) * 1024
    tc = TranslatorCache()
    updated = {}
    progress = load_progress()

    for name in FILES:
        src_path = SRC_DIR / name
        if not src_path.exists():
            continue
        if progress.get(name) == "done" and not args.force:
            out_name = target_name(name)
            updated[f"assets/data/{name}"] = f"assets/data_hi/{out_name}"
            print(f"Skip (already done): {name}")
            continue

        out_name = target_name(name)
        out_path = DST_DIR / out_name
        updated[f"assets/data/{name}"] = f"assets/data_hi/{out_name}"

        if src_path.stat().st_size > max_file_bytes:
            if not out_path.exists():
                out_path.write_text(src_path.read_text(encoding="utf-8-sig"), encoding="utf-8")
            progress[name] = "copied_large"
            save_progress(progress)
            print(f"Skip large file (copied): {name}")
            continue

        print(f"Translating: {name}")
        data = json.loads(src_path.read_text(encoding="utf-8-sig"))
        translated = walk_and_translate(data, tc)
        out_path.write_text(
            json.dumps(translated, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )
        progress[name] = "done"
        save_progress(progress)
        print(f"Done: {out_name}")

    map_data = json.loads(MAP_PATH.read_text(encoding="utf-8-sig"))
    datasets = map_data.get("datasets", {})
    datasets.update(updated)
    map_data["datasets"] = dict(sorted(datasets.items(), key=lambda kv: kv[0].lower()))
    MAP_PATH.write_text(
        json.dumps(map_data, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print("dataset_map_hi.json updated")


if __name__ == "__main__":
    main()
