
This Matlab package implements inference methods of Ledoit and Wolf (2008, JEF).

The package supersedes any previous packages.
In case you have installed a previous package, I recommend to simply remove it.

For HAC inference use the function sharpeHAC.

For bootstrap inference, use the function bootInference:
- the method requires a choice of block size
- the function blockSizeCalibrate selects an `optimal' block size based on Algorithm 3.1
  and is called by default within the function bootInference
- but users can call the function blockSizeCalibrate own its own, 
  changing default input arguments as they see fit, and then supply
  the chosen block size `explicitly' to the function bootInference

All functions have some (hopefully sufficient) documentation built in.

The two empirical data sets of Section 6 are contained in ret.mat.

Michael Wolf (Zurich, December 2014)
