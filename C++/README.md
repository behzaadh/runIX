# Intersect (IX) Simulator with Restart Files

## Overview

This C++ code serves as a simulator for the Intersect (IX) reservoir simulator (SLB software), designed to create restart files at specified time steps during the simulation. The user provides the initial restart time, and the code runs the simulation until the specified end time, generating restart files at regular intervals.

## Getting started

**Main Simulation Loop**
The `main` function runs the simulation process. It takes command-line arguments for file paths (afi and field Managment Strategy) but provides default values (Example folder) if no arguments are provided. The simulation involves updating input files, running a simulation command, and iterating through time steps until a specified end time is reached.

## Usage
Compile the C++ program and run it from the command line, providing optional paths for input files:
```
./your_program_name [afi_file_path] [fm_file_path]
```
If no file paths are provided, default values will be used (Examples folder).

## Dependencies
- C++ Standard Library

## Notes

- This program assumes Coordinated Universal Time (UTC) for time-related calculations.
- Ensure that the required input files exist and have appropriate content before running the simulation.
- The user is responsible for setting the initial restart time manually.
- Results are printed to the Command Window, indicating the successful completion of the simulation.

Feel free to contact me (behzadh@dtu.dk) for any questions or assistance.
