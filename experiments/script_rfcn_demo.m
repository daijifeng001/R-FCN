function script_rfcn_demo()
% script_rfcn_demo()
% A demo of R-FCN for object detection using ResNet101 model and RPN
% proposals
% --------------------------------------------------------
% R-FCN implementation
% Modified from MATLAB Faster R-CNN (https://github.com/shaoqingren/faster_rcnn)
% Copyright (c) 2016, Jifeng Dai
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

clc;
clear mex;
clear is_valid_handle; % to clear init_key
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'startup'));
%% -------------------- CONFIG --------------------
opts.caffe_version          = 'caffe_rfcn';
opts.gpu_id                 = auto_select_gpu;
opts.use_gpu                = true;
opts.max_rois_num_in_gpu    = 5000;
active_caffe_mex(opts.gpu_id, opts.caffe_version);
classes = {'aeroplane', 'bicycle', 'bird', 'boat', 'bottle', 'bus', 'car', 'cat', 'chair',...
        'cow', 'diningtable', 'dog', 'horse', 'motorbike', 'person', 'pottedplant', ...
        'sheep', 'sofa', 'train', 'tvmonitor'};

demo_dir               = fullfile(pwd, 'data', 'demo');

% conf

conf                   = rfcn_config_ohem('image_means',...
                                    fullfile(pwd, 'models', 'pre_trained_models', 'ResNet-101L', 'mean_image'));

%% -------------------- INIT MODEL -----------------
rfcn_net_def           = fullfile(pwd, 'models', 'rfcn_prototxts', 'ResNet-101L_OHEM_res3a', 'test.prototxt');
rfcn_net               = fullfile(pwd, 'output', 'rfcn_demo', ...
                                       'rfcn_VOC0712_ResNet101_OHEM_rpn_resnet101','final');

caffe_net = caffe.Net(rfcn_net_def, 'test');
caffe_net.copy_from(rfcn_net);

% set gpu/cpu
if opts.use_gpu
    caffe.set_mode_gpu();
else
    caffe.set_mode_cpu();
end
%% -------------------- WARM UP --------------------
% the first run will be slower; use an empty image to warm up
for j = 1:2 % we warm up 2 times
    im = uint8(ones(375, 500, 3)*128);
    proposals = repmat([1,1,400,275], [2000, 1]);
    proposals = proposals+100*rand(size(proposals));
    [boxes, scores] = rfcn_im_detect(conf, caffe_net, im, proposals, opts.max_rois_num_in_gpu);
end

%% -------------------- TESTING --------------------
im_names = {'000166', '001852', '002597', '004030', '005225'};
running_time = zeros(length(im_names), 1);
for j = 1:length(im_names)
    im = imread(fullfile(demo_dir, [im_names{j}, '.jpg']));
    proposals = load(fullfile(demo_dir, [im_names{j}, '_boxes.mat']));
    proposals = single(proposals.boxes);
    tic
    [boxes, scores] = rfcn_im_detect(conf, caffe_net, im, proposals, opts.max_rois_num_in_gpu);
    th = toc;
    fprintf('%s, (%dx%d): time %.3fs\n', im_names{j}, size(im, 1), size(im, 2), th);
    running_time(j) = th;
    boxes_cell = cell(length(classes), 1);
    thres = 0.6;
    for i = 1:length(boxes_cell)
        boxes_cell{i} = [boxes(:, (1+(i-1)*4):(i*4)), scores(:, i)];
        boxes_cell{i} = boxes_cell{i}(nms(boxes_cell{i}, 0.3), :);
        
        I = boxes_cell{i}(:, 5) >= thres;
        boxes_cell{i} = boxes_cell{i}(I, :);
    end
    figure(j);
    showboxes(im, boxes_cell, classes, 'voc');
    pause(0.1);
end
fprintf('mean time: %.3fs\n', mean(running_time));
end
