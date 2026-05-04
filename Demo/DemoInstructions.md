### **SPIFEE Demo**

\----------------------------------------------------------------------------------------------------

***Overview***



This folder contains two ways to run the SPIFEE pipeline as a demo:



1\. **Programmatic workflow** using the live script (`Demo.mlx`)

2\. **Graphical User Interface (GUI)** calling `SPIFEE\_GUI` in the MATLAB Command Window



Both approaches demonstrate the same pipeline, with the `.mlx` script 

showing a more transparent, step-by-step view of the underlying methods.

\-------------------------------------------------------------------------------------------------------

**Option 1: Programmatic Demo**



Open and run the live script: ***Demo.mlx***



**This script:**



* Walks through the SPIFEE pipeline step-by-step
* Uses the \*Harton et al. p53 manual modulation dataset\* as an example
* Demonstrates data quality control (QC) by:

  * Introducing synthetic NaN values into one dataset
  * Showcasing how the pipeline visualizes NaNs within data.
* Creates and shows all standard output

\------------------------------------------------------------------------------------------------------------

**Option 2 — GUI Workflow**



Run the graphical interface from the MATLAB command window:



*SPIFEE\_GUI*



**Setup requirements:**



Ensure the SPIFEE folder (SPIFEE) is added to your MATLAB path

Navigate to the ExampleData folder before launching the GUI



Users may impute other options as they see fit, but these options are required:

* NameField: Leave **BLANK**
* "Each trace is a Column" should be **CHECKED**

  * The data is in vertical column format



no other options are required.

\---------------------------------------------------------------------------------------------------------

**Notes \& Best Practices**

* The demo intentionally includes modified data (NaN-imputed) to highlight QC behavior—this is expected.
* Outputs from both methods should be consistent, aside from visualization differences.
* If errors occur:

  * Verify all dependencies are on the MATLAB path
  * Confirm you are running from the correct working directory

