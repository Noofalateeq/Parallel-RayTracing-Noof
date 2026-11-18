# Parallel Ray Tracing: Noof

C++17 ray tracer experiment comparing a sequential baseline, an intentionally unsafe counter implementation, and four OpenMP synchronization methods: critical, atomic, reduction, and lock.

## Source variants

All camera snapshots use the same main program and supporting headers. The root camera.h is the final lock snapshot. Do not compile a different executable name and assume that changes the algorithm: select the corresponding camera snapshot.

| Snapshot | Counter handling |
|---|---|
| camera-serial.h | Sequential baseline |
| camera-race.h | Intentionally unsynchronized shared updates |
| camera-critical.h | Critical section around both counters |
| camera-atomic.h | Separate atomic updates |
| camera-reduction.h | Sum reduction for both counters |
| camera-lock.h | Explicit OpenMP lock |

The counters are glass_hits and rendered_pixels. The unsafe variant deliberately contains data races and is for demonstration, not reliable production use.

## Build and run on Windows

Requires a C++17 compiler with OpenMP support (MSYS2 UCRT64 g++ was used). Run from this repository in PowerShell:

```powershell
.\build.ps1 -Variant serial
cmd /c ".\build\serial\raytracer-serial.exe > serial-run1.ppm"

.\build.ps1 -Variant reduction
$env:OMP_DYNAMIC = "FALSE"
$env:OMP_NUM_THREADS = "8"
cmd /c ".\build\reduction\raytracer-reduction.exe > reduction-8-run1.ppm"
```

Use race, critical, atomic, reduction, or lock for the other parallel variants. The build script copies sources into a separate build subdirectory, selects the requested snapshot there, and leaves the root sources unchanged. It adds -fopenmp only for parallel variants; all builds use -std=c++17 -O3. Supply -Compiler with a different g++ path if needed. If local policy prevents PowerShell scripts, use your approved script-running procedure rather than disabling security controls.

For manual compilation in a separate working copy, copy the chosen camera-variant.h to camera.h, then compile main.cc with those same flags.

## Fixed workload and measurement

- Image: 400 x 225 pixels; 10 samples per pixel; maximum depth 20.
- Scene seed: 42; per-pixel seed: 42 + j * image_width + i.
- Thread-local random generator; static collapsed pixel loop in parallel variants.
- Each configuration was run five times. Parallel thread counts: 2, 4, 8.
- Rendering time excludes writing the PPM image and image-buffer allocation. Lock initialization/destruction are outside the timed region.
- Reference counters in each recorded serial run: glass_hits = 245543 and rendered_pixels = 90000.

## Recorded results

- [All 80 runs, CSV](results/runs.csv)
- [All 80 terminal result blocks](results/terminal-results.txt)
- [Configuration summaries](results/summary.csv)

These are the user's recorded terminal measurements, not new measurements produced by packaging this repository. Numeric output precision is preserved. Commands, local personal paths, and unsuccessful setup attempts are omitted from the result-only transcript. The original transcript had a concatenated command before the third race/4-thread result; that single output block is recorded as run 3, not counted twice.

The serial actual_threads CSV field is empty because serial output did not print that field; threads=1 denotes the sequential configuration. counters_match_serial compares the two recorded counters only. All 60 synchronized runs matched both reference counts; all 15 unsafe runs differed. This is not an image-equality check or a formal proof of correctness.

Means use all five measurements per configuration, without discarding slower runs. Results describe this workload and execution environment, not a universal method ranking. Runtime variation may include machine load and other environmental effects.

## Attribution

The original source credits Peter Shirley and carries the CC0 public-domain dedication. Source notices and [COPYING.txt](COPYING.txt) are retained. [README-original.md](README-original.md) preserves the original project instructions; use the variant-aware instructions above for this experiment.

