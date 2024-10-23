# MFD-PC
 MFD Perimeter Control Example

## Overview
This MATLAB code simulates the traffic flow dynamics in a transportation network with two regions using a Macroscopic Fundamental Diagram (MFD) approach. The macrosimulation includes control strategies to manage traffic flow and optimize passenger hours traveled.

## Usage
1. Run the script `MFD_PC_Sim_TwoRegions.m`.
2. Input the exercise index (`a`, `b`, `c`, or `testing`) and required parameters as prompted.

## Code Structure
- **User Input**: Choose an exercise scenario and set parameters.
- **Settings**: Define MFD parameters, simulation settings, and control parameters.
- **Plot MFD Curve**: Visualize MFD curves for both regions.
- **Simulation**: Simulate with control strategies.
- **GetDemand**: Define demand profiles for the simulation.
- **ArrangeFigure**: Function for formatting and styling plots.
- **PlotMFDCurve**: Function for plotting MFD curves.
- **PlotState**: Function for visualizing simulation results.

## Output
The code generates plots illustrating the MFD curves, simulation state, and control actions. The final passenger hour traveled values for each network and the overall system are displayed in the console.

## Exporting Results
Optionally, the code allows the exporting of simulation results as figures in PNG format.

## License
This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
