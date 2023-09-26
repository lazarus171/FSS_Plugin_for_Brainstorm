# FSS_Plugin_for_Brainstorm

This process uses the Simulated Annealing Algorythm to apply the Functional Source Separation
to a dataset, extracting the functional source S1 or M1 (one at a time).

In the database explorer, drag the raw file you want to work out and drop it into the Process1 tab at the bottom of the window, then click on the RUN button on the left.
In the Pipeline editor window, click on the first button to see all the categories of processes available: choose the Test category, then click on the FSS throug Simulated Annealing item.
Set the options in the process GUI as you need, then click on the Run button at the bottom of the window to make the process start.
When the process ends its job, a new folder is available in the database explorer: the suffix "fss" means that the process has been applied.
Import the new raw folder into the database, as described in  https://neuroimage.usc.edu/brainstorm/Tutorials/Epoching#Import_in_database, then apply the Average by file process as described in https://neuroimage.usc.edu/brainstorm/Tutorials/Averaging#Averaging.
To view the response, right-click on the averaged file, then click on the EEG item and finally click on Display time series.
To visualize the signals distribution on the scalp obtained through the FSS process, repeat the sequence described above, but click on the 2D Disc item instead of the Display time series.
You can adjust the instant of visualization by using the buttons in the upper right corner of Brainstorm main window, shown by the red vertical line in the time series window.
When the time is set to the value of the maxSEF option, the signals distribution shown in the scalp visualization indicates the investigated area.
