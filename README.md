# dac-2026-artifacts

Final assertion testbenches for the paper *Will AI mess my RTL? A snapshot-based approach to verifying AI-written RTL*.

Sargantana is the open-source RISC-V core described by Víctor Soria-Pardos, Max Doblas, Guillem López-Paradís, Gerard Candón, Narcís Rodas, Xavier Carril, Pau Fontova-Musté, Neiel Leyva, Santiago Marco-Sola, and Miquel Moretó, “Sargantana: A 1 GHz+ In-Order RISC-V Processor with SIMD Vector Extensions in 22nm FD-SOI,” Euromicro Conference on Digital System Design (DSD), 2022, pp. 254–261, [10.1109/DSD57027.2022.00042](https://doi.org/10.1109/DSD57027.2022.00042).

The public sources are [bsc-loca/sargantana](https://github.com/bsc-loca/sargantana). The core [`rtl/`](https://github.com/bsc-loca/sargantana/tree/403975c8a3c64c8eb369021a1ac2a374e5df441b/rtl) directory at tag v3.1 (`403975c8a3c6`, 2026-06-08) is the current release tree. The page-table walker and the TLB live in the MMU repository, which that commit records as the `rtl/mmu` submodule: [`mmu` `rtl/`](https://github.com/bsc-loca/mmu/tree/0f4727a7ed57651f465f4eeeae509859693ad4dc/rtl) at `0f4727a7ed57` (2026-04-21).

The commit in each row is the public revision whose file matches the copy in this release.

| File in `rtl/` | Upstream file | Matching commit |
| --- | --- | --- |
| `branch_unit.sv` | [`rtl/datapath/rtl/exe_stage/rtl/branch_unit.sv`](https://github.com/bsc-loca/sargantana/blob/c6981edb8a3c3afe08d12c979fa372c4bb7f1a37/rtl/datapath/rtl/exe_stage/rtl/branch_unit.sv) | [`c6981edb8a3c`](https://github.com/bsc-loca/sargantana/commit/c6981edb8a3c3afe08d12c979fa372c4bb7f1a37) (2025-07-11, tags v2.1 and v3.0) |
| `drac_pkg.sv` | [`includes/drac_pkg.sv`](https://github.com/bsc-loca/sargantana/blob/1bc21ec4da9873d63ffa9de82342ca746d9aa6ba/includes/drac_pkg.sv) | [`1bc21ec4da98`](https://github.com/bsc-loca/sargantana/commit/1bc21ec4da9873d63ffa9de82342ca746d9aa6ba) (2025-07-08, tags v2.1 and v3.0) |
| `riscv_pkg.sv` | [`includes/riscv_pkg.sv`](https://github.com/bsc-loca/sargantana/blob/403975c8a3c64c8eb369021a1ac2a374e5df441b/includes/riscv_pkg.sv) | [`403975c8a3c6`](https://github.com/bsc-loca/sargantana/commit/403975c8a3c64c8eb369021a1ac2a374e5df441b) (v3.1, 2026-06-08) |
| `scoreboard_sargantana.sv` | [`rtl/datapath/rtl/exe_stage/rtl/score_board_scalar.sv`](https://github.com/bsc-loca/sargantana/blob/403975c8a3c64c8eb369021a1ac2a374e5df441b/rtl/datapath/rtl/exe_stage/rtl/score_board_scalar.sv) | [`403975c8a3c6`](https://github.com/bsc-loca/sargantana/commit/403975c8a3c64c8eb369021a1ac2a374e5df441b) (v3.1, 2026-06-08) |
| `mmu_pkg.sv` | [`includes/mmu_pkg.sv`](https://github.com/bsc-loca/mmu/blob/0f4727a7ed57651f465f4eeeae509859693ad4dc/includes/mmu_pkg.sv) | [`0f4727a7ed57`](https://github.com/bsc-loca/mmu/commit/0f4727a7ed57651f465f4eeeae509859693ad4dc) (2026-04-21) |
| `pseudoLRU.sv` | [`rtl/common/pseudoLRU.sv`](https://github.com/bsc-loca/mmu/blob/0f4727a7ed57651f465f4eeeae509859693ad4dc/rtl/common/pseudoLRU.sv) | [`0f4727a7ed57`](https://github.com/bsc-loca/mmu/commit/0f4727a7ed57651f465f4eeeae509859693ad4dc) (2026-04-21) |
| `ptw.sv` | [`rtl/ptw/ptw.sv`](https://github.com/bsc-loca/mmu/blob/0f4727a7ed57651f465f4eeeae509859693ad4dc/rtl/ptw/ptw.sv) | [`0f4727a7ed57`](https://github.com/bsc-loca/mmu/commit/0f4727a7ed57651f465f4eeeae509859693ad4dc) (2026-04-21) |
| `ptw_arb.sv` | [`rtl/ptw/ptw_arb.sv`](https://github.com/bsc-loca/mmu/blob/0f4727a7ed57651f465f4eeeae509859693ad4dc/rtl/ptw/ptw_arb.sv) | [`0f4727a7ed57`](https://github.com/bsc-loca/mmu/commit/0f4727a7ed57651f465f4eeeae509859693ad4dc) (2026-04-21) |
| `tlb.sv` | [`rtl/tlb/tlb.sv`](https://github.com/bsc-loca/mmu/blob/4943acc397dd2655075459df0b102fe26e3343be/rtl/tlb/tlb.sv) | [`4943acc397dd`](https://github.com/bsc-loca/mmu/commit/4943acc397dd2655075459df0b102fe26e3343be) (2025-04-24) |

`scoreboard_sargantana.sv` names the module `scoreboard_sargantana`. The upstream module at `403975c8a3c6` is `score_board_scalar`, and its `set_mul_64_i` arm writes `inst_d[1]`. This copy writes `inst_d[2]`.

`experiments.json` names `popcount`, `skipper_counter`, `edge_detector`, `alu`, `dynamic_target_event_counter`, `div_unit`, `div_unit_4bits`, and `mul_unit`. Place those sources in the directory passed as `--rtl-root`.

JasperGold is the tool used in the paper (`jg` on `PATH`). VC Formal re-proves the same testbenches (`vcf` on `PATH`, with `SNPSLMD_LICENSE_FILE` set in the environment).

One experiment:

```
python3 reproduce.py --rtl-root rtl jaspergold ptw__gpt_41_mini
python3 reproduce.py --rtl-root /path/to/rtl vcformal mul_unit__llama_405b
```

Every experiment:

```
python3 reproduce.py --rtl-root /path/to/rtl jaspergold
python3 reproduce.py --rtl-root /path/to/rtl vcformal
```

The experiment name is the `id` field in `experiments.json`. A parent row such as `div_unit__gpt_41_mini` elaborates the parent together with the submodule testbench, matching the paper row “with submodules”.

`logs/<id>/` holds the generation transcript for every experiment: `interactions/`, and `agent.log` where the run recorded one. For `popcount`, `skipper_counter`, `edge_detector`, `alu`, `dynamic_target_event_counter`, `div_unit`, `div_unit_4bits`, and `mul_unit`, each prompt keeps the line `Here is the RTL:` and replaces the source with a placeholder. The Sargantana transcripts keep the RTL that is already in `rtl/`.

A full run writes `results/<tool>/table.md`. This release gives Final Pass and Final Cov. Final Pass for JasperGold is properties marked proven or vacuous over the properties in the report. Final Pass for VC Formal is the Assertion summary's proven count over its found count, and that proven count includes the vacuous properties. JasperGold Final Cov is checker coverage from `check_cov -report`. VC Formal Final Cov is formal core coverage: the registers the non-vacuous proofs use, divided by the registers in scope, as a percentage. Checker coverage and formal core coverage count different objects, so the same testbench receives a different Final Cov from each tool. Topology, Source, LOC, and Sub identify the row.

## Expected table

These are the paper’s Final Pass and Final Cov values from JasperGold v2021.12. A re-proof reports Final Pass and Final Cov for the tool named on the command line. The Final Cov column below is JasperGold checker coverage.

| RTL Module | LLM | Topology | Source | LOC | Sub | Final Pass | Final Cov |
| --- | --- | --- | ---: | ---: | ---: | --- | ---: |
| popcount | GPT 4.1 mini | S | Internal | 139 | 2 | 3/59 | 93.9 |
| skipper_counter | GPT 4.1 mini | S | Internal | 165 | 2 | 4/22 | 53.5 |
| edge_detector | GPT 4.1 mini | S | Internal | 24 | 0 | 19/19 | 73.3 |
| alu | GPT 4.1 mini | C | Internal | 173 | 0 | 35/46 | 100 |
| dynamic_target_event_counter | GPT 4.1 mini | S | Internal | 230 | 1 | 6/14 | 62.8 |
| score_board_scalar | GPT 4.1 mini | S | Sargantana Core | 96 | 0 | 12/22 | 86.0 |
| branch_unit | GPT 4.1 mini | C | Sargantana Core | 140 | 0 | 12/14 | 42.0 |
| tlb (with submodules) | GPT 4.1 mini | S | Sargantana Core | 372 | 1 | 37/43 | 39.3 |
| ptw (with submodules) | GPT 4.1 mini | S | Sargantana Core | 419 | 2 | 96/107 | 52.8 |
| ptw_arb | GPT 4.1 mini | S | Sargantana Core | 115 | 0 | 33/37 | 95.7 |
| pseudoLRU | GPT 4.1 mini | S | Sargantana Core | 137 | 0 | 29/35 | 70.7 |
| ptw (with submodules) | Llama 3.3 70b | S | Sargantana Core | 419 | 2 | 162/221 | 44.6 |
| ptw_arb | Llama 3.3 70b | S | Sargantana Core | 115 | 0 | 32/49 | 89.0 |
| pseudoLRU | Llama 3.3 70b | S | Sargantana Core | 137 | 0 | 95/106 | 71.7 |
| ptw (with submodules) | Llama 3.1 405b | S | Sargantana Core | 419 | 2 | 86/116 | 43.4 |
| ptw_arb | Llama 3.1 405b | S | Sargantana Core | 115 | 0 | 19/29 | 88.7 |
| pseudoLRU | Llama 3.1 405b | S | Sargantana Core | 137 | 0 | 32/45 | 71.7 |
| div_unit (with submodules) | GPT 4.1 mini | S | Internal | 241 | 1 | 96/128 | 85.6 |
| div_unit_4bits | GPT 4.1 mini | C | Internal | 100 | 0 | 8/10 | 96.6 |
| div_unit (with submodules) | Llama 3.3 70b | S | Internal | 241 | 1 | 132/170 | 83.9 |
| div_unit_4bits | Llama 3.3 70b | C | Internal | 100 | 0 | 35/37 | 99.7 |
| div_unit (with submodules) | Llama 3.1 405b | S | Internal | 241 | 1 | 51/65 | 89.5 |
| div_unit_4bits | Llama 3.1 405b | C | Internal | 100 | 0 | 21/23 | 99.7 |
| mul_unit | GPT 4.1 mini | S | Internal | 294 | 0 | 81/115 | 98.9 |
| mul_unit | Llama 3.3 70b | S | Internal | 294 | 0 | 10/45 | 1.76 |
| mul_unit | Llama 3.1 405b | S | Internal | 294 | 0 | 37/67 | 70.3 |

The pseudoLRU row appears once in this table. The paper repeats that same GPT 4.1 mini row under the TLB group and under the PTW group.
