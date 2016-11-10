# *R-FCN*: Object Detection via Region-based Fully Convolutional Networks

By Jifeng Dai, Yi Li, Kaiming He, Jian Sun

**It is highly recommended to use the [python version of R-FCN](https://github.com/Orpine/py-R-FCN), which supports end-to-end training/inference of R-FCN for object detection.**

### Introduction

**R-FCN** is a region-based object detection framework leveraging deep fully-convolutional networks, which is accurate and efficient. In contrast to previous region-based detectors such as Fast/Faster R-CNN that apply a costly per-region sub-network hundreds of times, our region-based detector is fully convolutional with almost all computation shared on the entire image. R-FCN can natually adopt powerful fully convolutional image classifier backbones, such as [ResNets](https://github.com/KaimingHe/deep-residual-networks), for object detection.

R-FCN was initially described in a [NIPS 2016 paper](https://arxiv.org/abs/1605.06409).

This code has been tested on Windows 7/8 64 bit, Windows Server 2012 R2, and Ubuntu 14.04, with Matlab 2014a.

### License

R-FCN is released under the MIT License (refer to the LICENSE file for details).

### Citing R-FCN

If you find R-FCN useful in your research, please consider citing:

    @article{dai16rfcn,
        Author = {Jifeng Dai, Yi Li, Kaiming He, Jian Sun},
        Title = {{R-FCN}: Object Detection via Region-based Fully Convolutional Networks},
        Journal = {arXiv preprint arXiv:1605.06409},
        Year = {2016}
    }

### Main Results
                   | training data       | test data             | mAP   | time/img (K40) | time/img (Titian X)
-------------------|:-------------------:|:---------------------:|:-----:|:--------------:|:------------------:|
R-FCN, ResNet-50  | VOC 07+12 trainval  | VOC 07 test           | 77.4% | 0.12sec        | 0.09sec            |
R-FCN, ResNet-101 | VOC 07+12 trainval  | VOC 07 test           | 79.5% | 0.17sec        | 0.12sec            |


### Requirements: software

0. `Caffe` build for R-FCN (included in this repository, see `external/caffe`)
    - If you are using Windows, you may download a compiled mex file by running `fetch_data/fetch_caffe_mex_windows_vs2013_cuda75.m`
    - If you are using Linux or you want to compile for Windows, please recompile [our Caffe branch](https://github.com/daijifeng001/caffe-rfcn).
0.	MATLAB 2014a or later
 
    
### Requirements: hardware

GPU: Titan, Titan X, K40, K80.

### Demo
0.	Run `fetch_data/fetch_caffe_mex_windows_vs2013_cuda75.m` to download a compiled Caffe mex (for Windows only).
0.	Run `fetch_data/fetch_demo_model_ResNet101.m` to download a R-FCN model using ResNet-101 net (trained on VOC 07+12 trainval).
0.	Run `rfcn_build.m`.
0.	Run `startup.m`.
0.	Run `experiments/script_rfcn_demo.m` to apply the R-FCN model on demo images.

### Preparation for Training & Testing
0.	Run `fetch_data/fetch_caffe_mex_windows_vs2013_cuda75.m` to download a compiled Caffe mex (for Windows only).
0.	Run `fetch_data/fetch_model_ResNet50.m` to download an ImageNet-pre-trained ResNet-50 net.
0.	Run `fetch_data/fetch_model_ResNet101.m` to download an ImageNet-pre-trained ResNet-101 net.
0.	Run `fetch_data/fetch_region_proposals.m` to download the pre-computed region proposals.
0.	Download VOC 2007 and 2012 data to ./datasets.
0.	Run `rfcn_build.m`.
0.	Run `startup.m`.


### Training & Testing
0. Run `experiments/script_rfcn_VOC0712_ResNet50_OHEM_ss.m` to train a model using ResNet-50 net with online hard example mining (OHEM), leveraging selective search proposals. The accuracy should be ~75.4% in mAP.
    - **Note**: the training time is ~13 hours on Titian X.
0. Run `experiments/script_rfcn_VOC0712_ResNet50_OHEM_rpn.m` to train a model using ResNet-50 net with OHEM, leveraging RPN proposals (using ResNet-50 net). The accuracy should be ~77.4% in mAP.
    - **Note**: the training time is ~13 hours on Titian X.
0. Run `experiments/script_rfcn_VOC0712_ResNet101_OHEM_rpn.m` to train a model using ResNet-101 net with OHEM, leveraging RPN proposals (using ResNet-101 net). The accuracy should be ~79.5% in mAP.
    - **Note**: the training time is ~19 hours on Titian X.
0. Check other scripts in `./experiments` for more settings.

**Note:** 
- In all the experiments, training is performed on VOC 07+12 trainval, and testing is performed on VOC 07 test.
- Results are subject to some random variations. We have run 'experiments/script_rfcn_VOC0712_ResNet50_OHEM_rpn.m' for 5 times, the results are 77.1%, 77.3%, 77.7%, 77.9%, and 77.0%. The mean is 77.4%, and the std is 0.39%.
- Running time is not recorded in the test log (which is slower), but instead in an optimized implementation.

### Resources

0. Experiment logs: [OneDrive](https://1drv.ms/u/s!Am-5JzdW2XHzhc44qdRNJTsXLIU-2w), [BaiduYun](http://pan.baidu.com/s/1mhFYejI)

If the automatic "fetch_data" fails, you may manually download resouces from:

0. Pre-complied caffe mex (Windows):
    - [OneDrive](https://1drv.ms/u/s!Am-5JzdW2XHzhc456RlstMF-4wHr1g), [BaiduYun](http://pan.baidu.com/s/1i4OlG7z)
0. Demo R-FCN model:
    - [OneDrive](https://1drv.ms/u/s!Am-5JzdW2XHzhc486Tyvkf3koU7R7w), [BaiduYun](http://pan.baidu.com/s/1o77gFXo)
0. ImageNet-pretrained networks:
    - ResNet-50 net [OneDrive](https://1drv.ms/u/s!Am-5JzdW2XHzhc46RPYjtbdbNwPJ_w), [BaiduYun](http://pan.baidu.com/s/1kVm4ly3)
    - ResNet-101 net [OneDrive](https://1drv.ms/u/s!Am-5JzdW2XHzhc47z4S7O5Ql6W_0-g), [BaiduYun](http://pan.baidu.com/s/1nvgu1pJ)
0. Pre-computed region proposals:
    - [OneDrive](https://1drv.ms/u/s!Am-5JzdW2XHzhc49StWpgPo2GPEB_A), [BaiduYun](http://pan.baidu.com/s/1hrAJ5re)


