#!/usr/bin/env python3
"""Re-prove one saved testbench, or every testbench, with JasperGold or VC Formal.

A full run writes results/<tool>/table.md. The columns match the paper table.
Final Pass and Final Cov come from the tool. Init Assrt, Init Cov, and Pass
Before Stage 5 stay blank: those counts belong to earlier stages of generation.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import threading
from pathlib import Path

ROOT = Path(__file__).resolve().parent

_JG_LINE = re.compile(
    r"^\[\d+\]\s+(?P<path>[A-Za-z0-9_.]+)\s+:?\s*(?P<status>\S+)",
    re.MULTILINE,
)
_JG_COV = re.compile(
    r"\|\s*(?P<name>[\w\-_.]+)\s*\|\s*[\d.]+%\s*\(\d+/\d+\)\s*\|"
    r"\s*[\d.]+%\s*\(\d+/\d+\)\s*\|\s*(?P<cov>[\d.]+)\s*%"
)
_JG_ASSERT = {"proven", "proved", "vacuous", "cex", "falsified", "undetermined",
              "unprocessed", "bounded", "unreachable", "conflict"}
_VCF_ASSERTION_SUMMARY = re.compile(
    r">\s*Assertion\s*"
    r"- #\s*found\s*:\s*(?P<found>\d+)\s*"
    r"- #\s*proven\s*:\s*(?P<proven>\d+)"
)
_VCF_RESULT = re.compile(
    r"PROP_I_RESULT:\s+(?P<task>\w+)\s+(?P<path>\S+)\s+"
    r"(?P<fields>.+?)\s+(?P<type>property|vacuity|cover|constraint)\s+"
    r"(?P<time>\d+:\d+:\d+)",
    re.MULTILINE,
)
_DENSITY_TOTAL = re.compile(r"^Total\s+(?P<kind>.+?)\s+in\s+given\s+scope\s*:\s*(?P<count>\d+)\s*$")
_DENSITY_ITEM = re.compile(r"^#\d+:\s*(?P<name>\S+)")
_BIND_INST = re.compile(r"(\w+)\s*\(\s*\.\*\s*\)\s*;")


def load_experiments(only: str | None) -> list[dict]:
    data = json.loads((ROOT / "experiments.json").read_text(encoding="utf-8"))
    cells = data["experiments"]
    if only:
        cells = [cell for cell in cells if cell["id"] == only]
        if not cells:
            known = ", ".join(item["id"] for item in data["experiments"])
            raise SystemExit(f"unknown experiment {only}. Names: {known}")
    return cells


def with_virtual_clock(prop_text: str) -> tuple[str, bool]:
    """Give a clockless checker a free-running clock in the work copy."""
    if re.search(r"\bdefault\s+clocking\b", prop_text) or re.search(r"@\s*\(\s*posedge", prop_text):
        return prop_text, False
    match = re.search(r"\n[ \t]*\)\s*;\n", prop_text)
    if not match:
        return prop_text, False
    insert = (
        "\nwire svapshot_vclk;\n"
        "default clocking svapshot_cb @(posedge svapshot_vclk); endclocking\n"
    )
    return prop_text[: match.end()] + insert + prop_text[match.end() :], True


def stage(cell: dict, work: Path, rtl_root: Path, tool: str) -> list[str]:
    if work.exists():
        shutil.rmtree(work)
    work.mkdir(parents=True)
    sources = []
    for rel in cell["rtl"]:
        src = rtl_root / rel
        if not src.is_file():
            raise SystemExit(f"missing design source: {rel}")
        dest = work / src.name
        shutil.copy2(src, dest)
        sources.append(dest.name)
    vclks = []
    extras = []
    for check in cell["checks"]:
        folder = ROOT / check
        prop = next(folder.glob("*_prop.sv"))
        bind = next(folder.glob("*_bind.svh"))
        text = prop.read_text(encoding="utf-8", errors="replace")
        if tool == "vcformal":
            text, added = with_virtual_clock(text)
            if added:
                inst = _BIND_INST.search(bind.read_text(encoding="utf-8", errors="replace"))
                if inst:
                    vclks.append(f"{inst.group(1)}.svapshot_vclk")
        (work / prop.name).write_text(text, encoding="utf-8")
        shutil.copy2(bind, work / bind.name)
        extras.extend([prop.name, bind.name])
    names = sources + extras
    (work / "files.vc").write_text(_file_list(names), encoding="utf-8")
    if tool == "jaspergold":
        (work / "fpv.tcl").write_text(_jg_tcl(cell), encoding="utf-8")
    else:
        (work / "fpv.tcl").write_text(_vcf_tcl(cell, vclks), encoding="utf-8")
    return vclks


def _file_list(names: list[str]) -> str:
    lines = [
        "+libext+.v",
        "+libext+.sv",
        "+libext+.svh",
        "+librescan",
        "+incdir+.",
        "-y .",
    ]
    lines.extend(names)
    return "\n".join(lines) + "\n"


def _jg_tcl(cell: dict) -> str:
    clock = (cell.get("clock") or "").strip()
    reset = (cell.get("reset") or "").strip()
    lines = [
        "analyze -clear",
        "check_cov -init -type all -model all",
        "analyze -sv12 -f files.vc",
        f"elaborate -top {cell['top']} -disable_auto_bbox -create_related_covers {{witness precondition}}",
    ]
    if clock:
        lines.append(f"clock {clock}")
        lines.append(f"reset -expression (!{reset})")
    else:
        lines.append("clock -none")
        lines.append("reset -none")
    lines += [
        "get_design_info",
        "set_word_level_reduction on",
        "set_prove_time_limit 5m",
        "set_proofgrid_max_jobs 180",
        "set_proofgrid_manager on",
        "autoprove -all",
        "report",
        "check_cov -measure -type {coi stimuli proof bound}",
        "check_cov -report",
        "exit",
        "",
    ]
    return "\n".join(lines)


def _vcf_tcl(cell: dict, vclks: list[str]) -> str:
    clock = (cell.get("clock") or "").strip()
    reset = (cell.get("reset") or "").strip()
    lines = [
        "set_fml_appmode FPV",
        'analyze -format sverilog -vcs "-f files.vc"',
        f"elaborate -sva {cell['top']}",
        "set_fml_var fml_vacuity_on true",
        "set_fml_var fml_witness_on false",
    ]
    if clock:
        lines.append(f"create_clock {clock} -period 100")
        lines.append(f"set_change_at -default -posedge -clock {clock}")
        lines.append(f"create_reset {reset} -sense low")
    for net in vclks:
        if clock:
            lines.append(f"catch {{create_clock {net} -period 100}}")
        else:
            lines.append(f"create_clock {net} -period 100")
    if vclks and clock:
        lines += [
            "catch {",
            "    foreach_in_collection net [get_nets -hierarchical *svapshot_vclk] {",
            "        create_clock [get_attribute $net full_name] -period 100",
            "    }",
            "}",
        ]
    lines += [
        'set report_dir "reports"',
        "file delete -force $report_dir",
        "file mkdir $report_dir",
        'set command_time_budget "30M"',
        "if {[info exists env(SVAPSHOT_FML_MAX_TIME)]} {",
        "    set command_time_budget $env(SVAPSHOT_FML_MAX_TIME)",
        "}",
        'set property_time_budget "5M"',
        "if {[info exists env(SVAPSHOT_FML_PROPERTY_TIME)]} {",
        "    set property_time_budget $env(SVAPSHOT_FML_PROPERTY_TIME)",
        "}",
        "catch {set_fml_var fml_max_time $command_time_budget}",
        "catch {set_fml_var fml_property_time_limit $property_time_budget}",
        "if {[catch {check_fv -block} check_fv_error]} {",
        '    echo "CHECK_FV_FAILED: $check_fv_error"',
        "}",
        "catch {redirect -file $report_dir/properties.rpt {report_fv -verbose}}",
        "catch {compute_formal_core -block}",
        "catch {redirect -file $report_dir/formal_core.rpt {report_formal_core -verbose}}",
        "catch {",
        "    redirect -file $report_dir/assertion_density.rpt {",
        "        report_assertion_density -list -status all -type reg",
        "    }",
        "}",
        "exit",
        "",
    ]
    return "\n".join(lines)


def parse_jaspergold(log_text: str, top: str) -> dict:
    proved = 0
    total = 0
    for match in _JG_LINE.finditer(log_text):
        status = match.group("status").lower().rstrip(".,")
        if status not in _JG_ASSERT:
            continue
        total += 1
        if status in {"proven", "proved", "vacuous"}:
            proved += 1
    cov = ""
    rows = list(_JG_COV.finditer(log_text))
    chosen = next((row for row in rows if row.group("name") == top), None)
    if chosen is None and rows:
        chosen = rows[0]
    if chosen is not None:
        cov = chosen.group("cov")
    return {"final_pass": f"{proved}/{total}" if total else "", "final_cov": cov}


def _base_object_name(name: str) -> str:
    return re.sub(r"\s*\[[^\]]*\]\s*$", "", name.strip())


def _scope_overlap(core: set[str], scope: list[str]) -> int:
    """Count scope registers that the formal core names, by hierarchical suffix."""
    if not core:
        return 0
    hits = 0
    for name in scope:
        target = _base_object_name(name)
        if target in core or any(
            target.endswith("." + candidate) or candidate.endswith("." + target)
            for candidate in core
        ):
            hits += 1
    return hits


def _formal_core_registers(report_text: str) -> dict[str, list[str]]:
    cores: dict[str, list[str]] = {}
    current = ""
    bucket: list[str] | None = None
    for line in report_text.splitlines():
        header = re.match(r"^\s*Property\s*:\s*(.*?)\s*$", line)
        if header:
            current = header.group(1).strip()
            cores[current] = []
            bucket = None
            continue
        if re.match(r"^\s*#Registers\s*:", line):
            bucket = cores.get(current)
            continue
        if re.match(r"^\s*#(Inputs|Constraints)\s*:", line):
            bucket = None
            continue
        if bucket is not None and line[:1] in " \t" and line.strip():
            bucket.append(line.strip())
    return cores


def _register_scope(density_text: str) -> list[str]:
    scope: list[str] = []
    bucket: list[str] | None = None
    for line in density_text.splitlines():
        stripped = line.strip()
        if _DENSITY_TOTAL.match(stripped):
            bucket = scope
            bucket.clear()
            continue
        item = _DENSITY_ITEM.match(stripped)
        if item and bucket is not None:
            bucket.append(item.group("name"))
            continue
        if stripped:
            bucket = None
    return scope


def parse_vcformal(log_text: str, density_text: str, core_text: str = "") -> dict:
    summary = _VCF_ASSERTION_SUMMARY.search(log_text)
    records: dict[str, str] = {}
    proven_paths: set[str] = set()
    vacuous_paths: set[str] = set()
    for match in _VCF_RESULT.finditer(log_text):
        if match.group("task").endswith("_COV") or match.group("task") == "COV":
            continue
        fields = match.group("fields").split()
        if not fields:
            continue
        status = fields[-1].split(":")[0]
        if status == "checking":
            continue
        path = match.group("path")
        if match.group("type") == "vacuity":
            if status == "vacuous":
                vacuous_paths.add(path)
            continue
        if match.group("type") != "property":
            continue
        records[path.rsplit(".", 1)[-1]] = status
        if status == "proven":
            proven_paths.add(path)
    if summary:
        proved = int(summary.group("proven"))
        total = int(summary.group("found"))
    else:
        proved = sum(1 for status in records.values() if status == "proven")
        total = len(records)
    active = {path for path in proven_paths if path not in vacuous_paths}
    core_names: set[str] = set()
    for prop, registers in _formal_core_registers(core_text).items():
        if any(prop == path or prop.endswith("." + path) or path.endswith("." + prop) for path in active):
            core_names.update(_base_object_name(name) for name in registers)
    scope = _register_scope(density_text)
    cov = ""
    if scope and core_text:
        cov = f"{100.0 * _scope_overlap(core_names, scope) / len(scope):.1f}"
    return {"final_pass": f"{proved}/{total}" if total else "", "final_cov": cov}


def _forward_engine(stream, handle) -> None:
    """Copy the engine transcript to the terminal and to the saved log."""
    for raw in iter(stream.readline, b""):
        text = raw.decode("utf-8", errors="replace")
        sys.stdout.write(text)
        sys.stdout.flush()
        handle.write(text)
        handle.flush()


def run_one(cell: dict, tool: str, rtl_root: Path, out_dir: Path, timeout_s: int) -> dict:
    work = out_dir / "work" / cell["id"]
    stage(cell, work, rtl_root, tool)
    log_path = out_dir / "logs" / f"{cell['id']}.log"
    log_path.parent.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ)
    if tool == "jaspergold":
        cmd = ["jg", "-batch", "-tcl", "fpv.tcl", "-proj", "jg_proj"]
    else:
        env["TERM"] = "vt100"
        cmd = ["vcf", "-full64", "-session", "vcst_rtdb", "-no_restore", "-f", "fpv.tcl", "-batch"]
    with log_path.open("w", encoding="utf-8") as handle:
        proc = subprocess.Popen(
            cmd,
            cwd=work,
            env=env,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            start_new_session=True,
        )
        copier = threading.Thread(target=_forward_engine, args=(proc.stdout, handle), daemon=True)
        copier.start()
        try:
            code = proc.wait(timeout=timeout_s)
        except subprocess.TimeoutExpired:
            os.killpg(proc.pid, signal.SIGKILL)
            proc.wait()
            code = 124
            handle.write("\nWALL_CLOCK_STOP\n")
        copier.join(timeout=5)
    log_text = log_path.read_text(encoding="utf-8", errors="replace")
    if tool == "jaspergold":
        parsed = parse_jaspergold(log_text, cell["top"])
    else:
        density = work / "reports" / "assertion_density.rpt"
        density_text = density.read_text(encoding="utf-8", errors="replace") if density.is_file() else ""
        core_text = _read(work / "reports" / "formal_core.rpt")
        parsed = parse_vcformal(
            log_text + "\n" + _read(work / "reports" / "properties.rpt"),
            density_text,
            core_text,
        )
    result = {
        "id": cell["id"],
        "module": cell["module"],
        "llm": cell["llm"],
        "topology": cell["topology"],
        "source": cell["source"],
        "loc": cell["loc"],
        "sub": cell["sub"],
        "final_pass": parsed["final_pass"],
        "final_cov": parsed["final_cov"],
        "returncode": code,
        "log": str(log_path),
    }
    dest = out_dir / "json" / f"{cell['id']}.json"
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    return result


def _read(path: Path) -> str:
    if path.is_file():
        return path.read_text(encoding="utf-8", errors="replace")
    return ""


def write_table(rows: list[dict], path: Path) -> None:
    header = (
        "| RTL Module | LLM | Topology | Source | LOC | Sub | Init Assrt | Init Cov "
        "| Pass Before Stage 5 | Final Pass | Final Cov |"
    )
    rule = "| --- | --- | --- | --- | ---: | ---: | --- | --- | --- | --- | --- |"
    lines = [header, rule]
    for row in rows:
        final_pass = row.get("final_pass") or "—"
        final_cov = row.get("final_cov") or "—"
        lines.append(
            f"| {row['module']} | {row['llm']} | {row['topology']} | {row['source']} "
            f"| {row['loc']} | {row['sub']} | — | — | — | {final_pass} | {final_cov} |"
        )
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rtl-root", required=True)
    parser.add_argument("tool", choices=("jaspergold", "vcformal"))
    parser.add_argument("experiment", nargs="?", default="")
    parser.add_argument("--timeout", type=int, default=6 * 60 * 60)
    args = parser.parse_args()
    rtl_root = Path(args.rtl_root).resolve()
    if not rtl_root.is_dir():
        print("design source directory is missing", file=sys.stderr)
        return 2
    binary = "jg" if args.tool == "jaspergold" else "vcf"
    if not shutil.which(binary):
        print(f"{binary} is missing from PATH", file=sys.stderr)
        return 2
    if args.tool == "vcformal" and not os.environ.get("SNPSLMD_LICENSE_FILE"):
        print("SNPSLMD_LICENSE_FILE is unset", file=sys.stderr)
        return 2
    cells = load_experiments(args.experiment or None)
    out_dir = ROOT / "results" / args.tool
    rows = []
    for index, cell in enumerate(cells, 1):
        done = out_dir / "json" / f"{cell['id']}.json"
        if done.is_file() and not args.experiment:
            previous = json.loads(done.read_text(encoding="utf-8"))
            if previous.get("final_pass"):
                print(f"[{index}/{len(cells)}] {cell['id']} already recorded", flush=True)
                rows.append(previous)
                continue
        print(f"[{index}/{len(cells)}] {cell['id']}", flush=True)
        result = run_one(cell, args.tool, rtl_root, out_dir, args.timeout)
        rows.append(result)
        print(f"    Final Pass {result['final_pass'] or '—'}  Final Cov {result['final_cov'] or '—'}", flush=True)
    if not args.experiment:
        table = out_dir / "table.md"
        write_table(rows, table)
        print(f"wrote {table}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
