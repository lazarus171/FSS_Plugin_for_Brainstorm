# FSS_Plugin_for_Brainstorm

This process uses the Simulated Annealing Algorythm to apply the Functional Source Separation
to a dataset, extracting the functional source S1 or M1 (one at a time).

## Dataset description

The dataset consists of:
- one subject, one acquisition run of about 4 minutes;
- sample frequency: 5000 Hz;
- subject stimulated by galvanic median nerve stimulation;
- 63 acquisition channels and one trigger channel;

## Process GUI screenshot

![The process GUI in the pipeline editor](/screenshot.png)

## Options desription
### Dataset dependant options:
- Sensor types or names (empty=all): indicates which sensors are to be considered for elaboration.
- Sample frequency: the frequency at which the recordings were taken.
- maxSEF: is the time at which one can read the maximum potential, referring to the trigger. It has to be read directly on the original EEG, since it depends on the subject itself.
- lowSEF: is the time **before** maxSEF (on its left side) in which the potential is half the value of maxSEF potential. Expressed in absolute value.
- highSEF: is the time **after** maxSEF (on its right side) in which the potential is half the value of maxSEF potential. Expressed in absolute value.
- Trial Duration : the length of a single trial, including the pretrigger.
- pretrigger: the small amount of time considered **before** a trigger instant.
- bas: indicates the points between which the baseline is calculated.

### Simulated Annealing options
- Advanced SA options: if selected, it allows the user to change the successive Simulated Annealing parameters.
- lambda: a balancing parameter used in computing the Simulated Annealing objective function.
- Initial temperature for SA: the initial value of the temperature for SA.
- Function Tolerance: one of the SA stopping criteria.
- Max Time: another SA stopping criteria.
- Max Stall Iteration: the third SA stopping criteria.
- Reannealing Interval: causes the algorithm to restart from a temperature comprised between the current temperature and the previous starting one.

## How to use the process

In the database explorer, drag and drop the raw file you want to work out into the "Process1" tab at the bottom of the window, then click on the "RUN" button on the left.

In the Pipeline editor window, click on the first button to see all the categories of processes available: choose the "Test" category, then click on the "FSS throug Simulated Annealing" item.
![The process selection](/pipeline_editor.png)

Set the options in the process GUI as you need, then click on the "Run" button at the bottom of the window to make the process start. While the process is running, you should see on your screen something like the image below.
![The Matlab screen while the process is running](/screen_look.png)

When the process ends its job, a new raw folder is available in the database explorer: the suffix "fss" means that the process has been applied.

Import the new raw folder into the database, as described in [this tutorial](https://neuroimage.usc.edu/brainstorm/Tutorials/Epoching#Import_in_database), then apply the "Average by file" process as described in [this tutorial](https://neuroimage.usc.edu/brainstorm/Tutorials/Averaging#Averaging).

To view the response, right-click on the averaged file, then click on the "EEG" item and finally click on "Display time series".

To visualize the signals distribution on the scalp, obtained through the FSS process, repeat the sequence described above, but click on the "2D Disc" item instead of the "Display time series".

You can adjust the instant of visualization by using the buttons in the upper right corner of Brainstorm main window; the current value of time is shown by the red vertical line in the time series window.

When the time is set to the value of the maxSEF option, the signals distribution shown in the scalp visualization indicates the investigated area.

