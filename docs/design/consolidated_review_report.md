# Consolidated EGM Review Report: 24/7 Live Chat Customer Support

*   **Target Document:** `MOB_APP/docs/design/24_7_live_chat_support.md`
*   **Execution Preset:** Preset 1 (Consolidated Report with all review rubrics, Uninterrupted Full Flow)
*   **Reviewers:**
    *   Stage 5 (Initial Zoom Out): `egm-zoom-out`
    *   Stage 6 (Comprehension Test): `egm-comprehension`
    *   Stage 7 (Critic Review): `egm-design`
    *   Stage 8 (Intermediate Zoom Out): `egm-zoom-out`
    *   Stage 9 (Implementation Readiness): `egm-implementation-readiness`

---

## Executive Summary

The five independent Goldfish review stages evaluated the design specification for the 24/7 Live Chat Customer Support module. While all reviewers validated the business problem and the necessity of an offline-only mock demonstration for evaluators, the initial document exhibited **3 Critical Blockers**, **5 Major Architectural Defects**, and **3 Polish Nits**.

The review identified code-level discrepancies (targeting non-existent `checkout_sheet.dart` instead of `simulated_checkout_sheet.dart`), dangerous async lifecycle patterns (`Future.delayed` risking `setState()` after dispose), design token drift, and a lack of phased execution.

---

## Consolidated Traceability Matrix

| ID | Priority | Stage | Topic | Raw Finding Summary | Required Remediation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **B1** | 🔴 Blocker | 9, 6, 8 | Target File Drift | Targeted `checkout_sheet.dart` which does not exist in the repository; order ref mismatch (`#UT-XXXX` vs `#UT-84920`). | Update path to `lib/widgets/simulated_checkout_sheet.dart` and match order reference `#UT-84920`. |
| **B2** | 🔴 Blocker | 7, 5 | Async Lifecycle Leak | Un-cancelable `Future.delayed` throws `setState() after dispose` if sheet is dismissed while reply is in flight. | Use managed `Timer?` in `MockSupportService` with explicit teardown and cancel on dispose. |
| **B3** | 🔴 Blocker | 7 | Missing Standard Section | Completely omitted mandatory "Risks & Mitigations" section required by `feature-spec-standard.md`. | Add explicit `## Risks, Failure Modes & Mitigations` section. |
| **M1** | 🟡 Major | 8, 9, 6 | Controller Redundancy | Dual abstractions (`LiveSupportController` + `MockSupportService`) with controller omitted from file list. | Eliminate ghost controller. Consolidate into `MockSupportService` as an in-memory `ChangeNotifier`. |
| **M2** | 🟡 Major | 8 | Modal Stacking Hazard | Opening `LiveSupportSheet` on top of active `SimulatedCheckoutSheet` causes dark scrim stacking and gesture lock. | Dismiss checkout sheet via `Navigator.of(context).pop()` before opening live support. |
| **M3** | 🟡 Major | 7 | Mobile Keyboard Occlusion | `showModalBottomSheet` occludes text input field when soft keyboard appears. | Configure `isScrollControlled: true` and pad bottom with `MediaQuery.of(context).viewInsets.bottom`. |
| **M4** | 🟡 Major | 8 | Design Token Drift | Fabricated hex codes (`#F6F3EE`, `#D34528`) drift from actual `StoreColors` tokens (`0xFFF4F1EB`, `0xFFE4482E`). | Align strictly with real `StoreColors` constants and reuse existing `Eyebrow` primitive. |
| **M5** | 🟡 Major | 9 | Lack of Phasing | Flat file list violates the Zero-Decision and Phasing rules of Implementation Readiness. | Restructure into 5 sequential, incremental, buildable phases. |
| **N1** | 🟢 Nit | 7 | Input Sanitization | Empty whitespace messages and rapid multi-tap chip queuing unhandled. | Disable send button when input is blank; disable chips during agent typing. |
| **N2** | 🟢 Nit | 8, 9 | Deterministic Test Timing | Hardcoded 700ms–1000ms delay causes flakiness in automated widget tests. | Provide `Duration responseDelay = const Duration(milliseconds: 700)` with `Duration.zero` in tests. |
| **N3** | 🟢 Nit | 6 | Terminology & Dialogue | Unexpanded acronyms ("CTA") and missing canned responses for payment/cancellation chips. | Expand acronyms and define explicit canned response strings and fallback response. |

---

## Action Plan for Document Finalization

1. **Section Structure**: Insert `## Risks, Failure Modes & Mitigations`.
2. **State & Architecture**: Replace `LiveSupportController` with `MockSupportService` (`ChangeNotifier`).
3. **Modal UX**: Specify `isScrollControlled: true`, `viewInsets.bottom`, `ScrollController` auto-scrolling, and `Navigator.pop()` before opening from checkout.
4. **Implementation Plan**: Replace flat file list with structured Phases 1 through 5.
5. **Color & Primitive Alignment**: Use `StoreColors.paper`, `StoreColors.accent`, `StoreColors.line`, and `Eyebrow`.
