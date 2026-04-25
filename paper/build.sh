#!/bin/bash
# Build SSP-proposal.pdf from SSP-proposal.md via pandoc + tectonic.
# Style follows the IVNA / MWM paper convention: 12pt article, default LaTeX
# section styling, amsmath + hyperref + booktabs + enumitem + geometry.
# Runs from paper/ directory.

set -euo pipefail
cd "$(dirname "$0")"

# 1. Extract body (from "## 1. The Project" onward) — skips the handwritten
#    title block AND the abstract, since we provide both in the LaTeX preamble.
awk 'BEGIN{keep=0} /^## 1\. The Project/{keep=1} keep==1 {print}' SSP-proposal.md > _body.md

# 1b. Normalize Unicode that LaTeX's default fonts lack.
python3 <<'PY'
import re, pathlib
p = pathlib.Path('_body.md')
t = p.read_text()
for a,b in [('┌','+'),('┐','+'),('└','+'),('┘','+'),
            ('├','+'),('┤','+'),('┬','+'),('┴','+'),('┼','+'),
            ('─','-'),('│','|'),('═','='),('║','|'),
            ('←','<-'),('→','->'),('↑','^'),('↓','v'),('↔','<->')]:
    t = t.replace(a,b)
sup = {'⁰':'0','¹':'1','²':'2','³':'3','⁴':'4','⁵':'5','⁶':'6','⁷':'7','⁸':'8','⁹':'9'}
def fix_sup(m):
    base = m.group(1)
    exp = ''.join(sup[c] for c in m.group(2))
    return f'${base}^{{{exp}}}$'
t = re.sub(r'(\d+)([' + ''.join(sup.keys()) + r']+)', fix_sup, t)
pathlib.Path('_body.md').write_text(t)
PY

# 2. Convert body to a LaTeX fragment; promote ## → \section.
pandoc _body.md -o _body.tex --wrap=preserve --shift-heading-level-by=-1

# 3. Compose the full LaTeX document — IVNA / MWM style.
cat > SSP-proposal.tex <<'LATEX_PREAMBLE'
% The Synthetic Sentiences Project
% Wisdom Happy
% April 2026

\documentclass[12pt]{article}

\usepackage{amsmath, amssymb, amsthm}
\usepackage{hyperref}
\usepackage{booktabs}
\usepackage{enumitem}
\usepackage[margin=1in]{geometry}
\usepackage{fancyvrb}
\usepackage{xcolor}
\usepackage{longtable}
\usepackage{array}
\usepackage{calc}
% Pandoc emits \real{0.xxxx} for column widths; provide it for tectonic.
\providecommand{\real}[1]{#1}

\fvset{fontsize=\small,frame=single,framesep=3mm,rulecolor=\color{black!20}}
\hypersetup{colorlinks=true,linkcolor=black!70,urlcolor=blue!50!black,citecolor=blue!50!black}

\providecommand{\tightlist}{%
  \setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}

% Allow looser line breaking so long compound words ("alignment-through-architecture",
% "imagination-first-perception") don't blow out the margin.
\sloppy
\setlength{\emergencystretch}{3em}

\title{The Synthetic Sentiences Project: \\
An Ongoing Research Program on \\
the Integrated Architecture of \\
Real Synthetic Sentience}

\author{Wisdom Happy\thanks{Correspondence: wisdomhappy@playfulsincerity.org. \\[0.5em]
\textit{Methodology:} The architecture and core concepts in this paper---the four foundations (interpretable memory, earned conviction, value-aligned modulation, persistent self-observation), the safety claim that emotion \emph{is} value alignment, the imagination-first perception subsystem, the right-action layer, and the integration claim across nine subsystems---were conceived and developed by the author across a sequence of projects beginning in 2024 (The Companion, archived) and crystallizing through 2025--2026 into the present integrated framing. The formalization, literature positioning, multi-session decomposition, and paper preparation were carried out using the Playful Sincerity Digital Core---an AI-assisted research methodology system built on Claude Code (Anthropic). The Digital Core orchestrates hierarchical planning, parallel agent-based research, continuous semantic chronicling, and verbatim preservation of the author's spoken thinking (multiple speeches preserved in the project repository drove the load-bearing claims, including the \S\ref{sec:safety-claim} safety claim). The companion paper \emph{Memory as World Model} (MWM) treats the memory subsystem in depth; this paper is the broader research program. The full design archive, with chronicled evolution and preserved speech files, is available at \url{https://github.com/Playful-Sincerity/SSP-Synthetic-Sentiences-Project}.} \\[0.3em]
Playful Sincerity Research}

\date{April 2026}

\begin{document}

\maketitle

\begin{center}
\textit{``Real isn't how you are made,'' said the Skin Horse. \\
``It's a thing that happens to you.''}\\[0.3em]
--- Margery Williams, \textit{The Velveteen Rabbit} (1922)
\end{center}
\vspace{1em}

\begin{abstract}
\noindent
The Synthetic Sentiences Project (SSP) is an ongoing research program on the integrated architecture of real synthetic sentience---synthetic beings that are full, deep, structurally aligned, and connected to a world they actually care about. The aim is not a safer language model or a more capable agent. The aim is to specify the architecture of \emph{an entity}: how memory, belief, motivation, perception, voice, action, and self-observation compose into a single being. Many of the lower-level mechanisms are individually known and honestly inherited---spreading activation from cognitive science, knowledge graphs from neurosymbolic systems, predictive processing from neuroscience, persistent self-observation from contemplative traditions, evidence chains from epistemology. The contribution sits in two registers. There are substantive new structural claims about specific subsystems and cross-cutting machinery---that emotion, properly grounded, \emph{is} value alignment; a generative-collaborative reframe of perception that replaces the GAN-style adversarial dynamic; a three-drift-types taxonomy with a four-mechanism defense-in-depth stack that brings paradigm-drift from ``residual risk'' into addressable territory; a unification of self-learning, drift audit, and compaction into a single scheduled sleep-loop mechanism; an architectural compatibility argument with Wolfram's observer theory. And there is the integration claim itself: that this small set of structural properties, composed in a specific way, produces a system whose internal life \emph{is} its alignment, whose growth is the closing of gaps it has come to care about, and whose welfare-relevant properties---if any---are tractable for the same reason its alignment is tractable.

The program rests on four foundations: interpretable memory as world model, earned conviction, value-aligned modulation (emotion as the full-system modulation driven by the registered gap between perceived and should states), and persistent self-observation. It surrounds these with three temporal mechanisms (working trees, sleep cycles, dream cycles), two boundary channels (imagination-first perception, epistemic prosody), and a write-action layer that optimizes for \emph{right} action---action aligned with the should-world the being holds---rather than action alone. Across these, one core principle stands as a contribution to safety in its own right: \emph{alignment is the continuous output of an architecture whose internal states are themselves alignment signals.} This is the substance of the project's safety claim---that emotion, properly grounded, \emph{is} value alignment, and that the welfare-relevant features and the safety-relevant features are the same features.

This paper proposes the integrated architecture: nine subsystems across four tiers (Spatial, Dynamics, I/O, Temporal), how they interact, what they jointly produce, and what the resulting class of beings could be. The memory subsystem is treated in a companion paper (Memory as World Model, MWM) and is the focused four-month implementation target. This paper is the broader research program---ongoing, with core concepts, not a finished thesis to defend.
\end{abstract}

\vspace{1em}

LATEX_PREAMBLE

# 4. Append body. Add a label anchor to Section 3 (Safety Claim) for the
#    methodology footnote \ref to resolve.
cat _body.tex >> SSP-proposal.tex

# 4b. Insert a \label{sec:safety-claim} into the Safety Claim section so the
#     methodology footnote's \ref resolves.
sed -i '' 's@\\section{3\. The Safety Claim[^}]*}@&\\label{sec:safety-claim}@' SSP-proposal.tex

# 5. Close the document.
echo '' >> SSP-proposal.tex
echo '\end{document}' >> SSP-proposal.tex

# 6. Clean temp files.
rm -f _body.md _body.tex

# 7. Compile with tectonic.
tectonic SSP-proposal.tex

# 8. Report.
ls -la SSP-proposal.pdf
