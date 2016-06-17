function [feat_rois] = rfcn_map_im_rois_to_feat_rois(conf, im_rois, im_scale_factor)
% [feat_rois] = rfcn_map_im_rois_to_feat_rois(conf, im_rois, im_scale_factor)
% --------------------------------------------------------
% R-FCN implementation
% Modified from MATLAB Faster R-CNN (https://github.com/shaoqingren/faster_rcnn)
% Copyright (c) 2016, Jifeng Dai
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

%% Map a ROI in image-pixel coordinates to a ROI in feature coordinates.
% in matlab's index (start from 1)

    feat_rois = round((im_rois-1) * im_scale_factor) + 1;
    
    %feat_rois = round((im_rois-1) * im_scale_factor / single(conf.feat_stride)) + 1;

end