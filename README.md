# Online multiple view tracking: Target association across cameras  

Developed by Quoc C.LE at LIFAT, University of Tours, France

### Introduction

**MDP_MTMC_tracking** is an online Multiple target Multiple Camera tracking method based on the code source of [1]

### Usage

1. Run complie.m (openCV required)
2. Run MTMC_test.m (the code is tested on the 2 sequences: PETS09_S2L1 and EPFL Terrace1)
### Citation

    @inproceedings{le:hal-01880374,
      TITLE = {{Online Multiple View Tracking: Targets Association Across Cameras}},
      AUTHOR = {Le, Quoc Cuong and Conte, Donatello and Hidane, Moncef},
      URL = {https://hal.archives-ouvertes.fr/hal-01880374},
      BOOKTITLE = {{6th Workshop on Activity Monitoring by Multiple Distributed Sensing (AMMDS 2018)}},
      ADDRESS = {Newcastle, United Kingdom},
      YEAR = {2018},
      MONTH = Sep,
      PDF = {https://hal.archives-ouvertes.fr/hal-01880374/file/2018AMMDS.pdf},
      HAL_ID = {hal-01880374},
      HAL_VERSION = {v1},
    }

### Dataset and Detection

Will be available soon.

### Evaluation metric

To validate the method, we adopt the popular metrics used in motchallenge.net including CLEAR MOT metric [2] and ID measures [3].

### References

[1] Yu Xiang, Alexandre Alahi, and Silvio Savarese. Learning to track: Online multi-objecttracking  by  decision  making.   In2015 IEEE international conference on computervision (ICCV), number EPFL-CONF-230283, pages 4705–4713. IEEE, 2015.

[2] Keni Bernardin and Rainer Stiefelhagen.  Evaluating multiple object tracking perfor-mance: the clear mot metrics.Journal on Image and Video Processing, 2008:1, 2008

[3] Ergys Ristani, Francesco Solera, Roger Zou, Rita Cucchiara, and Carlo Tomasi.  Per-formance measures and a data set for multi-target, multi-camera tracking. InEuropeanConference on Computer Vision, pages 17–35. Springer, 2016.

### Contact

If you have any problem with the code, please contact quoccuong dot le at etu dot univ-tours dot fr
