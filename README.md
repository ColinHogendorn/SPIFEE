# SPIFEE



\---------------------------------------------------------------------------------------------------------------------------------------------------

Welcome to the Signal Processing and Integrated FEature Extraction (SPIFEE) Pipeline!



To start, you need to download the Signal Processing Toolbox from MATLAB. This can accessed through the "Add-Ons" Button in the Home tab in MATLAB.



INSTRUCTIONS

\---------------------------------------------------------------------------------------------------------------------------------------------------

After that, to run SPIFEE, Simply navigate to the SPIFEE files, then open and run the "SPIFEE\_GUI" script. This will open a dialogue box with a few options. First, input parameters that will affect how SPIFEE will filter your data. Enter the Oscillatory Frequency of your signal of interest. (p53 has a frequency of \~5.5) and then enter how long your experiment was. From there, check the boxes of the kinds of analysis that you want outputted from SPIFEE. (Clusters, Average traces of each experimental condition, and Means of each feature). Also enter the name of your experiment to name output files. Then hit RUN which will ask you to select your data. (Data must be in .mat format, with columns representing individual traces. SPIFEE can handle single files or multiple files. the field name for the fluorescent values must be consistent across files).



Speaking of features, here is a list of the intuitive features that SPIFEE calculates:



1\. Height

2\. Location

3\. Width

4\. Prominence

5\. Frequency

6\. Integral

7\. Peak Number\*

8\. Cell Number\*



Along with these features, SPIFEE will save various figures showing clustering results and other analysis. 



\----------------------------------------------------------------------------------------------------------------------------------------------------



Any questions or comments should be sent to Colin Hogendorn at hogen046@umn.edu





\*Bookkeeping features. Not "Features" of the trace. Used for making downstream analysis easier\*

