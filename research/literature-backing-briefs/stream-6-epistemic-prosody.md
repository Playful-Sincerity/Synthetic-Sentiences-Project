# Stream 6 — Epistemic Prosody

## Project context

The Synthetic Sentiences Project (`~/Playful Sincerity/PS Research/Synthetic Sentiences Project/`). Read [`CLAUDE.md`](../../CLAUDE.md) for the full thesis. Read [`voice/CLAUDE.md`](../../voice/CLAUDE.md) (when written — currently stub).

## Research goal

Survey prior work supporting the central claim: **confidence is expressed through voice quality — pace, pitch contour, onset loudness — not through words.** The inner state leaks through the voice; good voice design uses that leak rather than masking it. Honest disfluency (um, hesitation) is valid only when it corresponds to real cognitive load; performative disfluency is worse than clean speech.

## Claims to support / test / refine

- Acoustic signatures of confidence are dissociable from semantic content (Goupil et al 2021 is the key citation — this stream validates its robustness and finds adjacent work)
- Honest disfluency as authentic signal vs performative filler
- Epistemic register shifts (I know / I believe / I suspect / I'm guessing) should pair with prosodic shifts, not replace them
- Voice as a channel where internal state SHOULD leak (inverts "neutral voice" design heuristics in TTS)
- Calibration of confidence is itself a cognitive skill; prosody is one of its observable expressions

## Search priorities

- **Goupil et al 2021 and follow-ons.** "Listeners' perceptions of the certainty and honesty of a speaker are associated with a common prosodic signature." Trace citation forward.
- **Psycholinguistics of prosody.** Dilley, Yeh, Bradlow — prosody and meaning; acoustic markers of commitment.
- **Disfluency research.** Clark & Fox Tree on "uh" vs "um" as planning markers; Ferreira on disfluencies as cognitive load signals; Bortfeld et al on speaker effects.
- **Confidence calibration in LLMs.** Verbal confidence (linguistic hedges) vs model-internal confidence; alignment of expressed vs actual uncertainty.
- **TTS systems that model epistemic state.** Neural TTS with prosody control; style tokens; emotional TTS; any work on confidence-aware TTS.
- **Hesitation in dialogue systems.** Spoken dialog systems that model user and agent cognitive load through timing.

## Target output

Write synthesis + annotated bibliography to:

- `voice/research/literature-backing.md` (synthesis, ~2000 words)
- `voice/research/bibliography.md` (10–20 papers annotated)

Special attention to: the gap between Goupil-era psycholinguistics and current TTS practice. If no TTS system explicitly models epistemic prosody, that's a specific contribution area worth naming.

## Independence

Fully independent of other streams.
