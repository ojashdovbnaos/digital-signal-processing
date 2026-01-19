# digital-signal-processing
## Overview
This project implements and compares three methods for detecting **DTMF (Dual-Tone Multi-Frequency) signals**, commonly used in telephone systems to represent dialed numbers. Each DTMF key generates the sum of two sinusoidal tones: one from a low-frequency group (697 Hz, 770 Hz, 852 Hz, 941 Hz) and one from a high-frequency group (1209 Hz, 1336 Hz, 1477 Hz, 1633 Hz). Accurate detection of these two frequencies is essential for interpreting keypad inputs in telephony, voice response systems, and embedded devices.

## Methods Implemented
- **Goertzel Algorithm** – Efficient for detecting specific DTMF frequencies.  
- **Matched Filter** – Reliable detection with signal correlation.  
- **FFT-based Approach** – General frequency analysis.

## Analysis
Each method is compared in terms of:
- **Computational cost**  
- **Detection accuracy**
