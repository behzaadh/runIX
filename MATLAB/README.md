# Intersect (IX) Simulator with Restart Files

## Overview

This MATLAB code serves as a simulator for the Intersect (IX) reservoir simulator (SLB software), designed to create restart files at specified time steps during the simulation. The user provides the initial restart time, and the code runs the simulation until the specified end time, generating restart files at regular intervals.

## Getting Started

1. **Prerequisites:**
   - Ensure MATLAB is installed on your system.

2. **Run the Code:**
   - Place the MATLAB script in the directory containing the '*.afi' case file or provide the relative/abolute path of '*.afi' case.
   - Update the input simulation parameters as needed.

3. **Input Parameters:**
   - `startSimulationTime`: The initial simulation time when the model is initialized.
   - `initialRestartTime`: The first restart time, to be set manually by the user.
   - `incrementRestartTime`: Time step for creating restart files (e.g., days, hours, minutes).
   - `endRestartTime`: The final time for the simulation.

4. **Simulation Process**

   1. **Update Field Management Strategy File:**
      - Read the field management strategy file and append a new time step.
      - Set the date and save the restart file information.

   2. **Update AFI File:**
      - Read the AFI file and update the initial restart time.
      - Write the modified AFI file.

   3. **Run the Simulation:**
      - Execute the Intersect (IX) simulator using the updated AFI file.

   4. **Read Results:**
      - Read results from the generated restart file.

   5. **Iterative Simulation:**
      - Repeat the process until the specified end time is reached.

## Notes

- Ensure the code is executed from the directory containing the '*.afi' case file.
- The user is responsible for setting the initial restart time manually.
- Results are printed to the Command Window, indicating the successful completion of the simulation.

Feel free to contact me (behzadh@dtu.dk) for any questions or assistance.
