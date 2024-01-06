# FSS plugin for Brainstorm

This process uses the [Simulated Annealing Algorithm](https://it.mathworks.com/help/gads/what-is-simulated-annealing.html) to apply the Functional Source Separation
to a dataset, extracting the functional source S1 or M1 (one at a time).

## Dataset description

The dataset consists of:
- one subject, two acquisition runs (left and right stimulation) of about 4 minutes each;
- sampling frequency: 5000 Hz;
- subject stimulated by galvanic median nerve stimulation;
- 63 acquisition channels;

## Process GUI screenshot

![The process GUI in the pipeline editor](/Images/020_processGUI.png)

## Options description
### Dataset dependant options:
- Sensor types or names (empty=all): indicates which sensors are to be considered for elaboration.
- Area: the brain area to be investigated.
- Trial Duration : the length of a single trial, including the pretrigger.
- pretrigger: the small amount of time considered **before** a trigger instant.
- bas: indicates the two points within which the baseline is calculated. If both points are set to the same value, the process will consider the whole trial as the baseline.

### Simulated Annealing options
- Advanced SA options: if selected, it allows the user to change the successive Simulated Annealing parameters.
- Annealing Function: the function used to perturbate the current configuration. [Further info: see "Algorithm Settings"](https://it.mathworks.com/help/gads/simulated-annealing-options.html#bq26j8s-4)
- Acceptance Function: the function used to accept or reject a new point in SA. [Further info: see "Algorithm Settings"](https://it.mathworks.com/help/gads/simulated-annealing-options.html#bq26j8s-4)
- Temperature Function: the function used to reduce temperature. [Further info: see "Temperature Options"](https://it.mathworks.com/help/gads/simulated-annealing-options.html#bq26j8s-4)
- lambda: a balancing parameter used in computing the Simulated Annealing objective function.
- Initial temperature for SA: the starting value of the temperature for SA.
- Noise threshold coefficient: used by the PCA whitening function, is the coefficient of the value (in scientific notation, **coefficient * 10^exponent**) under which the signals are considered as noise.
- Noise threshold exponent: used by the PCA whitening function, is the exponent of the value (in scientific notation, **coefficient * 10^exponent**) under which the signals are considered as noise.
- Function Tolerance: the first SA stopping criteria: the algorithm stops when the change in the best function value is smaller than this option.
- Max Iterations: one more SA stopping criteria: the algorithm stops after this number of iterations.
- Max Time: another SA stopping criteria: the algorithm stops after the indicated number of seconds.
- Max Stall Iteration: the fourth SA stopping criteria.
- Reannealing Interval: causes the algorithm to restart from a temperature comprised between the current temperature and the previous starting one to avoid the algorithm to get trapped into a local minimum.

## How to use the process

- This process doesn't work on raw files, so that you could need to import your raw files in the Brainstorm database: to do this, just right-click on the file you want to use and select the "Import in database" item.
![Raw file importing](/Images/001_import_raw.png)

- Set the proposed options leaving unchecked the "Create a separate folder for each event type" item, then press the "Import" button.
![Importation options](/Images/002_import_panel.png)

- In the database explorer, drag and drop the file you want to work out into the "Process1" tab at the bottom of the window, then click on the "RUN" button on the left.
![The file selection](/Images/003_drag_drop_run.png)

- In the Pipeline editor window, click on the first button to see all the categories of processes available: choose the "Test" category, then click on the "FSS through Simulated Annealing" item.
![The process selection](/Images/010_pipeline_editor.png)

- Set the [options](#options-description) in the process GUI as you need, then click on the "Run" button at the bottom of the window to make the process start. You can check the SEF values in the windows appearing before the optimization starts.
![The checking window](/Images/025_area_related_values.png)

- While the optimization process is running, you should see on your screen something like the image below.
![The Matlab screen while the process is running](/Images/030_plugin_in_progress.png)

- When the process ends its job, two lines appear at the bottom of the Matlab Command Window: the first indicates which stopping criteria caused the algorithm to end, the second shows how much time was spent to reach the end.
![The Matlab screen at the end of the processing](/Images/040_process_end.PNG)

- A new file is now available in the database explorer: the first part of the file's name stands for the extracted brain area, while the suffix "fss" means that the process has been applied. In the figure below there are 2 files, each one resulting from a different run.
![The new files resulting from the processing](/Images/050_new_files.png)

- To visualize the signals distribution on the scalp, obtained through the FSS process, right-click on the new file, then click on the "EEG" item and finally on the "2D Disc" item as shown below.
![The new files resulting from the processing](/Images/060_visual_cmd.png)

- If everything went well, you should see the scalp distribution of the extracted signals.
![The resulting visualization](/Images/070_final_view.png)
